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
import keras
from keras import backend as K

from NNInput         import NNInput
from LoadData        import load_data, abscissa_to_plot, load_parameters, load_parameters_PIP
from MLP             import build_MLP_model
from SaveData        import save_labels, save_parameters, save_parameters_NoBiases, save_parameters_PIP, save_to_plot
from Plot            import plot_history, plot_try_set, plot_error, plot_scatter, plot_overall_error, plot_set
from Compute         import compute_cuts
from TransformOutput import InverseTransformation

#theano.config.optimizer           = 'fast_compile'
#theano.config.exception_verbosity = 'high'
#theano.config.compute_test_value  = 'warn'
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
        datasets, datasetsTry = load_data(NNInput)
    else:
        datasets = load_data(NNInput)

    RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat = datasets[0]
    RSetValid, ySetValid, ySetValidDiat, ySetValidTriat = datasets[1]
    RDataOrig, yDataOrig, yDataDiatOrig, yDataTriatOrig = datasets[2]

    NNInput.NIn  = RSetTrain.get_value(borrow=True).shape[1]
    #NNInput.NOut = ySetTrain.get_value(borrow=True).shape[1] 
    print(('  Nb of Input:  %i')    % NNInput.NIn)
    print(('  Nb of Output: %i \n') % 1)

    NNInput.NLayers = NNInput.NHid
    NNInput.NLayers.insert(0,NNInput.NIn)
    NNInput.NLayers.append(NNInput.NOut)
    print('  Network Shape: ', NNInput.NLayers, '\n')

    NTrain = RSetTrain.get_value(borrow=True).shape[0]
    NValid = RSetValid.get_value(borrow=True).shape[0]
    print('  Nb of Training + Validation Examples: ', NTrain + NValid, '; of which: ', NTrain, ' for Training and ', NValid, ' for Validation')
    #NTest  = RSetTest.shape[0]
    #print(('  Nb of Test                  Examples: %i \n') % NTest)



    ######################
    # BUILD ACTUAL MODEL #
    ######################  
    InputVar  = T.dmatrix('Inputs')
    #InputVar.tag.test_value  = numpy.random.randint(100,size=(100,3))
    InputVar.tag.test_value  = numpy.array([[1.0,2.0,7.0],[3.0,5.0,11.0]])
    TargetVar = T.dmatrix('Targets')
    #TargetVar.tag.test_value = numpy.random.randint(100,size=(100,1))


    print('\nBuilding the Model ... \n')
    model = build_MLP_model(NNInput)


    early_stop   = keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=NNInput.ImpThold, patience=NNInput.NPatience, restore_best_weights=True, verbose=1)

    WeightsPath  = NNInput.CheckpointFldr + '/weights.csv'
    mc_callback  = keras.callbacks.ModelCheckpoint(filepath=NNInput.CheckpointFilePath, monitor='val_loss', save_best_only=True, save_weights_only=True, verbose=1)

    lr_callback  = keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.7, patience=500, mode='auto', min_delta=1.e-6, cooldown=0, min_lr=1.e-8, verbose=1)

    tb_callback  = keras.callbacks.TensorBoard(log_dir=NNInput.CheckpointFldr, histogram_freq=100, batch_size=NNInput.NMiniBatch, write_graph=True, write_grads=True, write_images=True, embeddings_freq=0, embeddings_layer_names=None, embeddings_metadata=None, embeddings_data=None)

    callbacksVec = [mc_callback, early_stop, tb_callback]

    ### Training the NN
    print('\nTraining the Model ... \n')
    xTrain = RSetTrain.get_value()
    yTrain = ySetTrain.get_value()
    xValid = RSetValid.get_value()
    yValid = ySetValid.get_value()
    history = model.fit(xTrain, yTrain, shuffle=True, batch_size=NNInput.NMiniBatch, epochs=NNInput.NEpoch, validation_data=(xValid, yValid), verbose=1, callbacks=callbacksVec)

    ### Plotting History
    #plot_history(NNInput, history)

    #ErrorTest = model.evaluate(RSetTest, ySetTest, verbose=1)
    #print("TensorBoard LogDir: ", NNInput.CheckpointFldr)


    model.load_weights(NNInput.CheckpointFilePath)
    jLayer = -1
    for iLayer in [1,3,4,5]:
        jLayer = jLayer+1
        Params = model.get_layer(index=jLayer).get_weights()
        PathToFldr = NNInput.PathToOutputFldr + NNInput.LayersName[iLayer] + '/'
        if not os.path.exists(PathToFldr):
            os.makedirs(PathToFldr)
        PathToFile = PathToFldr + 'Weights.npz'
        numpy.savez(PathToFile, Params[0], Params[1])
        if (NNInput.WriteFinalFlg > 0):
            if (jLayer==0): 
                save_parameters_PIP(PathToFldr, Params[0], Params[1])
            else:
                save_parameters(PathToFldr, Params[0], Params[1])


    yPredOrig   = model.predict(RDataOrig)
    yPredOrig   = InverseTransformation(NNInput, yPredOrig, yDataDiatOrig)
    plot_scatter(NNInput, yPredOrig, yDataOrig)



    ### Evaluating Model for a Particular Data-Set
    if (NNInput.TryNNFlg > 0):
        
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            xSetTry, ySetTry, ySetTryDiat, ySetTryTriat = datasetsTry[i]
            yPredTry = model.predict(xSetTry)
            yPredTry = InverseTransformation(NNInput, yPredTry, ySetTryDiat)
            ### Saving Predicted Output
            #PathToTryLabels = NNInput.PathToOutputFldr + '/yEvaluated.csv'
            #save_labels(PathToTryLabels, 'Generated', yPredTry)
            PathToAbscissaToPlot = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
            xPlot = abscissa_to_plot(PathToAbscissaToPlot)
            #PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestAll.csv.' + str(Ang)
            # ErrorAbs    =  ySetTry - yPredTry
            # ErrorRel    = (ySetTry - yPredTry) / ySetTry
            # AbsErrorAbs = abs(  ySetTry - yPredTry            )
            # AbsErrorRel = abs( (ySetTry - yPredTry) / ySetTry )
            save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry), axis=1))
            #save_to_plot_all(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry, ErrorAbs, ErrorRel, AbsErrorAbs, AbsErrorRel), axis=1))
            
            # ### Plotting Results
            # plot_try_set(NNInput, ySetTry, yPredTry)
    
        error = ySetTry - yPredTry
        plot_error(NNInput, error)




def evaluate_model(NNInput):

    datasets, datasetsTry, G_MEAN, G_SD, RDataOrig, yDataOrig, yDataDiatOrig = load_data(NNInput)

    # if (NNInput.Model=='ModPIP') or (NNInput.Model=='PIP'):
    #     NNInput.NLayers = NNInput.NHid
    #     NNInput.NLayers.insert(0,NNInput.NIn)
    #     NNInput.NLayers.append(NNInput.NOut)

    # InputVar = T.dmatrix('Inputs')
    # Layers   = create_nn(NNInput, InputVar, 1, G_MEAN, G_SD)


    # if (NNInput.TryNNFlg > 0):
    #     i=-1
    #     for Ang in NNInput.AngVector:
    #         i=i+1
    #         RSetTry, GSetTry, ySetTry, ySetTryDiat, ySetTryTriat = datasetsTry[i]
    #         if (NNInput.Model == 'ModPIP') or (NNInput.Model == 'ModPIPPol'):
    #             xSetTry = RSetTry
    #         elif (NNInput.Model == 'PIP'):
    #             xSetTry = GSetTry
    #         NTry                  = xSetTry.get_value(borrow=True).shape[0]
    #         NBatchTry             = NTry // NNInput.NMiniBatch
    #         yPredTry = lasagne.layers.get_output(Layers[-1], inputs=xSetTry) 
    #         PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
    #         yPredTry = T.cast(yPredTry, 'float64')
    #         yPredTry = yPredTry.eval() 
    #         yPredTry = InverseTransformation(NNInput, yPredTry, ySetTryDiat.get_value())
    #         ySetTry  = T.cast(ySetTry, 'float64')
    #         ySetTry  = ySetTry.eval()
    #         ySetTry  = InverseTransformation(NNInput, ySetTry, ySetTryDiat.get_value())
    #         save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((RSetTry.get_value(), ySetTry, yPredTry), axis=1))


    # for iLayer in range(len(NNInput.NLayers)-1):
    #     PathToFldr = NNInput.PathToOutputFldr + Layers[iLayer].name + '/'
    #     if not os.path.exists(PathToFldr):
    #         os.makedirs(PathToFldr)
    #     if (NNInput.Model == 'ModPIP'):
    #         if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
    #             save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
    #         elif (iLayer > 1):
    #             if (NNInput.BiasesFlg):
    #                 save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())
    #             else:
    #                 save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
    #     elif (NNInput.Model == 'ModPIPPol'):
    #         if (iLayer == 0) and (NNInput.BondOrderStr != 'DiatPotFun'):
    #             save_parameters_PIP(PathToFldr, Layers[iLayer].Lambda.get_value(), Layers[iLayer].re.get_value())
    #         elif (iLayer==1):
    #             save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())
    #     elif (NNInput.Model == 'PIP'):
    #         if (NNInput.BiasesFlg):
    #             save_parameters(PathToFldr, Layers[iLayer].W.get_value(), Layers[iLayer].b.get_value())
    #         else:
    #             save_parameters_NoBiases(PathToFldr, Layers[iLayer].W.get_value())


    # compute_cuts(NNInput, NNInput.AnglesCuts, NNInput.RCuts, Layers, G_MEAN, G_SD)



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