from __future__ import print_function

import os
import numpy

import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras import backend as K
from tensorflow.python.ops import array_ops
#import importlib 

from NNInput  import NNInput
from LoadData import load_parameters, load_parameters_NoBiases, load_parameters_PIP
from TransformOutput import InverseTransformationTF
#import BondOrder
#import PIP

def build_MLP_model(NNInput):

    def rmsenorm(y_pred, y_true):
        error = K.mean(K.sqrt(K.square((y_pred - y_true+1.e-20) / (y_true+1.e-20))))
        return error

    def rmseexp(y_pred, y_true):
        y_predTemp = InverseTransformationTF(NNInput, y_pred, y_pred)
        y_trueTemp = InverseTransformationTF(NNInput, y_true, y_true)
        error = K.sqrt(K.mean(K.square((y_predTemp - y_trueTemp))))
        return error

    def rmse(y_true, y_pred):
        return K.sqrt(K.mean(K.square((y_pred - y_true))))


    class MorseFun_Layer(layers.Layer):
        def __init__(self, output_dim, **kwargs):
            self.output_dim = output_dim
            super(MorseFun_Layer, self).__init__(**kwargs)
        def build(self, input_shape):
            self.L  = self.add_weight(name='L',  shape=(1,1), initializer=tf.constant_initializer(0.5), trainable=True)
            self.re = self.add_weight(name='re', shape=(1,1), initializer=tf.constant_initializer(2.0), trainable=True)
            # Make sure to call the `build` method at the end
            super(MorseFun_Layer, self).build(input_shape)
        def call(self, inputs):
            #p  = tf.math.exp( - self.L[0] * (inputs - self.re[0]) - self.L[1] * (inputs - self.re[1])**2  )
            p  = tf.math.exp( - self.L[0] * (inputs - self.re[0]))
            p0 = p[:,0]
            p1 = p[:,1]
            p2 = p[:,2]
            G0 = p0*p1 + p1*p2 + p0*p2                                                          
            G1 = p0*p1*p2                                                                       
            G2 = p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2 
            G3 = p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3
            G4 = p0**2*p1*p2 + p0*p1**2*p2 + p0*p1*p2**2
            G5 = p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2
            G  = tf.stack([G0, G1, G2, G3, G4, G5], axis=1)
            return G
        def compute_output_shape(self, input_shape):
            return (input_shape[0], self.output_dim)
        def get_config(self):
            base_config = super(MorseFun_Layer, self).get_config()
            base_config['output_dim'] = self.output_dim
            return base_config
        @classmethod
        def from_config(cls, config):
            return cls(**config)


    class GaussianNoiseCalib(layers.Layer):
        """Apply additive zero-centered Gaussian noise.
        This is useful to mitigate overfitting
        (you could see it as a form of random data augmentation).
        Gaussian Noise (GS) is a natural choice as corruption process for real valued inputs.
        As it is a regularization layer, it is only active at training time.
        Arguments:
          stddevv: float, standard deviation of the noise distribution.
        Input shape:
          Arbitrary. Use the keyword argument `input_shape`
          (tuple of integers, does not include the samples axis)
          when using this layer as the first layer in a model.
        Output shape:
          Same shape as input.
        """
        def __init__(self, StdDevvIni, **kwargs):
            self.supports_masking = True
            self.StdDevvIni       = StdDevvIni
            super(GaussianNoiseCalib, self).__init__(**kwargs)
        def build(self, input_shape):
            self.stddevv = self.add_weight(name='stddevv', shape=(1,1), initializer=tf.constant_initializer(1.0), trainable=True)
            # Make sure to call the `build` method at the end
            super(GaussianNoiseCalib, self).build(input_shape)
        def call(self, inputs, training=None):
            def noised():
              return inputs * K.exp(K.random_normal(shape=array_ops.shape(inputs), mean=0., stddev=self.stddevv) )
            return K.in_train_phase(noised, inputs, training=training)
        def get_config(self):
            base_config = super(GaussianNoiseCalib, self).get_config()
            base_config['StdDevvIni'] = self.StdDevvIni
            return base_config
        def compute_output_shape(self, input_shape):
            return (input_shape[0], self.output_dim)
        @classmethod
        def from_config(cls, config):
            return cls(**config)


    # kW1 = NNInput.kWeightDecay[0]
    # kW2 = NNInput.kWeightDecay[1]
    # Layer1 = MorseFun_Layer(NNInput.NLayers[2])
    # Layer2 = layers.Dense(units=NNInput.NLayers[3], activation=NNInput.ActFun[2], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # Layer3 = layers.Dense(units=NNInput.NLayers[4], activation=NNInput.ActFun[3], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # Layer4 = layers.Dense(units=NNInput.NLayers[5],                               use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # #Layer4 = layers.Dense(units=NNInput.NLayers[5], activation=NNInput.ActFun[4], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # #Layer5 = layers.Dense(units=NNInput.NLayers[6],                               use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2), bias_regularizer=tf.keras.regularizers.l1_l2(l1=kW1,l2=kW2))
    # #Layer5 = GaussianNoiseCalib(.1)
    # Layer6 = layers.GaussianNoise(0.001)


    kW1 = NNInput.kWeightDecay[0]
    kW2 = NNInput.kWeightDecay[1]
    Layer1 = MorseFun_Layer(NNInput.NLayers[2])
    #Layer2 = layers.Dense(units=NNInput.NLayers[3], activation=NNInput.ActFun[2], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros')
    #Layer3 = layers.Dense(units=NNInput.NLayers[4], activation=NNInput.ActFun[3], use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros')
    #Layer4 = layers.Dense(units=NNInput.NLayers[5],                               use_bias=True, kernel_initializer='glorot_normal', bias_initializer='zeros')
    WSD          = numpy.sqrt(2.0 / (NNInput.NLayers[3] + NNInput.NLayers[2]) ) 
    InitializerW = tf.keras.initializers.RandomNormal(mean=0.0, stddev=WSD, seed=None)
    Layer2 = layers.Dense(units=NNInput.NLayers[3], activation=NNInput.ActFun[2], use_bias=True, kernel_initializer=InitializerW, bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l2(l=1.e-4))
    
    WSD          = numpy.sqrt(2.0 / (NNInput.NLayers[4] + NNInput.NLayers[3]) ) 
    InitializerW = tf.keras.initializers.RandomNormal(mean=0.0, stddev=WSD, seed=None)
    Layer3 = layers.Dense(units=NNInput.NLayers[4], activation=NNInput.ActFun[3], use_bias=True, kernel_initializer=InitializerW, bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l2(l=1.e-4))
    
    WSD          = numpy.sqrt(2.0 / (NNInput.NLayers[5] + NNInput.NLayers[4]) ) 
    InitializerW = tf.keras.initializers.RandomNormal(mean=0.0, stddev=WSD, seed=None)
    Layer4 = layers.Dense(units=NNInput.NLayers[5], use_bias=True, kernel_initializer=InitializerW, bias_initializer='zeros', kernel_regularizer=tf.keras.regularizers.l2(l=1.e-4))
    #Layer6 = layers.GaussianNoise(0.001)

    # RTemp = tf.Variable([[1.0, 2.0, 3.0],[4.0, 5.0, 6.0]])
    # sess  = tf.Session()
    # init  = tf.global_variables_initializer()
    # sess.run(init)
    # print("G = ", sess.run(Layer1(RTemp)))
    # print("y1 = ", sess.run(Layer2(Layer1(RTemp))))
    # print("y2 = ", sess.run(Layer3(Layer2(Layer1(RTemp)))))
    # print("y3 = ", sess.run(Layer4(Layer3(Layer2(Layer1(RTemp))))))
    # sess.close()
    model = tf.keras.Sequential([Layer1, Layer2, Layer3, Layer4])

        
    if (NNInput.Method == 'rmsprop'):
        optimizer = tf.train.RMSPropOptimizer(NNInput.LearningRate, decay=NNInput.kWeightDecay[0], momentum=NNInput.kMomentum, epsilon=1e-10)
    elif (NNInput.Method == 'adadelta'):
        optimizer = tf.train.AdadeltaOptimizer(NNInput.LearningRate, rho=0.95, epsilon=1e-08, use_locking=False, name='Adadelta')
    elif (NNInput.Method == 'adam'):
        optimizer = tf.train.AdamOptimizer(NNInput.LearningRate, beta1=0.9, beta2=0.999, epsilon=1e-08, use_locking=False, name='Adam')
    elif (NNInput.Method == 'proximal'):
        optimizer = tf.train.ProximalAdagradOptimizer(NNInput.LearningRate, initial_accumulator_value=0.1, l1_regularization_strength=NNInput.kWeightDecay[0], l2_regularization_strength=NNInput.kWeightDecay[1], use_locking=False, name='ProximalAdagrad')
    elif (NNInput.Method == 'nesterov'):
        optimizer = tf.keras.optimizers.SGD(lr=NNInput.LearningRate, momentum=NNInput.kMomentum, decay=NNInput.kWeightDecay[0], nesterov=True)
    

    if (NNInput.LossFunction == 'logcosh'):
        model.compile(loss=NNInput.LossFunction, optimizer=optimizer, metrics=[rmse])
    elif (NNInput.LossFunction == 'rmse'):
        model.compile(loss=rmse, optimizer=optimizer, metrics=[rmse])
    elif (NNInput.LossFunction == 'mse'):
        model.compile(loss='mse', optimizer=optimizer, metrics=[rmseexp])
    elif (NNInput.LossFunction == 'rmsenorm'):
        model.compile(loss=rmsenorm, optimizer=optimizer, metrics=[rmse])
    elif (NNInput.LossFunction == 'mean_squared_logarithmic_error'):
        model.compile(loss=tf.keras.losses.mean_squared_logarithmic_error, optimizer=optimizer, metrics=[rmse])
    elif (NNInput.LossFunction == 'mean_absolute_percentage_error'):
        model.compile(loss=tf.keras.losses.mean_absolute_percentage_error, optimizer=optimizer, metrics=[rmse])
    


    return model