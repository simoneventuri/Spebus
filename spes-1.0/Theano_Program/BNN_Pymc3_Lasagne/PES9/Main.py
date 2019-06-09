import numpy
import theano
import theano.tensor as T
floatX = theano.config.floatX
import timeit
import os
import sys
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import pymc3
from pymc3.theanof import set_tt_rng, MRG_RandomStreams
from pymc3.variational.callbacks import CheckParametersConvergence
import pickle # python3
import time

from NNInput          import NNInput
from LoadData         import load_data, abscissa_to_plot, load_parameters, load_parameters_PIP, load_scales
from SaveData         import save_labels, save_ADVI_reconstruction_PIP, save_ADVI_reconstruction_LEPS, save_to_plot, save_moments, save_ADVI_sample_PIP
from Model            import construct_model, GaussWeightsW, GaussWeightsb, try_model_PIP
from Plot             import plot_ADVI_ELBO, plot_ADVI_trace, plot_ADVI_posterior, plot_ADVI_convergence, plot_SVGD_vs_ADVI, plot_ADVI_reconstruction
from TransformOutput  import InverseTransformation

#theano.config.optimizer           = 'fast_compile'
# theano.config.exception_verbosity = 'high'
# theano.config.compute_test_value  = 'warn'
#THEANO_FLAGS=mode=DEBUG_MODE python3 Main.py


def sgd_optimization(NNInput):

    RandomSeed    = 42
    set_tt_rng(MRG_RandomStreams(RandomSeed))

    NSigmaSamples = 1000
    SigmaIntCoeff = 2


    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg):
        datasets, datasetsPlot, RDataOrig, yDataOrig, yDataDiatOrig = load_data(NNInput)
    else:
        datasets, RDataOrig, yDataOrig, yDataDiatOrig               = load_data(NNInput)

    RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat = datasets[0]
    RSetPlot, ySetPlot, ySetPlotDiat, ySetPlotTriat     = datasetsPlot[0]
    RSetPlotTemp = RSetPlot
    #NNInput.NIn  = xSetTrain.get_value(borrow=True).shape[1]
    NNInput.NOut = ySetTrain.get_value(borrow=True).shape[1] 
    print(('    Nb of Input:  %i')    % NNInput.NIn)
    print(('    Nb of Output: %i \n') % NNInput.NOut)
    NNInput.NLayers = NNInput.NHid
    NNInput.NLayers.insert(0,NNInput.NIn)
    NNInput.NLayers.append(NNInput.NOut)

    NNInput.NTrain = RSetTrain.get_value(borrow=True).shape[0]
    print(('    Nb of Training   Examples: %i')    % NNInput.NTrain)

    # compute number of minibatches for training, validation and testing
    if (NNInput.NMiniBatch != 0): 
        NNInput.NBatchTrain = NNInput.NTrain // NNInput.NMiniBatch
        print(('    Nb of Training   Batches: %i') % NNInput.NBatchTrain)
    else:
        print('    No-BATCH Version')


    ##############################################################################################
    ### TESTING REAL PARAMETERS ##################################################################
    if (NNInput.ReadIniParamsFlg):
        if (NNInput.Model == 'PIP'):
            LambdaVec  = NNInput.LambdaVec
            reVec      = NNInput.reVec
            WIni       = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[0] for iLayer in range(1,len(NNInput.LayersName))]
            bIni       = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[1] for iLayer in range(1,len(NNInput.LayersName))]
        if (NNInput.Model == 'ModPIP'):
            LambdaIni = load_parameters_PIP(NNInput.PathToWeightFldr + NNInput.LayersName[1] + '/')[0]
            reIni     = load_parameters_PIP(NNInput.PathToWeightFldr + NNInput.LayersName[1] + '/')[1]
            LambdaVec  = numpy.array([1.0, 1.0, 1.0]) * LambdaIni
            reVec      = numpy.array([1.0, 1.0, 1.0]) * reIni
            #print('Lambda = ', LambdaVec)
            #print('re     = ', reVec)
            WIni       = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[0] for iLayer in range(3,len(NNInput.LayersName))]
            bIni       = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[1] for iLayer in range(3,len(NNInput.LayersName))]
        elif (NNInput.Model == 'LEPS'):
            DeVec   = NNInput.DeVec 
            betaVec = NNInput.betaVec 
            reVec   = NNInput.reVec
            k       = NNInput.k
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            RSetPlot,  ySetPlot, ySetPlotDiat, ySetPlotTriat  = datasetsPlot[i]
            if (NNInput.Model == 'PIP') or (NNInput.Model == 'ModPIP'):
                yPredInitial       = try_model_PIP(NNInput, RSetPlot.get_value(borrow=True), LambdaVec, reVec, WIni, bIni)
            elif (NNInput.Model == 'LEPS'):
                yPredInitial       = try_model_LEPS(NNInput, RSetPlot.get_value(borrow=True), DeiVec, betaiVec, reiVec, ki)
            yPredInitial = InverseTransformation(NNInput, yPredInitial, ySetPlotDiat.get_value())
            PathToPlotLabels = NNInput.PathToOutputFldr + '/REInitial.csv.' + str(int(numpy.floor(Ang)))
            ySetPlot = T.cast(ySetPlot, 'float64')
            ySetPlot = ySetPlot.eval()
            ySetPlot = InverseTransformation(NNInput, ySetPlot, ySetPlotDiat.get_value())
            save_to_plot(PathToPlotLabels, 'Initial', numpy.column_stack([RSetPlot.get_value(), ySetPlot, yPredInitial]))
            print('    Initial Evaluation Saved in File: ', PathToPlotLabels, '\n')
        RSetPlotTemp = RSetPlot        
    ##############################################################################################


    ##################################################################################################################################
    # BUILD ACTUAL MODEL #
    ##################################################################################################################################    
    ### COMPUTING / UPDATING INFERENCE ######################################################################
    # print(RSetTrain.get_value())
    # print(ySetTrain.get_value())
    # time.sleep(5)
    if (NNInput.TrainFlg):
        if (NNInput.NMiniBatch > 0):
            RSetTrainTemp  = pymc3.Minibatch(RSetTrain.get_value(), batch_size=NNInput.NMiniBatch, dtype='float64')
            ySetTrainTemp  = pymc3.Minibatch(ySetTrain.get_value(), batch_size=NNInput.NMiniBatch, dtype='float64')
        else:
            RSetTrainTemp      = RSetTrain
            ySetTrainTemp      = ySetTrain
            NNInput.NMiniBatch = NNInput.NTrain
        #ADVIApprox, ADVIInference, ADVITracker, SVGDApprox, NUTSTrace, model, yPred, Sigma, Layers = construct_model(NNInput, RSetTrainTemp, ySetTrainTemp, GaussWeightsW, GaussWeightsb)
        ADVIApprox, ADVIInference, SVGDApprox, NUTSTrace, Params, yPred = construct_model(NNInput, RSetTrain, ySetTrain, RSetTrainTemp, ySetTrainTemp, GaussWeightsW, GaussWeightsb)
        #
        plot_ADVI_ELBO(NNInput, ADVIInference)
        #
        if (NNInput.SaveInference):
            PathToModTrace = NNInput.PathToOutputFldr + '/Approx&Preds.pkl'
            with open(PathToModTrace, 'wb') as buff:
                #pickle.dump({'model': model, 'trace': ADVITrace, 'tracker': ADVITracker, 'inference': ADVIInference, 'approx': ADVIApprox, 'yLike': yLike}, buff)
                pickle.dump({'ADVIApprox': ADVIApprox, 'Params': Params, 'yPred': yPred}, buff)
        #
    else:
        PathToWeightFldr = NNInput.PathToOutputFldr + '/Model&Trace.pkl'
        with open(PathToWeightFldr, 'rb') as buff:
            data = pickle.load(buff)  
        #model, ADVITrace, ADVITracker, ADVIInference, ADVIApprox, yPred = data['model'], data['trace'], data['tracker'], data['inference'], data['approx'], data['yPred']
        ADVIApprox, Params, yPred = data['ADVIApprox'], data['Params'], data['yPred']
        RSetPlot, ySetPlot, ySetPlotDiat, ySetPlotTriat  = datasetsPlot[0]
        RSetPlotTemp = RSetPlot
   
    if (NNInput.NTraceADVI > 0):
        ADVITrace = ADVIApprox.sample(draws=NNInput.NTraceADVI)      
        plot_ADVI_trace(NNInput, ADVITrace)
    else:
        ADVITrace = 1
    ##############################################################################################


    ### SAMPLING PARAMETERS POSTERIOR #######################################################################
    PathToADVI = NNInput.PathToOutputFldr + '/ParamsPosts/'
    if not os.path.exists(PathToADVI):
        os.makedirs(PathToADVI)

    if (NNInput.Model == 'PIP') or (NNInput.Model == 'ModPIP'):
        save_ADVI_reconstruction_PIP(NNInput, PathToADVI, ADVIApprox, Params)
        save_ADVI_sample_PIP(NNInput, PathToADVI, ADVIApprox, Params)
    elif (NNInput.Model == 'LEPS'):
        save_ADVI_reconstruction_LEPS(PathToADVI, ADVIApprox, Params)
    ##############################################################################################


    ### RECONSTRUCTING MOMENTS ###################################################################
    #means = ADVIApprox.bij.rmap(ADVIApprox.mean.eval())
    #sds   = ADVIApprox.bij.rmap(ADVIApprox.std.eval())
    #plot_ADVI_reconstruction(NNInput, means, sds)

    # PathToADVI = NNInput.PathToOutputFldr + '/ParamsPosts/'
    # if not os.path.exists(PathToADVI):
    #     os.makedirs(PathToADVI)
    # save_ADVI_reconstruction(PathToADVI, ADVITrace, model, 0.0, 0.0)
    ##############################################################################################


    ### RUNNING NUTS #############################################################################
    # xSetTrainTemp = xSetTrain
    # ySetTrainTemp = ySetTrain

    # fig = plt.figure()
    # pymc3.traceplot(NUTSTrace);
    # plt.show()
    # FigPath = NNInput.PathToOutputFldr + '/NUTSTrace.png'
    # fig.savefig(FigPath)
    # #plt.close()

    # varnames = means.keys()
    # fig, axs = plt.subplots(nrows=len(varnames), figsize=(12, 18))
    # for var, ax in zip(varnames, axs):
    #     mu_arr    = means[var]
    #     sigma_arr = sds[var]
    #     ax.set_title(var)
    #     for i, (mu, sigma) in enumerate(zip(mu_arr.flatten(), sigma_arr.flatten())):
    #         sd3 = (-4*sigma + mu, 4*sigma + mu)
    #         x = numpy.linspace(sd3[0], sd3[1], 300)
    #         y = stats.norm(mu, sigma).pdf(x)
    #         ax.plot(x, y)
    #         if hierarchical_trace[var].ndim > 1:
    #             t = NUTSTrace[var][i]
    #         else:
    #             t = NUTSTrace[var]
    #         sns.distplot(t, kde=False, norm_hist=True, ax=ax) 
    # fig.tight_layout()
    # plt.show()
    # FigPath = NNInput.PathToOutputFldr + '/ADVIDistributionsReconstruction.png'
    # fig.savefig(FigPath)
    # #plt.close()
    ##############################################################################################


    # ## COMPUTING MAX POSTERIOR ##################################################################
    # map_estimate = pymc3.find_MAP(model=model)
    # if (NNInput.Model == 'ModPIP'):
    #    LambdaVec    = map_estimate.get('Lambda')
    #    reVec        = map_estimate.get('re')
    #    WNames       = ['W1', 'W2', 'W3']
    #    WIni         = [ map_estimate.get(WNames[iLayer]) for iLayer in range(len(NNInput.LayersName))]
    #    bNames       = ['b1', 'b2', 'b3']
    #    bIni         = [ map_estimate.get(bNames[iLayer]) for iLayer in range(len(NNInput.LayersName))]
    # elif (NNInput.Model == 'PIP'):
    #    LambdaVec    = NNInput.reVec
    #    reVec        = NNInput.reVec
    #    WNames       = ['W1', 'W2', 'W3']
    #    WIni         = [ map_estimate.get(WNames[iLayer]) for iLayer in range(len(NNInput.LayersName))]
    #    bNames       = ['b1', 'b2', 'b3']
    #    bIni         = [ map_estimate.get(bNames[iLayer]) for iLayer in range(len(NNInput.LayersName))]
    # elif (NNInput.Model == 'LEPS'):
    #    DeVec   = map_estimate.get('De')
    #    betaVec = map_estimate.get('beta')
    #    reVec   = map_estimate.get('re')
    #    k       = map_estimate.get('k')


    # i=-1
    # for Ang in NNInput.AngVector:
    #    i=i+1
    
    #    xSetTry,  ySetTry  = datasetsTry[i]
    
    #    PathToAbscissaToPlot = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
    #    xPlot = abscissa_to_plot(PathToAbscissaToPlot)
    #    if (NNInput.Model == 'PIP') or (NNInput.Model == 'ModPIP'):
    #        yPredMaxPosterior = try_model_PIP(NNInput, xSetTry.get_value(borrow=True), LambdaVec, reVec, WIni, bIni, IniMean, IniStD)
    #    elif (NNInput.Model == 'LEPS'):
    #        yPredMaxPosterior = try_model_LEPS(NNInput, xSetTry.get_value(borrow=True), DeVec, betaVec, reVec, k)
    #    #print(WIni, bIni)
    #    PathToTryLabels = NNInput.PathToOutputFldr + '/REMaxPosterior.' + str(Ang) + '.csv'
    #    save_to_plot(PathToTryLabels, 'Evaluated', numpy.column_stack([xPlot, yPredMaxPosterior]))
    # #############################################################################################


    ### SAMPLING OUTPUT POSTERIOR #######################################################################
    PathToADVI = NNInput.PathToOutputFldr + '/OutputPosts/'
    if not os.path.exists(PathToADVI):
        os.makedirs(PathToADVI)

    x = T.dmatrix('X')
    n = T.iscalar('n')
    x.tag.test_value    = numpy.empty_like(RSetPlotTemp)
    x.tag.test_value    = numpy.random.randint(100,size=(100,3))
    n.tag.test_value    = 100
    _sample_proba_yPred = ADVIApprox.sample_node(yPred, size=n, more_replacements={RSetTrainTemp: x})
    sample_proba_yPred  = theano.function([x, n], _sample_proba_yPred)

    m                       = T.iscalar('m')
    _sample_proba_SigmaPred = ADVIApprox.sample_node(Params.get('Sigma'), size=n*m)
    sample_proba_SigmaPred  = theano.function([n,m], _sample_proba_SigmaPred)
    SigmaPred               = sample_proba_SigmaPred(NNInput.NOutPostSamples, NSigmaSamples)
    SigmaPred               = numpy.reshape(SigmaPred, (NNInput.NOutPostSamples, NSigmaSamples))

    i=-1
    for Ang in NNInput.AngVector:
        numpy.random.seed(RandomSeed)
        pymc3.set_tt_rng(RandomSeed)
        i=i+1 
        RSetPlot, ySetPlot, ySetPlotDiat, ySetPlotTriat = datasetsPlot[i]
        ySetPlot     = T.cast(ySetPlot, 'float64')
        ySetPlot     = ySetPlot.eval()
        #ySetPlot     = InverseTransformation(NNInput, ySetPlot, ySetPlotDiat.get_value())
        yPredPlot   = sample_proba_yPred(RSetPlot.get_value(borrow=True), NNInput.NOutPostSamples)
        yPredSum    = ySetPlot * 0.0
        yPredSumSqr = ySetPlot * 0.0
        for j in range(NNInput.NOutPostSamples):
            yPredTemp   = numpy.array(yPredPlot[j,:])
            yPredTemp   = InverseTransformation(NNInput, yPredTemp, ySetPlotDiat.get_value()) 
            yPredSum    = yPredSum    + yPredTemp
            yPredSumSqr = yPredSumSqr + numpy.square(yPredTemp)
        #
        yMean       = yPredSum / NNInput.NOutPostSamples
        yStD        = numpy.sqrt(yPredSumSqr / NNInput.NOutPostSamples - numpy.square(yMean))
        yPlus       = yMean + SigmaIntCoeff * yStD
        yMinus      = yMean - SigmaIntCoeff * yStD
        PathToPlotLabels = NNInput.PathToOutputFldr + '/OutputPosts/yPred' + str(int(numpy.floor(Ang))) + '.csv'
        save_moments(PathToPlotLabels, 'yPred', numpy.column_stack([RSetPlot.get_value(), ySetPlot, yMean, yStD, yMinus, yPlus]))
        print('    Wrote Sampled yPred for Angle ', Ang, '\n')


    if (NNInput.AddNoiseToPredsFlg):
        i=-1
        for Ang in NNInput.AngVector:
            numpy.random.seed(RandomSeed)
            pymc3.set_tt_rng(RandomSeed)
            i=i+1 
            RSetPlot, ySetPlot, ySetPlotDiat, ySetPlotTriat = datasetsPlot[i]
            ySetPlot     = T.cast(ySetPlot, 'float64')
            ySetPlot     = ySetPlot.eval()
            #ySetPlot     = InverseTransformation(NNInput, ySetPlot, ySetPlotDiat.get_value())
            yPredPlot   = sample_proba_yPred(RSetPlot.get_value(borrow=True), NNInput.NOutPostSamples)
            yPostSum    = ySetPlot * 0.0
            yPostSumSqr = ySetPlot * 0.0
            for j in range(NNInput.NOutPostSamples):
                yPredTemp   = numpy.array(yPredPlot[j,:])
                if (NNInput.AddNoiseToPredsFlg):
                    for k in range(NSigmaSamples):
                        yPostTemp   = InverseTransformation(NNInput, yPostTemp, ySetPlotDiat.get_value()) 
                        SigmaTemp   = SigmaPred[j,k]
                        RandNum     = numpy.random.normal(loc=0.0, scale=SigmaTemp)
                        yPostTemp   = yPredTemp * RandNum
                        yPostSum    = yPostSum    + yPostTemp
                        yPostSumSqr = yPostSumSqr + numpy.square(yPostTemp) 
            #
            yMean       = yPostSum / NNInput.NOutPostSamples
            yStD        = numpy.sqrt(yPostSumSqr / NNInput.NOutPostSamples - numpy.square(yMean))
            yPlus       = yMean + SigmaIntCoeff * yStD
            yMinus      = yMean - SigmaIntCoeff * yStD
            PathToPlotLabels = NNInput.PathToOutputFldr + '/OutputPosts/yPost' + str(int(numpy.floor(Ang))) + '.csv'
            save_moments(PathToPlotLabels, 'yPost', numpy.column_stack([RSetPlot.get_value(), ySetPlot, yMean, yStD, yMinus, yPlus]))
            print('    Wrote Sampled yPost for Angle ', Ang, '\n')

    
    ##############################################################################################

    ### PLOTTING OUTPUT POSTERIOR ################################################################
    # fig = plt.figure(figsize=(7, 5))
    # plt.plot(xSetTrainTemp.get_value(), ySetTrainTemp.get_value(), 'x', label='data')
    # #pymc3.plot_posterior_predictive_glm(hierarchical_trace, samples=100, label='posterior predictive regression lines')
    # plt.plot(xSetTrainTemp.get_value(), yPredMaxPosterior, 'x', label='MaxPosterior')
    # #plt.legend(loc=0);
    # plt.show()
    # FigPath = NNInput.PathToOutputFldr + '/PlotPoints.png'
    # fig.savefig(FigPath)
    #plt.close()
    ##############################################################################################


# def evaluate_model(NNInput):

#     datasets, datasetsPlot = load_data(NNInput)
#     xSetTry,  ySetTry     = datasetsTry
#     NTry                  = xSetTry.get_value(borrow=True).shape[0]
#     NBatchTry             = NTry // NNInput.NMiniBatch
#     print(('    Nb of NTry:  %i')    % NTry)
#     print(('    Nb of NBatchTry: %i \n') % NBatchTry)

#     NNInput.NLayers = NNInput.NHid
#     NNInput.NLayers.insert(0,NNInput.NIn)
#     NNInput.NLayers.append(NNInput.NOut)

#     ### Evaluating Model for a Particular Data-Set
#     model = build_MLP_model(NNInput)
#     model.summary()
#     model.load_weights(NNInput.CheckpointPath)
#     yPredTry = model.predict(xSetTry)

#     ### Saving Predicted Output
#     #PathToTryLabels = NNInput.PathToOutputFldr + '/yEvaluated.csv'
#     #save_labels(PathToTryLabels, 'Generated', yPredTry)
#     PathToAbscissaToPlot = NNInput.PathToDataFldr + '/xToPlot.csv'
#     xPlot = abscissa_to_plot(PathToAbscissaToPlot)
#     PathToTryLabels = NNInput.PathToOutputFldr + '/xyEvaluated.csv'
#     save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, yPredTry), axis=1))


#     ### Plotting Results
#     #plot_try_set(NNInput, ySetTry, yPredTry)
    
#     error = ySetTry - yPredTry
#     #plot_error(NNInput, error)


######################################################################################################################################
### RUNNING
######################################################################################################################################
if __name__ == '__main__':

    if not os.path.exists(NNInput.PathToOutputFldr):
        os.makedirs(NNInput.PathToOutputFldr)

    #if (NNInput.TrainFlg):
    sgd_optimization(NNInput)
    #else:
    #evaluate_model(NNInput)
