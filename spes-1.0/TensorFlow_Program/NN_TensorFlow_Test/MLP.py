from __future__ import absolute_import, division, print_function

import tensorflow as tf
from tensorflow import keras

from NNInputObj import NNInputObj

def build_MLP_model(NNInput):
    model = keras.Sequential([
        keras.layers.Dense(NNInput.NHid[0], activation=NNInput.ActFun[0], input_shape=(NNInput.NIn,)),
        keras.layers.Dense(NNInput.NHid[1], activation=NNInput.ActFun[1]),
        keras.layers.Dense(NNInput.NOut)
    ])

    optimizer = tf.train.RMSPropOptimizer(NNInput.LearningRate, decay=NNInput.kWeightDecay[0], momentum=NNInput.kMomentum, epsilon=1e-10)

    model.compile(loss='mse', optimizer=optimizer, metrics=['mae'])
    return model