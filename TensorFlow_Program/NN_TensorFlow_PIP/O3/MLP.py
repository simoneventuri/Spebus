from __future__ import absolute_import, division, print_function

import tensorflow as tf
from tensorflow import keras
import numpy
from keras import backend
#from keras.engine.topology import Layer
from keras.models import Sequential

from NNInput    import NNInput

def build_MLP_model(NNInput):

    # class MyLayer(keras.layers.Layer):

    #     def __init__(self, output_dim, **kwargs):
    #         self.output_dim = output_dim
    #         super(MyLayer, self).__init__(**kwargs)


    #     def build(self, input_shape):

    #         LambdaIni = keras.initializers.Constant(value=1.9)
    #         reIni     = keras.initializers.Constant(value=0.0)

    #         self.Lambda = self.add_weight(name='Lambda', shape=(1,1), initializer='uniform', trainable=True)
    #         self.re     = self.add_weight(name='re',     shape=(1,1), initializer='uniform', trainable=True)

    #         # self.kernel = self.add_weight(name='Lambda', shape(input_shape[1], self.output_dim), initializer='normal', trainable=True)
    #         # self.kernel = self.add_weight(name='re',     shape(input_shape[1], self.output_dim), initializer='normal', trainable=True)
    #         # Be sure to call this at the end
    #         super(MyLayer, self).build(input_shape)

    #     def call(self, x):

    #         p  = backend.exp( - self.Lambda * (x - self.re))
    #         G1 = backend.sum(p, axis=1) / 3.
    #         G2 = ( p[:,0]*p[:,1] + p[:,1]*p[:,2] + p[:,2]*p[:,0]) / 3.0
    #         G3 = backend.prod(p, axis=1)
    #         G  = backend.concatenate([[G1],[G2],[G3]], axis=0)
    #         G  = backend.transpose(G)

    #         # p  = T.exp( - R * self.Lambda)
    #         # G1 = (p[:,0] + p[:,1]) / 2.
    #         # G2 =  p[:,0] * p[:,1]
    #         # G3 =  p[:,2]
    #         # G  = T.concatenate([[G1],[G2],[G3]], axis=0)
    #         # G  = G.T
    #         return G 


    #     def compute_output_shape(self, input_shape):
    #         return (input_shape, self.output_dim)


    def rmsenorm(y_pred, y_true):
        error = backend.mean(backend.sqrt(backend.square((y_pred - y_true+1.e-20) / (y_true+1.e-20))))
        return error


    def rmse(y_true, y_pred):
        return backend.sqrt(backend.mean(backend.square((y_pred - y_true))))

    kW1 = NNInput.kWeightDecay[0]
    kW2 = NNInput.kWeightDecay[1]

    #print((NNInput.NLayers[0])
    #MyLayer.build((NNInput.NLayers[0],NNInput.NLayers[1])
    #MyLayer(output_dim=NNInput.NLayers[0]).build(10)
    #kerasVec = [MyLayer(output_dim=NNInput.NLayers[0])]
    #kerasVec.append(keras.layers.Dense(units=NNInput.NLayers[1], activation=NNInput.ActFun[0], input_shape=(NNInput.NLayers[0],), kernel_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2)))
    kerasVec = [keras.layers.Dense(units=NNInput.NLayers[1], activation=NNInput.ActFun[0], input_shape=(NNInput.NLayers[0],), kernel_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2))] 
    for i in range(len(NNInput.NLayers)-3):
        kerasVec.append(keras.layers.Dense(units=NNInput.NLayers[i+2], activation=NNInput.ActFun[i+1], kernel_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2)))
    i = len(NNInput.NLayers)-1
    kerasVec.append(keras.layers.Dense(units=NNInput.NLayers[i], kernel_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=keras.regularizers.l1_l2(l1=kW1,l2=kW2)))
    model = keras.Sequential(kerasVec)

    if (NNInput.Method == 'rmsprop'):
        optimizer = tf.train.RMSPropOptimizer(NNInput.LearningRate, decay=NNInput.kWeightDecay[0], momentum=NNInput.kMomentum, epsilon=1e-10)
    elif (NNInput.Method == 'adadelta'):
        optimizer = tf.train.AdadeltaOptimizer(NNInput.LearningRate, rho=0.95, epsilon=1e-08, use_locking=False, name='Adadelta')
    elif (NNInput.Method == 'adam'):
        optimizer = tf.train.AdamOptimizer(NNInput.LearningRate, beta1=0.9, beta2=0.999, epsilon=1e-08, use_locking=False, name='Adam')
    elif (NNInput.Method == 'proximal'):
        optimizer = tf.train.ProximalAdagradOptimizer(NNInput.LearningRate, initial_accumulator_value=0.1, l1_regularization_strength=NNInput.kWeightDecay[0], l2_regularization_strength=NNInput.kWeightDecay[1], use_locking=False, name='ProximalAdagrad')
    elif (NNInput.Method == 'nesterov'):
        optimizer = keras.optimizers.SGD(lr=NNInput.LearningRate, momentum=NNInput.kMomentum, decay=NNInput.kWeightDecay[0], nesterov=True)
    
    if (NNInput.LossFunction == 'logcosh'):
        model.compile(loss=NNInput.LossFunction, optimizer=optimizer, metrics=[rmse])
    elif (NNInput.LossFunction == 'rmse'):
        model.compile(loss=rmse, optimizer=optimizer, metrics=[rmse])
    elif (NNInput.LossFunction == 'mse'):
        model.compile(loss='mse', optimizer=optimizer, metrics=[rmse])
    elif (NNInput.LossFunction == 'rmsenorm'):
        model.compile(loss=rmsenorm, optimizer=optimizer, metrics=[rmse])
    return model