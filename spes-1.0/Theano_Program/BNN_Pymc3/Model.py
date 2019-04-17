from __future__ import print_function

import numpy
import theano
floatX = theano.config.floatX
import theano.tensor as T
import os
import numpy
import pymc3
from pymc3.theanof import set_tt_rng, MRG_RandomStreams

from NNInput  import NNInput
from LoadData import load_parameters, load_parameters_PIP, load_scales
from PIP      import PIP_A3, PIP_A2B

def construct_model(NNInput, R, y, G_MEAN, G_SD):


    if (NNInput.Model == 'PIP') or (NNInput.Model == 'ModPIP'):

        if (NNInput.ReadIniParamsFlg):
            # Read Initial paramaters

            iLayer=1
            if (NNInput.Model=='ModPIP'):
                PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
                LambdaIni, reIni = load_parameters_PIP(PathToFldr)

            WIni  = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[0] for iLayer in range(2,len(NNInput.LayersName))]
            bIni  = [ load_parameters(NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/')[1] for iLayer in range(2,len(NNInput.LayersName))]
            W1Ini = WIni[0]
            b1Ini = bIni[0]
            W2Ini = WIni[1]
            b2Ini = bIni[1]
            W3Ini = WIni[2]
            b3Ini = bIni[2]

            LambdaMean = LambdaIni
            reMean     = reIni
            W1Mean     = W1Ini
            b1Mean     = b1Ini
            W2Mean     = W2Ini
            b2Mean     = b2Ini
            W3Mean     = W3Ini
            b3Mean     = b3Ini

        else:
            
            iLayer = 0
            if (NNInput.Model == 'ModPIP'):
                # LambdaIni = numpy.random.uniform(low=0.5,  high=2.5, size=(1,1)).astype(floatX)
                # reIni     = numpy.random.uniform(low=-1.0, high=1.0, size=(1,1)).astype(floatX)
                LambdaIni = 1.0
                reIni     = 1.0
                iLayer    = iLayer+2

            elif (NNInput.Model == 'PIP'):
                LambdaIni = NNInput.LambdaVec
                reIni     = NNInput.reVec


            print('    1st Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
            WSD    = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
            W1Ini  = numpy.random.normal(loc=0.0, scale=WSD, size=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]) )
            b1Ini  = numpy.zeros(NNInput.NLayers[iLayer+1])
            iLayer = iLayer+1

            print('    2nd Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
            WSD    = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
            W2Ini  = numpy.random.normal(loc=0.0, scale=WSD, size=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]) )
            b2Ini  = numpy.zeros(NNInput.NLayers[iLayer+1])
            iLayer = iLayer+1

            print('    3rd Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
            WSD    = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
            W3Ini  = numpy.random.normal(loc=0.0, scale=WSD, size=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]) )
            b3Ini  = numpy.zeros(NNInput.NLayers[iLayer+1])

            LambdaMean = 1.0
            reMean     = 1.0
            W1Mean     = 0.0
            b1Mean     = 0.0
            W2Mean     = 0.0
            b2Mean     = 0.0
            W3Mean     = 0.0
            b3Mean     = 0.0


        # print('G_MEAN=',G_MEAN)
        # print('G_SD=',G_SD)
        # print('LambdaMean=',LambdaMean)
        # print('reMean=',reMean)
        # print('W1Mean=',W1Mean)
        # print('W2Mean=',W2Mean)
        # print('W3Mean=',W3Mean)
        # print('b1Mean=',b1Mean)
        # print('b2Mean=',b2Mean)
        # print('b3Mean=',b3Mean)

        # print('G_MEAN=',G_MEAN)
        # print('G_SD=',G_SD)
        # print('LambdaIni=',LambdaIni)
        # print('reIni=',reIni)
        # print('W1Ini=',W1Ini)
        # print('W2Ini=',W2Ini)
        # print('W3Ini=',W3Ini)
        # print('b1Ini=',b1Ini)
        # print('b2Ini=',b2Ini)
        # print('b3Ini=',b3Ini)

    elif (NNInput.Model == 'LEPS'):

        Dei   = 9.9044
        betai = 1.4223
        rei   = 2.0743
        ki    = -0.023 
        eps   = 1e-30


    with pymc3.Model() as model: # model specifications in PyMC3 are wrapped in a with-statement
            
        NData = R.shape[0]

        if (NNInput.Model == 'ModPIP') or (NNInput.Model == 'PIP'):

            iLayer = 0
            if (NNInput.Model == 'ModPIP'):
                iLayer = iLayer+2

            # LambdaPar = pymc3.Normal('Lambda',     mu=LambdaMean, sd=LambdaSD, shape=(1,1), testval=LambdaIni)
            # rePar     = pymc3.Normal('re',         mu=reMean,     sd=reSD,     shape=(1,1), testval=reIni)
            LambdaPar = pymc3.Uniform('Lambda', lower=0.0, upper=2.0, shape=(1,1), testval=1.0)
            rePar     = pymc3.Uniform('re',     lower=0.0, upper=1.5, shape=(1,1), testval=0.1)

            p0 = pymc3.math.exp( - LambdaPar * (R[:,0] - rePar))
            p1 = pymc3.math.exp( - LambdaPar * (R[:,1] - rePar))
            p2 = pymc3.math.exp( - LambdaPar * (R[:,2] - rePar))

            G0 = (p0*p1 + p1*p2 + p0*p2                                                             - G_MEAN[0]) / G_SD[0]
            G1 = (p0*p1*p2                                                                          - G_MEAN[1]) / G_SD[1]
            G2 = (p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2    - G_MEAN[2]) / G_SD[2]
            G3 = (p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3    - G_MEAN[3]) / G_SD[3]
            G4 = (p0**2*p1*p2 + p0*p1**2*p2 + p2**2*p1*p0 + p2*p1**2*p0 + p0**2*p2*p1 + p0*p2**2*p1 - G_MEAN[4]) / G_SD[4]
            G5 = (p0**2*p1**2 + p0**2*p1**2 + p2**2*p1**2 + p2**2*p1**2 + p0**2*p2**2 + p0**2*p2**2 - G_MEAN[5]) / G_SD[5]

            G0 = G0.dimshuffle((0, 1)) 
            G1 = G1.dimshuffle((0, 1)) 
            G2 = G2.dimshuffle((0, 1))
            G3 = G3.dimshuffle((0, 1))
            G4 = G4.dimshuffle((0, 1))
            G5 = G5.dimshuffle((0, 1))

            #G  = pymc3.math.concatenate( [pymc3.math.concatenate([G0,G1], axis=0), G2], axis=0).T
            G  = pymc3.math.concatenate( [pymc3.math.concatenate( [pymc3.math.concatenate( [pymc3.math.concatenate( [pymc3.math.concatenate([G0,G1], axis=0), G2], axis=0), G3], axis=0), G4], axis=0), G5] ).T

            
            print('    1st Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
            WSD = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
            bSD = 10.e0
            W1 = pymc3.Normal('W1', mu=W1Mean, sd=WSD, shape=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]), testval=W1Ini)
            b1 = pymc3.Normal('b1', mu=b1Mean, sd=bSD, shape=(NNInput.NLayers[iLayer+1]),                          testval=b1Ini)
            #W1 = pymc3.Uniform('W1', lower=-3.0, upper=3.0, shape=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]), testval=W1Ini)
            #b1 = pymc3.Uniform('b1', lower=-3.0, upper=3.0, shape=(NNInput.NLayers[iLayer+1]),                          testval=b1Ini)
            iLayer = iLayer+1

            print('    2nd Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
            WSD = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
            bSD = 10.e0
            W2 = pymc3.Normal('W2', mu=W2Mean, sd=WSD, shape=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]), testval=W2Ini)
            b2 = pymc3.Normal('b2', mu=b2Mean, sd=bSD, shape=(NNInput.NLayers[iLayer+1]),                          testval=b2Ini)
            #W2 = pymc3.Uniform('W2', lower=-3.0, upper=3.0, shape=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]), testval=W2Ini)
            #b2 = pymc3.Uniform('b2', lower=-3.0, upper=3.0, shape=(NNInput.NLayers[iLayer+1]),                          testval=b2Ini)
            iLayer = iLayer+1

            print('    3rd Layer of NN; size = ', NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1])
            WSD = numpy.sqrt(2.0 / (NNInput.NLayers[iLayer] + NNInput.NLayers[iLayer+1]))
            bSD = 10.e0
            W3 = pymc3.Normal('W3', mu=W3Mean, sd=WSD, shape=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]), testval=W3Ini)
            b3 = pymc3.Normal('b3', mu=b3Mean, sd=bSD, shape=(NNInput.NLayers[iLayer+1]),                          testval=b3Ini)
            #W3 = pymc3.Uniform('W3', lower=-3.0,  upper=3.0, shape=(NNInput.NLayers[iLayer], NNInput.NLayers[iLayer+1]), testval=W3Ini)
            #b3 = pymc3.Uniform('b3', lower=-10.0, upper=3.0, shape=(NNInput.NLayers[iLayer+1]),                          testval=b3Ini)

            # Build neural-network 
            h1         = NNInput.ActFun[0](pymc3.math.dot(G,  W1) + b1)
            h2         = NNInput.ActFun[1](pymc3.math.dot(h1, W2) + b2)
            yPred      =                  (pymc3.math.dot(h2, W3) + b3)


        elif (NNInput.Model == 'LEPS'):

            ### Define priors
            De   = pymc3.Uniform('De',     lower=0.0,   upper=20.0,   shape=(1,1))
            beta = pymc3.Uniform('beta',   lower=-2.0,  upper=2.0,    shape=(1,1))
            re   = pymc3.Uniform('re',     lower=-2.5,  upper=2.5,    shape=(1,1))
            k    = pymc3.Uniform('k',      lower=-0.5,  upper=+0.5,   shape=(1,1))
            b    = pymc3.Uniform('b',      lower=-20.0, upper=+20.0,  shape=(1,1))


            # Build neural-network using tanh activation function
            EBond  = De     * ( pymc3.math.exp(-2.0 * beta * (R - re)) - 2.0 * pymc3.math.exp(-beta * (R - re)) )
            EAnti  = De/2.0 * ( pymc3.math.exp(-2.0 * beta * (R - re)) + 2.0 * pymc3.math.exp(-beta * (R - re)) )

            Q      = (EBond * (1.0 + k) + EAnti * (1.0 - k)) / 2.0
            Alpha  = (EBond * (1.0 + k) - EAnti * (1.0 - k)) / 2.0

            y1     = pymc3.math.sqrt(eps + 0.5 * (pymc3.math.sqr(Alpha[:,0] - Alpha[:,1]) + pymc3.math.sqr(Alpha[:,1] - Alpha[:,2]) + pymc3.math.sqr(Alpha[:,2] - Alpha[:,0])))
            #  # 
            yPred  = (Q[:,0] +  Q[:,1] +  Q[:,2] - y1) / (1.0 + k) 
            #yPred  = (- y1) / (1.0 + k) 

            #yPred = yPred.reshape((NNInput.yPredLength,1))
            yPred = yPred.T + b


        # Define likelihood
        #yLikeApprox = pymc3.StudentT('yLikeApprox', mu=b + W * x, lam=1, nu=1, observed=y, total_size=y.eval().shape[0])
        yNorm = yPred / T.abs_(y)**NNInput.OutputExpon
        yObs  =     y / T.abs_(y)**NNInput.OutputExpon
        Sigma = pymc3.Lognormal('Sigma', mu=0.01,  sd=2.0,   testval=10.0)
        yLike = pymc3.Normal('yLike',    mu=yNorm, sd=Sigma, observed=yObs, total_size=NNInput.NTrain)
        
        # Inference!
        #trace  = pymc3.sample(3000) # , cores=2 draw 3000 posterior samples using NUTS sampling
        set_tt_rng(MRG_RandomStreams(42))
        ADVIInference = 0
        ADVITracker   = 0 
        #ADVIApprox    = 0
        ADVIInference = pymc3.ADVI()
        ADVITracker   = pymc3.callbacks.Tracker(mean=ADVIInference.approx.mean.eval, std=ADVIInference.approx.std.eval)
        ##ADVIApprox    = pymc3.fit(n=NNInput.NStepsADVI, method=ADVIInference, callbacks=[pymc3.callbacks.CheckParametersConvergence(diff='absolute'), ADVITracker])
        ADVIApprox    = pymc3.fit(n=NNInput.NStepsADVI, method=ADVIInference, callbacks=[pymc3.callbacks.CheckParametersConvergence(diff='absolute'), ADVITracker], obj_optimizer=pymc3.adadelta(learning_rate=1.0, rho=0.95, epsilon=1e-8))

        SVGDApprox = 0
        #SVGDApprox = pymc3.fit(300, method='svgd', inf_kwargs=dict(n_particles=100), obj_optimizer=pymc3.adadelta(learning_rate=1.0, rho=0.95, epsilon=1e-6))
        #ADVIApprox = SVGDApprox 

        NUTSTrace = 0
        #step      = pymc3.NUTS(scaling=approx.cov.eval(), is_cov=True)
        #NUTSTrace = pymc3.sample(2000, step, start=approx.sample()[0], progressbar=True, njobs=1)
        #NUTSTrace = pymc3.sample(2000, tune=1000, njobs=2, start=approx.sample()[0], progressbar=True)

        return ADVIApprox, ADVIInference, ADVITracker, SVGDApprox, NUTSTrace, model, yLike, yPred


def try_model_PIP(NNInput, R, LambdaVec, reVec, WIni, bIni, G_MEAN, G_SD):

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

    G      = PIP_A3(NNInput, R, LambdaVec, reVec, G_MEAN, G_SD)

    h1     = numpy.tanh(numpy.dot(G,  W1) + b1)
    h2     = numpy.tanh(numpy.dot(h1, W2) + b2)
    output =           (numpy.dot(h2, W3) + b3)

    return output


def try_model_LEPS(NNInput, x, Dei, betai, rei, ki):

    De   = Dei
    beta = betai
    re   = rei
    k    = ki
    
    # Build neural-network using tanh activation function
    EBond  = De     * ( numpy.exp(-2.0 * beta * (x - re)) - 2.0 * numpy.exp(-beta * (x - re)) )
    EAnti  = De/2.0 * ( numpy.exp(-2.0 * beta * (x - re)) + 2.0 * numpy.exp(-beta * (x - re)) )

    Q      = (EBond * (1.0 + k) + EAnti * (1.0 - k)) / 2.0
    Alpha  = (EBond * (1.0 + k) - EAnti * (1.0 - k)) / 2.0
         
    output = ( Q[:,0] +  Q[:,1] +  Q[:,2] - ( ( (Alpha[:,0] - Alpha[:,1])**2.0 + (Alpha[:,1] - Alpha[:,2])**2.0 + (Alpha[:,2] - Alpha[:,0])**2.0) / 2.0)**(0.5) ) / (1.0 + k)

    return output
