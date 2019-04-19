from __future__ import print_function

import numpy
import theano
floatX = theano.config.floatX
import theano.tensor as T
import os
import numpy
import pymc3
import lasagne

from NNInput  import NNInput
from LoadData import load_parameters, load_parameters_NoBiases, load_parameters_PIP
import BondOrder 
import PIP


def create_nn(NNInput, Input, Data, G_MEAN, G_SD):

    print('\n    Neural Network Shape: ', NNInput.NLayers, '\n')

    if (NNInput.GetIniWeightsFlg == 2):

        iLayer=1
        if (NNInput.Model=='ModPIP') or (NNInput.Model=='ModPIPPol'):
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BondOrderStr != 'DiatPotFun'):
                Lambda, re = load_parameters_PIP(PathToFldr)
            else:
                Lambda     = 0.0
                re         = 0.0
            iLayer     = iLayer+1


        if (NNInput.Model=='ModPIP') or (NNInput.Model=='PIP'):

            iLayer     = iLayer+1
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BiasesFlg):
                W1, b1 = load_parameters(PathToFldr)
            else:
                W1 = load_parameters_NoBiases(PathToFldr)
                b1 = None
            iLayer     = iLayer+1
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BiasesFlg):
                W2, b2 = load_parameters(PathToFldr)
            else:
                W2 = load_parameters_NoBiases(PathToFldr)
                b2 = None
            iLayer     = iLayer+1
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BiasesFlg):
                W3, b3 = load_parameters(PathToFldr)
            else:
                W3 = load_parameters_NoBiases(PathToFldr)
                b3 = None
            iLayer     = iLayer+1

        elif (NNInput.Model=='ModPIPPol'):

            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            W          = load_parameters_NoBiases(PathToFldr)
            iLayer     = iLayer+1


    elif (NNInput.GetIniWeightsFlg == 1):

        iLayer=1
        if (NNInput.Model=='ModPIP') or (NNInput.Model=='ModPIPPol'):
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BondOrderStr != 'DiatPotFun'):
                PathToFile = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/Weights.npz'
                print(' Loading Parameters for Layer ', iLayer, ' from File ', PathToFldr)
                with numpy.load(PathToFile) as f:
                    Lambda, re = [f['arr_%d' % i] for i in range(len(f.files))]     
            else:
                Lambda     = 0.0
                re         = 0.0
            iLayer     = iLayer+1


        if (NNInput.Model=='ModPIP') or (NNInput.Model=='PIP'):

            iLayer     = iLayer+1
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BiasesFlg):
                W1, b1 = load_parameters(PathToFldr)
            else:
                W1 = load_parameters_NoBiases(PathToFldr)
                b1 = None
            iLayer     = iLayer+1
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BiasesFlg):
                W2, b2 = load_parameters(PathToFldr)
            else:
                W2 = load_parameters_NoBiases(PathToFldr)
                b2 = None
            iLayer     = iLayer+1
            PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
            if (NNInput.BiasesFlg):
                W3, b3 = load_parameters(PathToFldr)
            else:
                W3 = load_parameters_NoBiases(PathToFldr)
                b3 = None
            iLayer     = iLayer+1

        elif (NNInput.Model=='ModPIPPol'):
            PathToFile = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/Weights.npz'
            print(' Loading Parameters for Layer ', iLayer, ' from File ', PathToFldr)
            with numpy.load(PathToFile) as f:
                W = [f['arr_%d' % i] for i in range(len(f.files))]
                W = numpy.asarray(W[2])


    elif (NNInput.GetIniWeightsFlg == 0):

        iLayer = 0
        if (NNInput.Model=='ModPIP') or (NNInput.Model=='ModPIPPol'):
            #Lambda = lasagne.init.Normal(mean=1.0,std=0.2)
            #re     = lasagne.init.Normal(mean=0.0,std=0.2)
            Lambda = lasagne.init.Constant(val=0.5)
            re     = lasagne.init.Constant(val=2.0)
            iLayer = iLayer+1

        if (NNInput.Model=='ModPIP') or (NNInput.Model=='PIP'):

            iLayer = iLayer+1
            #Range = numpy.sqrt(6.0/(NNInput.NLayers[iLayer]+NNInput.NLayers[iLayer+1]))
            #W1 = lasagne.init.Uniform(range=Range)
            W1 = lasagne.init.GlorotNormal(gain=1.0)
            if (NNInput.BiasesFlg):
                b1 = lasagne.init.Constant(0.0)
            else:
                b1 = None
            iLayer = iLayer+1

            #Range = numpy.sqrt(6.0/(NNInput.NLayers[iLayer]+NNInput.NLayers[iLayer+1]))
            #W2 = lasagne.init.Uniform(range=Range)
            W2 = lasagne.init.GlorotNormal(gain=1.0)
            if (NNInput.BiasesFlg):
                b2 = lasagne.init.Constant(0.0)
            else:
                b2 = None
            iLayer = iLayer+1

            #Range = numpy.sqrt(6.0/(NNInput.NLayers[iLayer]+NNInput.NLayers[iLayer+1]))
            #W3 = lasagne.init.Uniform(range=Range)
            W3 = lasagne.init.GlorotNormal(gain=1.0)
            if (NNInput.BiasesFlg):
                b3 = lasagne.init.Constant(0.0)
            else:
                b3 = None

        elif (NNInput.Model=='ModPIPPol'):   
        
            Range = 10.0
            W = lasagne.init.Constant(val=1.0) #lasagne.init.Uniform(range=Range)     

    # print('G_MEAN = ', G_MEAN)
    # print('G_SD   = ', G_SD)
    # print('Lambda = ', Lambda)
    # print('re     = ', re)
    # print('W1     = ', W1)
    # print('W2     = ', W2)
    # print('W3     = ', W3)
    # print('b1     = ', b1)
    # print('b2     = ', b2)
    # print('b3     = ', b3)

    if (NNInput.Model == 'ModPIP'):
        BondOrder_Layer = getattr(BondOrder,NNInput.BondOrderStr + '_Layer')
        PIP_Layer       = getattr(PIP,NNInput.PIPTypeStr         + '_Layer')

        iLayer=0;        InputL     = lasagne.layers.InputLayer((NNInput.NMiniBatch, NNInput.NLayers[iLayer]),  input_var=Input,                       name=NNInput.LayersName[iLayer])
        iLayer=iLayer+1; BOL        =           BondOrder_Layer(InputL, Lambda=Lambda, re=re,                                                          name=NNInput.LayersName[iLayer])   
        iLayer=iLayer+1; PIPL       =                 PIP_Layer(BOL,    G_MEAN=G_MEAN, G_SD=G_SD,                                                      name=NNInput.LayersName[iLayer])
        iLayer=iLayer+1; HL1        = lasagne.layers.DenseLayer(PIPL,   num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W1, b=b1)
        iLayer=iLayer+1; HL2        = lasagne.layers.DenseLayer(HL1,    num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W2, b=b2)
        iLayer=iLayer+1; OutputL    = lasagne.layers.DenseLayer(HL2,    num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W3, b=b3)
        Layers  = [BOL, PIPL, HL1, HL2, OutputL]
    
    elif(NNInput.Model == 'ModPIPPol'):
        BondOrder_Layer = getattr(BondOrder,NNInput.BondOrderStr + '_Layer')

        iLayer=0;        InputL  = lasagne.layers.InputLayer((NNInput.NMiniBatch, NNInput.NLayers[iLayer]), input_var=Input, name=NNInput.LayersName[iLayer])
        iLayer=iLayer+1; BOL     =           BondOrder_Layer(InputL, Lambda=Lambda, re=re,                                   name=NNInput.LayersName[iLayer])   
        iLayer=iLayer+1; PolL    =          Polynomial_Layer(BOL,    W=W,           NOrd=NNInput.NOrd,                       name=NNInput.LayersName[iLayer])
        Layers  = [BOL, PolL]
    
    elif (NNInput.Model == 'PIP'):
        iLayer=0;        InputL  = lasagne.layers.InputLayer((NNInput.NMiniBatch, NNInput.NLayers[iLayer]),  input_var=Input,                       name=NNInput.LayersName[iLayer])
        iLayer=iLayer+1; HL1     = lasagne.layers.DenseLayer(InputL, num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W1, b=b1)
        iLayer=iLayer+1; HL2     = lasagne.layers.DenseLayer(HL1,    num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W2, b=b2)
        iLayer=iLayer+1; OutputL = lasagne.layers.DenseLayer(HL2,    num_units=NNInput.NLayers[iLayer],      nonlinearity=NNInput.ActFun[iLayer-1], name=NNInput.LayersName[iLayer], W=W3, b=b3)
        Layers  = [HL1, HL2, OutputL]

    return Layers


def iterate_minibatches(inputs, targets, batchsize, shuffle):
    inputs  = inputs.get_value()
    targets = targets.get_value()
    assert len(inputs) == len(targets)
    if shuffle:
        indices = numpy.arange(len(inputs))
        numpy.random.shuffle(indices)
    for StartIdx in range(0, len(inputs) - batchsize + 1, batchsize):
        if shuffle:
            excerpt = indices[StartIdx:StartIdx + batchsize]
        else:
            excerpt = slice(StartIdx, StartIdx + batchsize)
        yield inputs[excerpt], targets[excerpt]



class Polynomial_Layer(lasagne.layers.Layer):

    def __init__(self, incoming, W, NOrd, **kwargs):
        super(Polynomial_Layer, self).__init__(incoming,  **kwargs)
        
        self.IdxVecs = IdxVecs  =  [[1,1,0], 
                                    [1,1,1], [2,1,0], 
                                    [2,1,1], [2,2,0], [3,1,0],        
                                    [2,2,1], [3,1,1], [3,2,0], [4,1,0], 
                                    [2,2,2], [3,2,1], [4,1,1], [3,3,0], [4,2,0], [5,1,0], 
                                    [3,2,2], [3,3,1], [4,2,1], [5,1,1], [4,3,0], [5,2,0], [6,1,0], 
                                    [3,3,2], [4,2,2], [4,3,1], [5,2,1], [6,1,1], [4,4,0], [5,3,0], [6,2,0], [7,1,0],    
                                    [3,3,3], [4,3,2], [4,4,1], [5,2,2], [5,3,1], [6,2,1], [7,1,1], [5,4,0], [6,3,0], [7,2,0], [8,1,0], 
                                    [4,3,3], [4,4,2], [5,3,2], [5,4,1], [6,2,2], [6,3,1], [7,2,1], [8,1,1], [5,5,0], [6,4,0], [7,3,0], [8,2,0], [9,1,0],            
                                    [4,4,3], [5,3,3], [5,4,2], [5,5,1], [6,3,2], [6,4,1], [6,5,0], [7,2,2], [7,3,1], [7,4,0], [8,2,1], [8,3,0], [9,1,1], [9,2,0], [10,1,0], 
                                    [4,4,4], [5,4,3], [5,5,2], [6,4,2], [6,5,1], [6,6,0], [7,3,2], [7,4,1], [7,5,0], [8,2,2], [8,3,1], [8,4,0], [9,2,1], [9,3,0], [10,1,1], [10,2,0], [11,1,0], 
                                    [5,4,4], [6,4,4], [6,5,2], [6,4,2], [6,6,1], [7,3,3], [7,4,2], [7,5,1], [8,3,2], [8,4,1], [8,5,0], [9,2,2], [9,3,1], [9,4,0], [10,2,1], [10,3,0], [11,2,0], [11,1,1], [12,1,0], 
                                    [5,5,4], [6,3,5], [6,4,4], [7,3,4], [7,5,2], [7,6,1], [7,7,0], [8,3,3], [8,4,2], [8,5,1], [8,6,0], [9,3,2], [9,4,1], [9,5,0], [10,2,2], [10,3,1], [10,4,0], [11,2,1], [11,3,0], [12,2,0], [13,1,0],
                                   ] 

        self.PermVecs = [2,
                         6, 1,
                         2, 2, 1,
                         2, 2, 1, 1,
                         6, 1, 2, 2, 1, 1,
                         2, 2, 1, 2, 1, 1, 1,
                         2, 2, 1, 1, 2, 2, 1, 1, 1,
                         6, 1, 2, 2, 1, 1, 2, 1, 1, 1, 1,
                         2, 2, 1, 1, 2, 1, 1, 2, 2, 1, 1, 1, 1,
                         2, 2, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1,
                         6, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1,
                         2, 2, 1, 1, 2, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1,
                         2, 1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1]

        self.NbVecs = numpy.array([1,0,1,2,3,4,6,7,9,11,13,15,17,19,21]) 

        self.NOrd   = NOrd
        print('    Order of Polynomials   = ', self.NOrd)
        NPar        = numpy.sum(self.NbVecs[0:self.NOrd+1])
        print('    Number of Coefficients = ', NPar)
        self.W      = self.add_param(W, (NPar,1), name='W')
        

    def get_output_for(self, incoming, **kwargs):

        Sum  = T.zeros((1,incoming.shape[0]))
        p0   = incoming[:,0]
        p1   = incoming[:,1]
        p2   = incoming[:,2]

        #print('p0    = ', p0.tag.test_value)
        #print('p1    = ', p1.tag.test_value)
        #print('p2    = ', p2.tag.test_value)

        iCum = 0
        for iOrd in range(2, self.NOrd+1):

            for iIdx in range(self.NbVecs[iOrd]):

                IdxVec = self.IdxVecs[iCum]
                Temp   = (p0**IdxVec[0] * p1**IdxVec[1] * p2**IdxVec[2] + 
                          p0**IdxVec[0] * p1**IdxVec[2] * p2**IdxVec[1] + 
                          p0**IdxVec[1] * p1**IdxVec[0] * p2**IdxVec[2] + 
                          p0**IdxVec[1] * p1**IdxVec[2] * p2**IdxVec[0] + 
                          p0**IdxVec[2] * p1**IdxVec[0] * p2**IdxVec[1] + 
                          p0**IdxVec[2] * p1**IdxVec[1] * p2**IdxVec[0]) / self.PermVecs[iCum]
                Sum    = Sum + self.W[iCum,0] * Temp

                #print('W    = ', self.W[iCum,0])
                #print('Temp = ', Temp.tag.test_value)
                #print('Sum  = ', Sum.tag.test_value)
                iCum = iCum + 1

        V = Sum.dimshuffle(1, 0) * 0.159360144e-2*27.2113839712790

        #print('V=',V.tag.test_value)
        V = V - self.W[iCum]
        #print('V=',V.tag.test_value)

        return V

    def get_output_shape_for(self, input_shape):
        return (input_shape[0], input_shape[1])



class Exit_Layer(lasagne.layers.Layer):

    def __init__(self, incoming, Data, **kwargs):
        super(Exit_Layer, self).__init__(incoming,  **kwargs)
        self.Data = Data

    def get_output_for(self, incoming, **kwargs):
        
        yPred =  incoming / self.Data

        return yPred

    def get_output_shape_for(self, input_shape):
        return (input_shape[0], input_shape[1])
