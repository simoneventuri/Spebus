from __future__ import print_function

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

from NNInput          import NNInput
from LoadData         import load_data, abscissa_to_plot, load_parameters, load_parameters_PIP, load_scales
from SaveData         import save_labels, save_ADVI_reconstruction_PIP, save_ADVI_reconstruction_LEPS, save_to_plot, save_moments, save_ADVI_sample_PIP
from Model            import construct_model, try_model_PIP, try_model_LEPS
from Plot             import plot_ADVI_ELBO, plot_ADVI_trace, plot_ADVI_posterior, plot_ADVI_convergence, plot_SVGD_vs_ADVI, plot_ADVI_reconstruction
from TransformOutput  import InverseTransformation

#theano.config.optimizer           = 'fast_compile'
# theano.config.exception_verbosity = 'high'
# theano.config.compute_test_value  = 'warn'
#THEANO_FLAGS=mode=DEBUG_MODE python3 Main.py


def sgd_optimization(NNInput):

    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg):
        datasets, datasetsTry, RDataOrig, yDataOrig, yDataDiatOrig = load_data(NNInput)
    else:
        datasets  = load_data(NNInput)

    RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat = datasets[0]


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
    NBatchTrain = NNInput.NTrain // NNInput.NMiniBatch
    print(('    Nb of Training   Batches: %i') % NBatchTrain)


    if (NNInput.NormalizedDataFlg):
        PathToScalingValues = NNInput.PathToWeightFldr + '/ScalingValues.csv'
        IniMean, IniStD     = load_scales(PathToScalingValues)
    else:
        IniMean = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        IniStD  = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    print('\n    Scale Values: Mean=', IniMean, '; StDev=', IniStD, '\n')



    ##################################################################################################################################
    # BUILD ACTUAL MODEL #
    ##################################################################################################################################

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
            LambdaVec  = numpy.array([1.0, 1.0, 1.0, 1.0, 1.0, 1.0]) * LambdaIni
            reVec      = numpy.array([1.0, 1.0, 1.0, 1.0, 1.0, 1.0]) * reIni
            #print('Lambda = ', LambdaVec)
            #print('re     = ', reVec)
            WIni       = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[0] for iLayer in range(2,len(NNInput.LayersName))]
            bIni       = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[1] for iLayer in range(2,len(NNInput.LayersName))]
        elif (NNInput.Model == 'LEPS'):
            DeVec   = NNInput.DeVec 
            betaVec = NNInput.betaVec 
            reVec   = NNInput.reVec
            k       = NNInput.k
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            RSetTry,  ySetTry, ySetTryDiat, ySetTryTriat  = datasetsTry[i]
            if (NNInput.Model == 'PIP') or (NNInput.Model == 'ModPIP'):
                yPredInitial       = try_model_PIP(NNInput, RSetTry.get_value(borrow=True), LambdaVec, reVec, WIni, bIni, IniMean, IniStD)
            elif (NNInput.Model == 'LEPS'):
                yPredInitial       = try_model_LEPS(NNInput, RSetTry.get_value(borrow=True), DeiVec, betaiVec, reiVec, ki)
            yPredInitial = InverseTransformation(NNInput, yPredInitial, ySetTryDiat.get_value())
            PathToTryLabels = NNInput.PathToOutputFldr + '/REInitial.csv.' + str(Ang)
            ySetTry = T.cast(ySetTry, 'float64')
            ySetTry = ySetTry.eval()
            ySetTry = InverseTransformation(NNInput, ySetTry, ySetTryDiat.get_value())
            save_to_plot(PathToTryLabels, 'Initial', numpy.column_stack([RSetTry.get_value(), ySetTry, yPredInitial]))
            print('    Initial Evaluation Saved in File: ', PathToTryLabels, '\n')
        RSetTryTemp = RSetTry
    else:
        RSetTry, ySetTry, ySetTryDiat, ySetTryTriat  = datasetsTry[0]
        RSetTryTemp = RSetTry
    ##############################################################################################

    
    ### COMPUTING POSTERIOR ######################################################################

    if (NNInput.TrainFlg):
        RSetTrainTemp  = RSetTrain.get_value()
        ySetTrainTemp  = ySetTrain.get_value()
        RSetTrainTemp  = pymc3.Minibatch(RSetTrainTemp, batch_size=NNInput.NMiniBatch)
        ySetTrainTemp  = pymc3.Minibatch(ySetTrainTemp, batch_size=NNInput.NMiniBatch)
        ADVIApprox, ADVIInference, ADVITracker, SVGDApprox, NUTSTrace, model, yLike, yPred = construct_model(NNInput, RSetTrainTemp, ySetTrainTemp, IniMean, IniStD)
        #plot_ADVI_ELBO(NNInput, ADVIInference)
        #plot_ADVI_posterior(NNInput, ADVIApprox)
        ADVITrace = ADVIApprox.sample(draws=NNInput.NTraceADVI)
        #PathToModTrace = NNInput.PathToOutputFldr + '/Model&Trace.pkl'
        #with open(PathToModTrace, 'wb') as buff:
        #    pickle.dump({'model': model, 'trace': ADVITrace, 'tracker': ADVITracker, 'inference': ADVIInference, 'approx': ADVIApprox, 'yLike': yLike}, buff)
    else:
        PathToWeightFldr = NNInput.PathToOutputFldr + '/Model&Trace.pkl'
        with open(PathToWeightFldr, 'rb') as buff:
            data = pickle.load(buff)  
        model, ADVITrace, ADVITracker, ADVIInference, ADVIApprox, yLike = data['model'], data['trace'], data['tracker'], data['inference'], data['approx'], data['yLike']
        RSetTry, ySetTry, ySetTryDiat, ySetTryTriat  = datasetsTry[0]
        RSetTryTemp = RSetTry


    PathToADVI = NNInput.PathToOutputFldr + '/OutputPosts/'
    if not os.path.exists(PathToADVI):
        os.makedirs(PathToADVI)
    PathToADVI = NNInput.PathToOutputFldr + '/ParamsPosts/'
    if not os.path.exists(PathToADVI):
        os.makedirs(PathToADVI)


    if (NNInput.Model == 'PIP') or (NNInput.Model == 'ModPIP'):
        save_ADVI_reconstruction_PIP(PathToADVI, ADVITrace, model)
        save_ADVI_sample_PIP(PathToADVI, ADVITrace, NNInput.NTraceADVI, NNInput.NParPostSamples, model)
    elif (NNInput.Model == 'LEPS'):
        save_ADVI_reconstruction_LEPS(PathToADVI, ADVITrace, model)


    # plot_ADVI_trace(NNInput, ADVITrace)

    # plot_ADVI_convergence(NNInput, ADVITracker, ADVIInference)

    #plot_SVGD_vs_ADVI(NNInput, ADVIApprox, SVGDApprox)
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


    ### SAMPLING POSTERIOR #######################################################################
    x = T.dmatrix('X')
    n = T.iscalar('n')
    x.tag.test_value = numpy.empty_like(RSetTryTemp)
    x.tag.test_value = numpy.random.randint(100,size=(100,3))
    n.tag.test_value = 100
    #_sample_proba = ADVIApprox.sample_node(yLike.distribution.mean, size=n, more_replacements={xSetTrainTemp : x})
    _sample_proba = ADVIApprox.sample_node(yPred, size=n, more_replacements={RSetTrainTemp : x})
    sample_proba = theano.function([x, n], _sample_proba)

    i=-1
    for Ang in NNInput.AngVector:
        i=i+1   
        RSetTry, ySetTry, ySetTryDiat, ySetTryTriat = datasetsTry[i]
        yPredTry = sample_proba(RSetTry.get_value(borrow=True), NNInput.NOutPostSamples)
        ySetTry  = T.cast(ySetTry, 'float64')
        ySetTry  = ySetTry.eval()
        ySetTry  = InverseTransformation(NNInput, ySetTry, ySetTryDiat.get_value())
        yPredSum    = ySetTry * 0.0
        yPredSumSqr = ySetTry * 0.0
        for j in range(NNInput.NOutPostSamples):
            #PathToTryLabels = NNInput.PathToOutputFldr + '/REPostSamples' + str(Ang) + '.csv.' + str(j+1) 
            #yPredTemp = numpy.array(yPredTry[j,:]) 
            #save_to_plot(PathToTryLabels, 'PostSamples', numpy.column_stack([xPlot, yPredTemp[:,-1]]))
            yPredTemp   = numpy.array(yPredTry[j,:])
            yPredTemp   = InverseTransformation(NNInput, yPredTemp, ySetTryDiat.get_value()) 
            yPredSum    = yPredSum    + yPredTemp
            yPredSumSqr = yPredSumSqr + numpy.square(yPredTemp)
        yMean       = yPredSum / NNInput.NOutPostSamples
        yStD        = numpy.sqrt(yPredSumSqr / NNInput.NOutPostSamples - numpy.square(yMean))
        yPlus       = yMean + 3.0 * yStD
        yMinus      = yMean - 3.0 * yStD
        PathToTryLabels = NNInput.PathToOutputFldr + '/OutputPosts/Post' + str(Ang) + '.csv'
        save_moments(PathToTryLabels, 'yPost', numpy.column_stack([RSetTry.get_value(), ySetTry, yMean, yStD, yMinus, yPlus]))
    print('Wrote Sampled yPost')
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

#     datasets, datasetsTry = load_data(NNInput)
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
