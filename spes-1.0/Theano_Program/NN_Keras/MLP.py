from __future__ import print_function
import os
import numpy

import theano
import theano.tensor as T
floatX = theano.config.floatX
import keras
from keras import layers
from keras import backend as K
from keras import optimizers
from keras import initializers
from keras import losses
#import importlib 
from NNInput  import NNInput
from LoadData import load_parameters, load_parameters_NoBiases, load_parameters_PIP
import BondOrder
import PIP

def build_MLP_model(NNInput):

    def rmsenorm(y_pred, y_true):
        error = K.mean(K.sqrt(K.square((y_pred - y_true+1.e-20) / (y_true+1.e-20))))
        return error

    def RMSE(y_true, y_pred):
        return K.sqrt(K.mean(K.square((y_pred - y_true))))


    class MorseFun_Layer_TEMP(layers.Layer):
        def __init__(self, output_dim, **kwargs):
            self.output_dim = output_dim
            super(MorseFun_Layer_TEMP, self).__init__(**kwargs)
        def build(self, input_shape):
            self.L  = self.add_weight(name='L',  shape=(1,1), initializer=initializers.Constant(value=0.5), trainable=True)
            self.re = self.add_weight(name='re', shape=(1,1), initializer=initializers.Constant(value=2.0), trainable=True)
            # Make sure to call the `build` method at the end
            super(MorseFun_Layer_TEMP, self).build(input_shape)
        def call(self, inputs):
            #p  = tf.math.exp( - self.L[0] * (inputs - self.re[0]) - self.L[1] * (inputs - self.re[1])**2  )
            p  = K.exp( - self.L[0] * (inputs - self.re[0]))
            p0 = p[:,0]
            p1 = p[:,1]
            p2 = p[:,2]
            G0 = p0*p1 + p1*p2 + p0*p2                                                          
            G1 = p0*p1*p2                                                                       
            G2 = p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2 
            G3 = p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3
            G4 = p0**2*p1*p2 + p0*p1**2*p2 + p0*p1*p2**2
            G5 = p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2
            G  = K.stack([G0, G1, G2, G3, G4, G5], axis=1)
            return G
        def compute_output_shape(self, input_shape):
            return (input_shape[0], self.output_dim)
        def get_config(self):
            base_config = super(MorseFun_Layer_TEMP, self).get_config()
            base_config['output_dim'] = self.output_dim
            return base_config
        @classmethod
        def from_config(cls, config):
            return cls(**config)


    # kW1 = NNInput.kWeightDecay[0]
    # kW2 = NNInput.kWeightDecay[1]
    # Layer1 = MorseFun_Layer(NNInput.NLayers[2])
    # Layer2 = layers.Dense(units=NNInput.NLayers[3], activation=NNInput.ActFun[2],  use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # Layer3 = layers.Dense(units=NNInput.NLayers[4], activation=NNInput.ActFun[3],  use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # Layer4 = layers.Dense(units=NNInput.NLayers[5],                                use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # #Layer4 = layers.Dense(units=NNInput.NLayers[5], activation=NNInput.ActFun[4], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # #Layer5 = layers.Dense(units=NNInput.NLayers[6],                               use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # #Layer5 = GaussianNoiseCalib(.1)
    # Layer6 = layers.GaussianNoise(0.001)


    #BondOrder_Layer = getattr(BondOrder,NNInput.BondOrderStr + '_Layer')
    #Layer1          = BondOrder_Layer(NNInput.NLayers[1])

    #PIP_Layer = getattr(PIP,NNInput.PIPTypeStr + '_Layer')
    #Layer2    = PIP_Layer(NNInput.NLayers[2])

    Layer2    = MorseFun_Layer_TEMP(NNInput.NLayers[2])

    kW1 = NNInput.kWeightDecay[0]
    kW2 = NNInput.kWeightDecay[1]
    Layer3 = layers.Dense(units=NNInput.NLayers[3], activation=NNInput.ActFun[2], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros')
    Layer4 = layers.Dense(units=NNInput.NLayers[4], activation=NNInput.ActFun[3], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros')
    Layer5 = layers.Dense(units=NNInput.NLayers[5],                               use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros')

    #model = keras.Sequential([Layer1, Layer2, Layer3, Layer4, Layer5])
    model = keras.Sequential([Layer2, Layer3, Layer4, Layer5])

        
    if (NNInput.Method == 'rmsprop'):
        optimizer = optimizers.RMSprop(lr=NNInput.LearningRate, decay=NNInput.kWeightDecay[0], rho=0.9, epsilon=1e-10)
    if (NNInput.Method == 'adagrad'):
        optimizer = optimizers.Adagrad(lr=NNInput.LearningRate, decay=NNInput.kWeightDecay[0], epsilon=1e-10)
    elif (NNInput.Method == 'adadelta'):
        optimizer = optimizers.AdadeltaOptimizer(NNInput.LearningRate, rho=0.95, epsilon=1e-08, use_locking=False, name='Adadelta')
    elif (NNInput.Method == 'adam'):
        optimizer = optimizers.Adam(lr=NNInput.LearningRate, beta_1=0.9, beta_2=0.999, epsilon=None, amsgrad=False)
    elif (NNInput.Method == 'adamax'):
        optimizer = optimizers.Adamax(lr=NNInput.LearningRate, beta_1=0.9, beta_2=0.999, epsilon=None, decay=0.0)
    elif (NNInput.Method == 'nadam'):
        optimizer = optimizers.Nadam(lr=NNInput.LearningRate, beta_1=0.9, beta_2=0.999, epsilon=None, schedule_decay=0.004)
    elif (NNInput.Method == 'sgd'):
        optimizer = optimizers.SGD(lr=NNInput.LearningRate, momentum=NNInput.kMomentum, decay=NNInput.kWeightDecay[0], nesterov=True)
    

    if (NNInput.LossFunction == 'logcosh'):
        model.compile(loss=losses.logcosh,                        optimizer=optimizer, metrics=[RMSE])    
    elif (NNInput.LossFunction == 'mean_squared_error'):
        model.compile(loss=losses.mean_squared_error,             optimizer=optimizer, metrics=[RMSE])
    elif (NNInput.LossFunction == 'mean_squared_logarithmic_error'):
        model.compile(loss=losses.mean_squared_logarithmic_error, optimizer=optimizer, metrics=[RMSE])
    elif (NNInput.LossFunction == 'mean_absolute_percentage_error'):
        model.compile(loss=losses.mean_absolute_percentage_error, optimizer=optimizer, metrics=[RMSE])


    return model


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



# class Polynomial_Layer(lasagne.layers.Layer):

#     def __init__(self, incoming, W, NOrd, **kwargs):
#         super(Polynomial_Layer, self).__init__(incoming,  **kwargs)
        
#         self.IdxVecs = IdxVecs  =  [[1,1,0], 
#                                     [1,1,1], [2,1,0], 
#                                     [2,1,1], [2,2,0], [3,1,0],        
#                                     [2,2,1], [3,1,1], [3,2,0], [4,1,0], 
#                                     [2,2,2], [3,2,1], [4,1,1], [3,3,0], [4,2,0], [5,1,0], 
#                                     [3,2,2], [3,3,1], [4,2,1], [5,1,1], [4,3,0], [5,2,0], [6,1,0], 
#                                     [3,3,2], [4,2,2], [4,3,1], [5,2,1], [6,1,1], [4,4,0], [5,3,0], [6,2,0], [7,1,0],    
#                                     [3,3,3], [4,3,2], [4,4,1], [5,2,2], [5,3,1], [6,2,1], [7,1,1], [5,4,0], [6,3,0], [7,2,0], [8,1,0], 
#                                     [4,3,3], [4,4,2], [5,3,2], [5,4,1], [6,2,2], [6,3,1], [7,2,1], [8,1,1], [5,5,0], [6,4,0], [7,3,0], [8,2,0], [9,1,0],            
#                                     [4,4,3], [5,3,3], [5,4,2], [5,5,1], [6,3,2], [6,4,1], [6,5,0], [7,2,2], [7,3,1], [7,4,0], [8,2,1], [8,3,0], [9,1,1], [9,2,0], [10,1,0], 
#                                     [4,4,4], [5,4,3], [5,5,2], [6,4,2], [6,5,1], [6,6,0], [7,3,2], [7,4,1], [7,5,0], [8,2,2], [8,3,1], [8,4,0], [9,2,1], [9,3,0], [10,1,1], [10,2,0], [11,1,0], 
#                                     [5,4,4], [6,4,4], [6,5,2], [6,4,2], [6,6,1], [7,3,3], [7,4,2], [7,5,1], [8,3,2], [8,4,1], [8,5,0], [9,2,2], [9,3,1], [9,4,0], [10,2,1], [10,3,0], [11,2,0], [11,1,1], [12,1,0], 
#                                     [5,5,4], [6,3,5], [6,4,4], [7,3,4], [7,5,2], [7,6,1], [7,7,0], [8,3,3], [8,4,2], [8,5,1], [8,6,0], [9,3,2], [9,4,1], [9,5,0], [10,2,2], [10,3,1], [10,4,0], [11,2,1], [11,3,0], [12,2,0], [13,1,0],
#                                    ] 

#         self.PermVecs = [2,
#                          6, 1,
#                          2, 2, 1,
#                          2, 2, 1, 1,
#                          6, 1, 2, 2, 1, 1,
#                          2, 2, 1, 2, 1, 1, 1,
#                          2, 2, 1, 1, 2, 2, 1, 1, 1,
#                          6, 1, 2, 2, 1, 1, 2, 1, 1, 1, 1,
#                          2, 2, 1, 1, 2, 1, 1, 2, 2, 1, 1, 1, 1,
#                          2, 2, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1,
#                          6, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1,
#                          2, 2, 1, 1, 2, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1,
#                          2, 1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1]

#         self.NbVecs = numpy.array([1,0,1,2,3,4,6,7,9,11,13,15,17,19,21]) 

#         self.NOrd   = NOrd
#         print('    Order of Polynomials   = ', self.NOrd)
#         NPar        = numpy.sum(self.NbVecs[0:self.NOrd+1])
#         print('    Number of Coefficients = ', NPar)
#         self.W      = self.add_param(W, (NPar,1), name='W')
        

#     def get_output_for(self, incoming, **kwargs):

#         Sum  = T.zeros((1,incoming.shape[0]))
#         p0   = incoming[:,0]
#         p1   = incoming[:,1]
#         p2   = incoming[:,2]

#         #print('p0    = ', p0.tag.test_value)
#         #print('p1    = ', p1.tag.test_value)
#         #print('p2    = ', p2.tag.test_value)

#         iCum = 0
#         for iOrd in range(2, self.NOrd+1):

#             for iIdx in range(self.NbVecs[iOrd]):

#                 IdxVec = self.IdxVecs[iCum]
#                 Temp   = (p0**IdxVec[0] * p1**IdxVec[1] * p2**IdxVec[2] + 
#                           p0**IdxVec[0] * p1**IdxVec[2] * p2**IdxVec[1] + 
#                           p0**IdxVec[1] * p1**IdxVec[0] * p2**IdxVec[2] + 
#                           p0**IdxVec[1] * p1**IdxVec[2] * p2**IdxVec[0] + 
#                           p0**IdxVec[2] * p1**IdxVec[0] * p2**IdxVec[1] + 
#                           p0**IdxVec[2] * p1**IdxVec[1] * p2**IdxVec[0]) / self.PermVecs[iCum]
#                 Sum    = Sum + self.W[iCum,0] * Temp

#                 #print('W    = ', self.W[iCum,0])
#                 #print('Temp = ', Temp.tag.test_value)
#                 #print('Sum  = ', Sum.tag.test_value)
#                 iCum = iCum + 1

#         V = Sum.dimshuffle(1, 0) * 0.159360144e-2*27.2113839712790

#         #print('V=',V.tag.test_value)
#         V = V - self.W[iCum]
#         #print('V=',V.tag.test_value)

#         return V

#     def get_output_shape_for(self, input_shape):
#         return (input_shape[0], input_shape[1])



# class Exit_Layer(lasagne.layers.Layer):

#     def __init__(self, incoming, Data, **kwargs):
#         super(Exit_Layer, self).__init__(incoming,  **kwargs)
#         self.Data = Data

#     def get_output_for(self, incoming, **kwargs):
        
#         yPred =  incoming / self.Data

#         return yPred

#     def get_output_shape_for(self, input_shape):
#         return (input_shape[0], input_shape[1])
