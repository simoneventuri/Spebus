from __future__ import print_function

import numpy
import theano
import theano.tensor as T
from theano.compile.nanguardmode import NanGuardMode
import timeit
import time
import os
import sys
import matplotlib.pyplot as plt
import lasagne
from lasagne.regularization import regularize_layer_params_weighted, l2, l1
from lasagne.regularization import regularize_layer_params

from NNInput         import NNInput
from LoadData        import load_data, abscissa_to_plot, load_parameters, load_parameters_PIP
from MLP             import create_nn, iterate_minibatches
from SaveData        import save_labels, save_parameters, save_parameters_NoBiases, save_parameters_PIP, save_to_plot
from Plot            import plot_history, plot_try_set, plot_error, plot_scatter, plot_overall_error, plot_set
from Compute         import compute_cuts
from TransformOutput import InverseTransformation

# theano.config.optimizer           = 'fast_compile'
# theano.config.exception_verbosity = 'high'
# theano.config.compute_test_value  = 'warn'
#THEANO_FLAGS=mode=DEBUG_MODE python3 Main.py

def sgd_optimization(NNInput):

    # def normalized_squared_error(a, b, expon):
    #     """Computes the element-wise squared normalized difference between two tensors.
    #     .. math:: L = ( (p - t) / t )^2
    #     Parameters
    #     ----------
    #     a, b : Theano tensor
    #         The tensors to compute the squared difference between.
    #     Returns
    #     -------
    #     Theano tensor
    #         An expression for the item-wise squared difference.
    #     """
    #     a, b = align_targets(a, b)
    #     return T.square((a - b) / T.abs_(b)**expon)
    #     # / T.abs_(TargetVar)**(0.0) / T.abs_(b)**expon



    # def weighted_squared_error(a, b, Shift, Power):
    #     """Computes the element-wise squared normalized difference between two tensors.
    #     .. math:: L = ( (p - t) / t )^2
    #     Parameters
    #     ----------
    #     a, b : Theano tensor
    #         The tensors to compute the squared difference between.
    #     Returns
    #     -------
    #     Theano tensor
    #         An expression for the item-wise squared difference.
    #     """
    #     a, b = align_targets(a, b)
    #     Vi   = T.maximum(b, Shift)
    #     w    = T.power(Shift/b, Power)
    #     return w * T.square(a - b)
    #     # / T.abs_(TargetVar)**(0.0) / T.abs_(b)**expon



    # def align_targets(predictions, targets):
    #     """Helper function turning a target 1D vector into a column if needed.
    #     This way, combining a network of a single output unit with a target vector
    #     works as expected by most users, not broadcasting outputs against targets.
    #     Parameters
    #     ----------
    #     predictions : Theano tensor
    #         Expression for the predictions of a neural network.
    #     targets : Theano tensor
    #         Expression or variable for corresponding targets.
    #     Returns
    #     -------
    #     predictions : Theano tensor
    #         The predictions unchanged.
    #     targets : Theano tensor
    #         If `predictions` is a column vector and `targets` is a 1D vector,
    #         returns `targets` turned into a column vector. Otherwise, returns
    #         `targets` unchanged.
    #     """
    #     if (getattr(predictions, 'broadcastable', None) == (False, True) and
    #             getattr(targets, 'ndim', None) == 1):
    #         targets = as_theano_expression(targets).dimshuffle(0, 'x')
    #     return predictions, targets


    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg > 0):
        datasets, datasetsTry, G_MEAN, G_SD, RDataOrig, yDataOrig, yDataDiatOrig = load_data(NNInput)
    else:
        datasets, G_MEAN, G_SD, RDataOrig, yDataOrig, yDataDiatOrig = load_data(NNInput)

    RSetTrain, GSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat = datasets[0]
    RSetValid, GSetValid, ySetValid, ySetValidDiat, ySetValidTriat = datasets[1]
    RSetTest,  GSetTest,  ySetTest,  ySetTestDiat,  ySetTestTriat  = datasets[2]


    plot_set(NNInput, RSetTrain.get_value(), ySetTrainDiat.get_value(), RSetValid.get_value(), ySetValidDiat.get_value(), RSetTest.get_value(), ySetTestDiat.get_value())
    
    NNInput.NIn  = RSetTrain.get_value(borrow=True).shape[1]
    NNInput.NOut = ySetTrain.get_value(borrow=True).shape[1] 
    print(('    Nb of Input:  %i')    % NNInput.NIn)
    print(('    Nb of Output: %i \n') % NNInput.NOut)
    if (NNInput.Model=='ModPIP') or (NNInput.Model=='PIP'):
        NNInput.NLayers = NNInput.NHid
        NNInput.NLayers.insert(0,NNInput.NIn)
        NNInput.NLayers.append(NNInput.NOut)

    NTrain      = RSetTrain.get_value(borrow=True).shape[0]
    NBatchTrain = NTrain // NNInput.NMiniBatch
    NValid      = RSetValid.get_value(borrow=True).shape[0]
    NTest       = RSetTest.get_value(borrow=True).shape[0]
    print(('    Nb of Training   Examples: %i')    % NTrain)
    print(('    Nb of Training   Batches:  %i') % NBatchTrain)
    print(('    Nb of Validation Examples: %i')    % NValid)
    print(('    Nb of Test       Examples: %i \n') % NTest)



    ######################
    # BUILD ACTUAL MODEL #
    ######################  
    InputVar  = T.dmatrix('Inputs')
    #InputVar.tag.test_value  = numpy.random.randint(100,size=(100,3))
    InputVar.tag.test_value  = numpy.array([[1.0,2.0,7.0],[3.0,5.0,11.0]]) * 0.529177
    TargetVar = T.dmatrix('Targets')
    #TargetVar.tag.test_value = numpy.random.randint(100,size=(100,1))


    Layers = create_nn(NNInput, InputVar, TargetVar, G_MEAN, G_SD)

    TrainPrediction  = lasagne.layers.get_output(Layers[-1])
    if (NNInput.LossFunction == 'squared_error'):
        mu, sigma    = 0.0, 0.003 # mean and standard deviation
        #Noise        = numpy.random.normal(mu, sigma)
        Noise        = numpy.random.normal(mu, sigma, (NNInput.NMiniBatch,1))
        #TrainError   = T.sqr( TrainPrediction - TargetVar )
        TrainError   = T.sqr( TrainPrediction - TargetVar + Noise )
        #TrainError       = T.sqr( T.log(T.abs_(TrainPrediction)) - T.log(T.abs_(TargetVar)) )
        #TrainError       = T.sqrt(TrainError.mean())
        TrainError   = TrainError.mean()

        TrainLoss    = lasagne.objectives.squared_error( TrainPrediction, TargetVar + Noise )
        #TrainLoss        = lasagne.objectives.squared_error( T.log(T.abs_(TrainPrediction)), T.log(T.abs_(TargetVar)) )

    # elif (NNInput.LossFunction == 'normalized_squared_error'):
    #     TrainError       = T.abs_( (TrainPrediction - TargetVar ) / T.abs_(TargetVar)**NNInput.OutputExpon )
    #     TrainLoss        = normalized_squared_error(T.log(TrainPrediction), T.log(TargetVar), NNInput.OutputExpon)
    # elif (NNInput.LossFunction == 'huber_loss'):
    #     TrainError       = T.abs_( (TrainPrediction - TargetVar) )
    #     TrainLoss        = lasagne.objectives.huber_loss(TrainPrediction, TargetVar, delta=5)
    # elif (NNInput.LossFunction == 'weighted_squared_error'):
    #     TrainError       = T.abs_( (TrainPrediction - TargetVar) )
    #     TrainLoss        = weighted_squared_error(TrainPrediction, TargetVar, NNInput.Shift, NNInput.Power)

    # if (NNInput.Model == 'ModPIP'):
    #     LayersK          = {Layers[2]: 1, Layers[3]: 1, Layers[4]: 1}
    # elif (NNInput.Model=='ModPIPPol'):
    #     LayersK          = {Layers[1]: 1}
    # elif (NNInput.Model=='PIP'):
    #     LayersK          = {Layers[0]: 1, Layers[1]: 1, Layers[2]: 1}
    # L2Penalty        = regularize_layer_params_weighted(LayersK, l2)
    # L1Penalty        = regularize_layer_params(LayersK, l1)
    TrainLoss        = TrainLoss.mean() #+ NNInput.kWeightDecay[0] * L1Penalty + NNInput.kWeightDecay[1] * L2Penalty

    params           = lasagne.layers.get_all_params(Layers[-1], trainable=True)
    if (NNInput.Method == 'nesterov'):
        updates          = lasagne.updates.nesterov_momentum(TrainLoss, params, learning_rate=NNInput.LearningRate, momentum=NNInput.kMomentum)
    elif (NNInput.Method == 'sgd'):
        updates          = lasagne.updates.sgd(TrainLoss, params, learning_rate=NNInput.LearningRate)
    elif (NNInput.Method == 'rmsprop'):
        updates          = lasagne.updates.rmsprop(TrainLoss, params, learning_rate=NNInput.LearningRate, rho=NNInput.RMSProp[0], epsilon=1e-06)
    elif (NNInput.Method == 'adamax'):
        updates          = lasagne.updates.adamax(TrainLoss, params, learning_rate=NNInput.LearningRate, beta1=0.9, beta2=0.999, epsilon=1e-08)
    elif (NNInput.Method == 'amsgrad'):
        updates          = lasagne.updates.amsgrad(TrainLoss, params, learning_rate=NNInput.LearningRate, beta1=0.9, beta2=0.999, epsilon=1e-08)
    elif (NNInput.Method == 'adam'):
        updates          = lasagne.updates.adam(TrainLoss, params, learning_rate=NNInput.LearningRate, beta1=0.9, beta2=0.999, epsilon=1e-08)
    elif (NNInput.Method == 'adadelta'):
        updates          = lasagne.updates.adadelta(TrainLoss, params, learning_rate=NNInput.LearningRate, rho=0.95, epsilon=1e-08)
    TrainFn = theano.function(inputs=[InputVar, TargetVar], outputs=[TrainError, TrainLoss], updates=updates)


    ValidPrediction = lasagne.layers.get_output(Layers[-1], deterministic=True)
    if (NNInput.LossFunction == 'squared_error'):
        mu, sigma   = 0.0, 0.03 # mean and standard deviation
        #Noise       = numpy.random.normal(mu, sigma)
        Noise       = numpy.random.normal(mu, sigma, (NValid,1) )
        #ValidError  = T.sqr( ValidPrediction - TargetVar)
        ValidError  = T.sqr( ValidPrediction - TargetVar )
        #ValidError      = T.sqr( T.log(T.abs_(ValidPrediction)) - T.log(T.abs_(TargetVar)) )
        ValidError  = ValidError.mean()
    # elif (NNInput.LossFunction == 'normalized_squared_error'):
    #     ValidError      = T.sqr((ValidPrediction - TargetVar) / TargetVar)
    #     ValidError      = T.sqrt(ValidError.mean())
    # elif (NNInput.LossFunction == 'huber_loss'):
    #     ValidError      = T.sqr(ValidPrediction - TargetVar)
    #     ValidError      = T.sqrt(ValidError.mean())
    # elif (NNInput.LossFunction == 'weighted_squared_error'):
    #     Vi              = T.maximum(ValidPrediction, NNInput.Shift)
    #     w               = T.power(NNInput.Shift/TargetVar, NNInput.Power)
    #     ValidError      = w * T.sqr(ValidPrediction - TargetVar)
    #     ValidError      = T.sqrt(ValidError.mean())
    ValFn   = theano.function(inputs=[InputVar, TargetVar], outputs=ValidError)


    TestPrediction = lasagne.layers.get_output(Layers[-1], deterministic=True)
    if (NNInput.LossFunction == 'squared_error'):
        TestError = T.sqr( TestPrediction - TargetVar)
        #ValidError      = T.sqr( T.log(T.abs_(ValidPrediction)) - T.log(T.abs_(TargetVar)) )
        #ValidError      = T.sqrt(ValidError.mean())
        TestError  = TestError.mean()
    # elif (NNInput.LossFunction == 'normalized_squared_error'):
    #     ValidError      = T.sqr((ValidPrediction - TargetVar) / TargetVar)
    #     ValidError      = T.sqrt(ValidError.mean())
    # elif (NNInput.LossFunction == 'huber_loss'):
    #     ValidError      = T.sqr(ValidPrediction - TargetVar)
    #     ValidError      = T.sqrt(ValidError.mean())
    # elif (NNInput.LossFunction == 'weighted_squared_error'):
    #     Vi              = T.maximum(ValidPrediction, NNInput.Shift)
    #     w               = T.power(NNInput.Shift/TargetVar, NNInput.Power)
    #     ValidError      = w * T.sqr(ValidPrediction - TargetVar)
    #     ValidError      = T.sqrt(ValidError.mean())
    TestFn = theano.function(inputs=[InputVar, TargetVar], outputs=TestError)


    ###############
    # TRAIN MODEL #
    ###############
    print('\n\nTRAINING ... ')

    fValid                = min(NBatchTrain, NNInput.NPatience // 2) # go through this many minibatche before checking the network on the validation set; in this case we check every epoch
    BestValidError        = numpy.inf
    BestIter              = 0
    TestScore             = 0.
    tStart                = timeit.default_timer()
    iEpoch                = 0
    LoopingFlg            = True
    iIterTot              = 0
    TrainEpochVec         = []
    TrainErrorVec         = []
    ValidErrorVec         = []
    TestEpochVec          = []
    TestErrorVec          = []
    iTry                  = 0

    if (NNInput.Model=='ModPIP') or (NNInput.Model == 'ModPIPPol'):
        xSetTrain = RSetTrain
        xSetValid = RSetValid
        xSetTest  = RSetTest
        xDataOrig = RDataOrig
    elif (NNInput.Model == 'PIP'):
        xSetTrain = GSetTrain
        xSetValid = GSetValid
        xSetTest  = GSetTest
        #xDataOrig = GDataOrig
    # print(xSetTrain)
    # print(xSetValid)
    # print(xSetTest)
    # print(xDataOrig)
    # print(ySetTrain.get_value())
    # print(ySetValid.get_value())
    # print(ySetTest.get_value())
    # print(yDataOrig)
    # time.sleep(5)


    while (iEpoch < NNInput.NEpoch) and (LoopingFlg):
        iEpoch += 1


        iMiniBatch      = 0
        TrainErrorEpoch = 0
        for TrainBatch in iterate_minibatches(xSetTrain, ySetTrain, NNInput.NMiniBatch, shuffle=True):
            iMiniBatch += 1
            iIterTot    = (iEpoch - 1) * NBatchTrain + iMiniBatch
            TrainInputs, TrainTargets         = TrainBatch
            [TrainErrorBatch, TrainLossBatch] = TrainFn(TrainInputs, TrainTargets)
            TrainErrorEpoch                   = TrainErrorEpoch + TrainErrorBatch
        TrainErrorEpoch = TrainErrorEpoch / iMiniBatch
        TrainErrorVec   = numpy.append(TrainErrorVec, TrainErrorEpoch)


        ValidErorrEpoch = 0
        iMiniBatch      = 0
        for ValidBatch in iterate_minibatches(xSetValid, ySetValid, NValid, shuffle=False):
            iMiniBatch += 1
            ValidInputs, ValidTargets = ValidBatch
            ValidErrorBatch           = ValFn(ValidInputs, ValidTargets)
            ValidErorrEpoch           = ValidErorrEpoch + ValidErrorBatch
        ValidErorrEpoch = ValidErorrEpoch / iMiniBatch
        ValidErrorVec   = numpy.append(ValidErrorVec, ValidErorrEpoch)

        print( '\n    iEpoch %i: Training Error = %f; Validation Error %f' % (iEpoch, TrainErrorEpoch, ValidErorrEpoch) )
        # fig = plt.figure()
        # plt.plot(ValidErorrVec, color='lightblue', linewidth=3)
        # #ax.set_xlim(,)
        # plt.show()

        

        # if we got the best validation score until now
        if ValidErorrEpoch < BestValidError:
            #improve patience if loss improvement is good enough
            #if (ThisValidError < BestValidError * NNInput.ImpThold):
                # NNInput.NPatience = max(NNInput.NPatience, iIterTot * NNInput.NDeltaPatience)

            BestValidError = ValidErorrEpoch
            BestIter       = iIterTot

            TestErrorEpoch = 0
            iMiniBatch     = 0
            for TestBatch in iterate_minibatches(xSetTest, ySetTest, NTest, shuffle=False):
                iMiniBatch += 1
                TestInputs, TestTargets = TestBatch
                TestErrorBatch          = TestFn(TestInputs, TestTargets)
                TestErrorEpoch          = TestErrorEpoch + TestErrorBatch
            TestErrorEpoch = TestErrorEpoch / iMiniBatch
            TestErrorVec   = numpy.append(TestErrorVec, TestErrorEpoch)

            print(('        iEpoch %i,  test error of best model %f') % (iEpoch, TestErrorEpoch))

            TestEpochVec   = numpy.append(TestEpochVec, iEpoch)


            if (NNInput.WriteFinalFlg > 0):
                
                for iLayer in range(len(NNInput.NLayers)-1):

                    PathToFldr = NNInput.PathToOutputFldr + Layers[iLayer].name + '/'
                    if not os.path.exists(PathToFldr):
                        os.makedirs(PathToFldr)
                    PathToFile = PathToFldr + 'Weights.npz'
                    numpy.savez(PathToFile, *lasagne.layers.get_all_param_values(Layers[iLayer]))

                    if (NNInput.WriteFinalFlg > 1):
                        if (NNInput.Model == 'ModPIP'):
                            if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
                                save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
                            elif (iLayer > 1):
                                if (NNInput.BiasesFlg):
                                    save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())
                                else:
                                    save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
                        elif (NNInput.Model == 'ModPIPPol'):
                            if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
                                save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
                            elif (iLayer==1):
                                save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
                        elif (NNInput.Model == 'PIP'):
                            if (NNInput.BiasesFlg):
                                save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())
                            else:
                                save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())


                if (NNInput.TryNNFlg > 1):
                    i=-1
                    for Ang in NNInput.AngVector:
                        i=i+1
                        iTry=iTry+1
                        RSetTry, GSetTry, ySetTry, ySetTryDiat, ySetTryTriat  = datasetsTry[i]
                        if (NNInput.Model == 'ModPIP') or (NNInput.Model == 'ModPIPPol'):
                            xSetTry = RSetTry
                        elif (NNInput.Model == 'PIP'):
                            xSetTry = GSetTry
                        NTry                  = xSetTry.get_value(borrow=True).shape[0]
                        NBatchTry             = NTry // NNInput.NMiniBatch
                        yPredTry = lasagne.layers.get_output(Layers[-1], inputs=xSetTry) 
                        if  (NNInput.TryNNFlg > 2):
                            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(iTry)
                        else:
                            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
                        yPredTry = T.cast(yPredTry, 'float64')
                        yPredTry = yPredTry.eval()
                        yPredTry = InverseTransformation(NNInput, yPredTry, ySetTryDiat.get_value())
                        ySetTry = T.cast(ySetTry, 'float64')
                        ySetTry = ySetTry.eval()
                        ySetTry = InverseTransformation(NNInput, ySetTry, ySetTryDiat.get_value())
                        save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((RSetTry.get_value(), ySetTry, yPredTry), axis=1))
            

        TrainEpochVec = numpy.append(TrainEpochVec, iEpoch)


    #############################################################################################################
    ### LOADING THE OPTIMAL PARAMETERS
    for iLayer in range(len(NNInput.NLayers)-1):

        PathToFldr = NNInput.PathToWeightFldr + Layers[iLayer].name + '/'
        print(' Loading Parameters for Layer ', iLayer, ' from File ', PathToFldr)
        if (NNInput.Model == 'ModPIP'):
            if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
                save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
            elif (iLayer > 1):
                if (NNInput.BiasesFlg):
                    save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())
                else:
                    save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
        elif (NNInput.Model == 'ModPIPPol'):
            if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
                save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
            elif (iLayer==1):
                save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
        elif (NNInput.Model == 'PIP'):
            save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())


    #############################################################################################################
    ### Evaluating Model for a Particular Data-Set
    if (NNInput.TryNNFlg > 0):
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            RSetTry, GSetTry, ySetTry, ySetTryDiat, ySetTryTriat  = datasetsTry[i]
            if (NNInput.Model == 'ModPIP') or (NNInput.Model == 'ModPIPPol'):
                xSetTry = RSetTry
            elif (NNInput.Model == 'PIP'):
                xSetTry = GSetTry
            NTry                  = xSetTry.get_value(borrow=True).shape[0]
            NBatchTry             = NTry // NNInput.NMiniBatch
            yPredTry = lasagne.layers.get_output(Layers[-1], inputs=xSetTry) 
            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
            yPredTry = T.cast(yPredTry, 'float64')
            yPredTry = yPredTry.eval()
            yPredTry = InverseTransformation(NNInput, yPredTry, ySetTryDiat.get_value())
            ySetTry = T.cast(ySetTry, 'float64')
            ySetTry = ySetTry.eval()
            ySetTry = InverseTransformation(NNInput, ySetTry, ySetTryDiat.get_value())
            save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((RSetTry.get_value(), ySetTry, yPredTry), axis=1))


    #############################################################################################################
    ### COMPUTING ERRORS
    ySetTrain = InverseTransformation(NNInput, ySetTrain.get_value(), ySetTrainDiat.get_value())
    ySetValid = InverseTransformation(NNInput, ySetValid.get_value(), ySetValidDiat.get_value())
    ySetTest  = InverseTransformation(NNInput, ySetTest.get_value(),  ySetTestDiat.get_value())

    yPredTrain  = lasagne.layers.get_output(Layers[-1], inputs=xSetTrain) 
    yPredTrain  = T.cast(yPredTrain, 'float64')
    yPredTrain  = yPredTrain.eval()
    yPredTrain  = InverseTransformation(NNInput, yPredTrain, ySetTrainDiat.get_value())
    error_Train = ySetTrain - yPredTrain 
    plot_error(NNInput, error_Train, 'Train')

    yPredValid  = lasagne.layers.get_output(Layers[-1], inputs=xSetValid) 
    yPredValid  = T.cast(yPredValid, 'float64')
    yPredValid  = yPredValid.eval()
    yPredValid  = InverseTransformation(NNInput, yPredValid, ySetValidDiat.get_value())
    error_Valid = ySetValid - yPredValid
    plot_error(NNInput, error_Valid, 'Valid') 

    yPredTest   = lasagne.layers.get_output(Layers[-1], inputs=xSetTest) 
    yPredTest   = T.cast(yPredTest, 'float64')
    yPredTest   = yPredTest.eval()
    yPredTest   = InverseTransformation(NNInput, yPredTest, ySetTestDiat.get_value())
    error_Test  = ySetTest - yPredTest
    plot_error(NNInput, error_Test, 'Test')

    plot_set(NNInput, RSetTrain.get_value(), ySetTrain, RSetValid.get_value(), ySetValid, RSetTest.get_value(), ySetTest)


    yPredOrig   = lasagne.layers.get_output(Layers[-1], inputs=xDataOrig) 
    yPredOrig   = T.cast(yPredOrig, 'float64')
    yPredOrig   = yPredOrig.eval()
    yPredOrig   = InverseTransformation(NNInput, yPredOrig, yDataDiatOrig)
    plot_scatter(NNInput, yPredOrig, yDataOrig)
    #plot_overall_error(NNInput, yPredOrig, yDataOrig)

    plot_history(NNInput, TrainEpochVec, TrainErrorVec, ValidErrorVec, TestEpochVec, TestErrorVec)


    tEnd = timeit.default_timer()
    print(('\nOptimization complete. Best validation score of %f obtained at iteration %i, with test performance %f') % (BestValidError, BestIter + 1, TestScore))
    print(('\nThe code for file ' + os.path.split(__file__)[1] + ' ran for %.2fm' % ((tEnd - tStart) / 60.)), file=sys.stderr)


    #############################################################################################################
    ### COMPUTING CUT PLOTS
    #compute_cuts(NNInput, NNInput.AnglesCuts, NNInput.RCuts, Layers, G_MEAN, G_SD)



def evaluate_model(NNInput):

    datasets, datasetsTry, G_MEAN, G_SD, RDataOrig, yDataOrig, yDataDiatOrig = load_data(NNInput)

    if (NNInput.Model=='ModPIP') or (NNInput.Model=='PIP'):
        NNInput.NLayers = NNInput.NHid
        NNInput.NLayers.insert(0,NNInput.NIn)
        NNInput.NLayers.append(NNInput.NOut)

    InputVar = T.dmatrix('Inputs')
    Layers   = create_nn(NNInput, InputVar, 1, G_MEAN, G_SD)


    if (NNInput.TryNNFlg > 0):
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            RSetTry, GSetTry, ySetTry, ySetTryDiat, ySetTryTriat = datasetsTry[i]
            if (NNInput.Model == 'ModPIP') or (NNInput.Model == 'ModPIPPol'):
                xSetTry = RSetTry
            elif (NNInput.Model == 'PIP'):
                xSetTry = GSetTry
            NTry                  = xSetTry.get_value(borrow=True).shape[0]
            NBatchTry             = NTry // NNInput.NMiniBatch
            yPredTry = lasagne.layers.get_output(Layers[-1], inputs=xSetTry) 
            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
            yPredTry = T.cast(yPredTry, 'float64')
            yPredTry = yPredTry.eval() 
            yPredTry = InverseTransformation(NNInput, yPredTry, ySetTryDiat.get_value())
            ySetTry  = T.cast(ySetTry, 'float64')
            ySetTry  = ySetTry.eval()
            ySetTry  = InverseTransformation(NNInput, ySetTry, ySetTryDiat.get_value())
            save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((RSetTry.get_value(), ySetTry, yPredTry), axis=1))


    for iLayer in range(len(NNInput.NLayers)-1):
        PathToFldr = NNInput.PathToOutputFldr + Layers[iLayer].name + '/'
        if not os.path.exists(PathToFldr):
            os.makedirs(PathToFldr)
        if (NNInput.Model == 'ModPIP'):
            if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
                save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
            elif (iLayer > 1):
                if (NNInput.BiasesFlg):
                    save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())
                else:
                    save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
        elif (NNInput.Model == 'ModPIPPol'):
            if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
                save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
            elif (iLayer==1):
                save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
        elif (NNInput.Model == 'PIP'):
            if (NNInput.BiasesFlg):
                save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())
            else:
                save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())


    compute_cuts(NNInput, NNInput.AnglesCuts, NNInput.RCuts, Layers, G_MEAN, G_SD)



######################################################################################################################################
### RUNNING
######################################################################################################################################
if __name__ == '__main__':

    if ('--help' in sys.argv) or ('-h' in sys.argv):
        print("Neural Network for Potential Energy Surface Fitting Using Lasagne.")
    else:
        if not os.path.exists(NNInput.PathToOutputFldr):
            os.makedirs(NNInput.PathToOutputFldr)

        if (NNInput.TrainFlg):
            sgd_optimization(NNInput)
        else:
            evaluate_model(NNInput)