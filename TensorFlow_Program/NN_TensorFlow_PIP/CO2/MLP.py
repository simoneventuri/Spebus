from __future__ import absolute_import, division, print_function

import tensorflow as tf
from tensorflow import keras
import numpy
from keras import backend

from NNInput    import NNInput

def build_MLP_model(NNInput):

    def rmsenorm(y_pred, y_true):
        error = backend.mean(backend.sqrt(backend.square((y_pred - y_true+1.e-20) / (y_true+1.e-20))))
        return error

    def rmse(y_true, y_pred):
        return backend.sqrt(backend.mean(backend.square((y_pred - y_true))))

    kW1 = NNInput.kWeightDecay[0]
    kW2 = NNInput.kWeightDecay[1]

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