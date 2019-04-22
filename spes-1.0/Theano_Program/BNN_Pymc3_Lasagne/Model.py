from __future__ import print_function

import numpy
import theano
floatX = theano.config.floatX
import theano.tensor as T
import os
import numpy
import pymc3
from pymc3.theanof import set_tt_rng, MRG_RandomStreams
import lasagne

from NNInput  import NNInput
from LoadData import load_parameters, load_parameters_PIP, load_scales
from Plot     import plot_ADVI_convergence
import PIP      
import BondOrder 

def construct_model(NNInput, RSetTrain, ySetTrain, Input, yObs, InitW, Initb):

    with pymc3.Model() as model:

        BondOrder_Layer = getattr(BondOrder,NNInput.BondOrderStr + '_Layer')
        PIP_Layer       = getattr(PIP,NNInput.PIPTypeStr         + '_Layer')


        Lambda = pymc3.Uniform('Lambda', lower=0.0, upper=3.0, shape=(1,1), testval=1.5)
        re     = pymc3.Uniform('re',     lower=0.0, upper=3.0, shape=(1,1), testval=1.5)

        iLayer = 2
        print('\n    1st Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
        WSD     = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1])) 
        if (NNInput.TwoLevelsFlg):
            W1Hyper = pymc3.HalfNormal('W1Hyper', sd=5.0)
        else:
            W1Hyper = 5.0
        W1      = pymc3.Normal('W1', mu=0.0, sd=W1Hyper, testval=numpy.random.normal(loc=0.0, scale=WSD, size=(NNInput.NLayers[iLayer],NNInput.NLayers[iLayer+1])).astype(numpy.float64), shape=(NNInput.NLayers[iLayer],NNInput.NLayers[iLayer+1]))
        b1      = pymc3.Normal('b1', mu=0.0, sd=10.0,    testval=0.0, shape=NNInput.NLayers[iLayer+1])
        iLayer  = iLayer+1

        print('    2nd Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
        WSD     = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
        if (NNInput.TwoLevelsFlg):
            W2Hyper = pymc3.HalfNormal('W2Hyper', sd=5.0)
        else:
            W2Hyper = 5.0
        W2      = pymc3.Normal('W2', mu=0.0, sd=W2Hyper, testval=numpy.random.normal(loc=0.0, scale=WSD, size=(NNInput.NLayers[iLayer],NNInput.NLayers[iLayer+1])).astype(numpy.float64), shape=(NNInput.NLayers[iLayer],NNInput.NLayers[iLayer+1]))
        b2      = pymc3.Normal('b2', mu=0.0, sd=10.0,    testval=0.0, shape=NNInput.NLayers[iLayer+1])
        iLayer  = iLayer+1

        print('    3rd Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
        WSD     = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
        if (NNInput.TwoLevelsFlg):
            W3Hyper = pymc3.HalfNormal('W3Hyper', sd=5.0)
        else:
            W3Hyper = 5.0
        W3      = pymc3.Normal('W3', mu=0.0, sd=W3Hyper, testval=numpy.random.normal(loc=0.0, scale=WSD, size=(NNInput.NLayers[iLayer],NNInput.NLayers[iLayer+1])).astype(numpy.float64), shape=(NNInput.NLayers[iLayer],NNInput.NLayers[iLayer+1]))
        b3      = pymc3.Normal('b3', mu=0.0, sd=10.0,    testval=0.0, shape=NNInput.NLayers[iLayer+1])


        iLayer=0;        InputL     = lasagne.layers.InputLayer((None, NNInput.NLayers[iLayer]),  input_var=Input,                                     name=NNInput.LayersName[iLayer])
        iLayer=iLayer+1; BOL        =           BondOrder_Layer(InputL, Lambda=Lambda, re=re,                                                          name=NNInput.LayersName[iLayer])   
        iLayer=iLayer+1; PIPL       =                 PIP_Layer(BOL,                                                                                   name=NNInput.LayersName[iLayer])
        iLayer=iLayer+1; HL1        = lasagne.layers.DenseLayer(PIPL,   num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W1, b=b1)
        iLayer=iLayer+1; HL2        = lasagne.layers.DenseLayer(HL1,    num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W2, b=b2)
        iLayer=iLayer+1; OutL       = lasagne.layers.DenseLayer(HL2,    num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W3, b=b3)
        Layers = [BOL, PIPL, HL1, HL2, OutL]
        yPred  = lasagne.layers.get_output(OutL)

        # Define likelihood
        #Sigma = pymc3.Lognormal('Sigma', mu=0.01,  sd=2.0, testval=10.0)
        Sigma = pymc3.HalfNormal('Sigma', sd=1.0, testval=1.0)
        yLike = pymc3.Normal('yLike',     mu=yPred, sd=Sigma, observed=numpy.log(yObs))#, total_size=NNInput.NMiniBatch
        

        Params  = {'Lambda':Lambda,'re':re, 'W1':W1,'b1':b1, 'W2':W2,'b2':b2, 'W3':W3,'b3':b3, 'Sigma':Sigma}


        # Inference!
        #ADVIInference = 0
        #ADVITracker   = 0 
        #ADVIApprox    = 0
        ADVIInference = pymc3.ADVI()
        ADVITracker   = pymc3.callbacks.Tracker(mean=ADVIInference.approx.mean.eval, std=ADVIInference.approx.std.eval)
        if (NNInput.NMiniBatch == 0):
            ADVIApprox    = pymc3.fit(n=NNInput.NStepsADVI, method=ADVIInference, callbacks=[pymc3.callbacks.CheckParametersConvergence(diff='absolute'), ADVITracker], obj_optimizer=pymc3.adadelta(learning_rate=1.0, rho=0.95, epsilon=1e-8))
        else:
            ADVIApprox    = pymc3.fit(n=NNInput.NStepsADVI, more_replacements={RSetTrain: Input, ySetTrain: yObs}, method=ADVIInference, callbacks=[pymc3.callbacks.CheckParametersConvergence(diff='absolute'), ADVITracker])
        #ADVIApprox    = pymc3.fit(n=NNInput.NStepsADVI, method=ADVIInference)
        plot_ADVI_convergence(NNInput, ADVITracker, ADVIInference)

        SVGDApprox = 0
        #SVGDApprox = pymc3.fit(300, method='svgd', inf_kwargs=dict(n_particles=1000), obj_optimizer=pymc3.adadelta(learning_rate=1.0, rho=0.95, epsilon=1e-8))
        #plot_SVGD_vs_ADVI(NNInput, ADVIApprox, SVGDApprox)

        NUTSTrace = 0
        #UTSTrace = pymc3.sample(2000, step, start=approx.sample()[0], progressbar=True, njobs=1)
        #NUTSTrace = pymc3.sample(200, tune=1000, njobs=2, progressbar=True)

        #MCMCTrace = pymc3.sample(200000, step=pymc3.Metropolis(), tune=10000)


        #return ADVIApprox, ADVIInference, ADVITracker, SVGDApprox, NUTSTrace, model, yPred, Sigma, Layers
        return ADVIApprox, ADVIInference, SVGDApprox, NUTSTrace, Params, yPred


class GaussWeightsLambda(object):
    def __init__(self):
        self.count = 0
    def __call__(self, shape):
        self.count += 1
        return pymc3.Uniform('Lambda', lower=0.0, upper=2.0, shape=(1,1), testval=1.0)


class GaussWeightsRe(object):
    def __init__(self):
        self.count = 0
    def __call__(self, shape):
        self.count += 1
        return pymc3.Uniform('re',     lower=0.0, upper=1.5, shape=(1,1), testval=1.0)


class GaussWeightsW(object):
    def __init__(self):
        self.count = 0
    def __call__(self, shape):
        self.count += 1
        WSD = numpy.sqrt( 2.0 / (shape[0] + shape[1]) )
        return pymc3.Normal('W%d' % self.count, mu=0.0, sd=WSD,  testval=numpy.random.normal(loc=0.0, scale=WSD, size=shape).astype(numpy.float64), shape=shape)



class GaussWeightsb(object):
    def __init__(self):
        self.count = 0
    def __call__(self, shape):
        self.count += 1
        bSD = 10.0
        return pymc3.Normal('b%d' % self.count, mu=0.0, sd=WSD,  testval=numpy.random.normal(loc=0.0, scale=WSD, size=shape).astype(numpy.float64), shape=shape)


def try_model_PIP(NNInput, R, LambdaVec, reVec, WIni, bIni):

    W1 = WIni[0]
    b1 = bIni[0]
    W2 = WIni[1]
    b2 = bIni[1]
    W3 = WIni[2]
    b3 = bIni[2]

    # print('G_MEAN  = ', G_MEAN)
    # print('G_SD    = ', G_SD)
    # print('Lambda  = ', LambdaVec)
    # print('re      = ', reVec)
    # print('W1      = ', W1)
    # print('W2      = ', W2)
    # print('W3      = ', W3)
    # print('b1      = ', b1)
    # print('b2      = ', b2)
    # print('b3      = ', b3)

    G      = PIP_A3(NNInput, R, LambdaVec, reVec)

    h1     = numpy.tanh(numpy.dot(G,  W1) + b1)
    h2     = numpy.tanh(numpy.dot(h1, W2) + b2)
    output =           (numpy.dot(h2, W3) + b3)

    return output
