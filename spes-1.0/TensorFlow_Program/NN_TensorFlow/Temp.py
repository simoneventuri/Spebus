from __future__ import absolute_import, division, print_function

import os
import numpy
import tensorflow as tf
print(tf.__version__)
from tensorflow import keras as keras
from tensorflow.keras import layers
from tensorflow.keras import backend as K

from NNInput         import NNInput
from LoadData        import load_data, abscissa_to_plot, load_parameters, load_parameters_PIP


if (NNInput.TryNNFlg > 0):
    datasets, datasetsTry = load_data(NNInput)
else:
    datasets = load_data(NNInput)

RSetTrainValid, ySetTrainValid, ySetTrainValidDiat, ySetTrainValidTriat = datasets[0]
RSetTest,  ySetTest,  ySetTestDiat,  ySetTestTriat                      = datasets[1]


NNInput.NIn  = RSetTrainValid.shape[1]
NNInput.NOut = ySetTrainValid.shape[1] 
print(('  Nb of Input:  %i')    % NNInput.NIn)
print(('  Nb of Output: %i \n') % NNInput.NOut)

NNInput.NLayers = NNInput.NHid
NNInput.NLayers.insert(0,NNInput.NIn)
NNInput.NLayers.append(NNInput.NOut)
print('  Network Shape: ', NNInput.NLayers, '\n')

NTrainValid = RSetTrainValid.shape[0]
NTest       = RSetTest.shape[0]
print(('  Nb of Training + Validation Examples: %i')    % NTrainValid)
print(('  Nb of Test                  Examples: %i \n') % NTest)

NBatchTrainValid = NTrainValid // NNInput.NMiniBatch
print(('  Nb of Training + Validation Batches: %i') % NBatchTrainValid)



class MorseFun_Layer(layers.Layer):
    def __init__(self, output_dim, **kwargs):
        self.output_dim = output_dim
        super(MorseFun_Layer, self).__init__(**kwargs)
    def build(self, input_shape):
        self.Lambdaa = self.add_weight(name='Lambdaa', shape=(1,1), trainable=True, initializer=tf.constant_initializer(1.0), dtype=tf.float32)
        self.ree     = self.add_weight(name='ree',     shape=(1,1), trainable=True, initializer=tf.constant_initializer(1.0), dtype=tf.float32)
        # Make sure to call the `build` method at the end
        super(MorseFun_Layer, self).build(input_shape)
    def call(self, inputs):
        p0 = tf.math.exp( - self.Lambdaa * (inputs[:,0] - self.ree))
        p1 = tf.math.exp( - self.Lambdaa * (inputs[:,1] - self.ree))
        p2 = tf.math.exp( - self.Lambdaa * (inputs[:,2] - self.ree))
        # p  = tf.concat([[p0],[p1],[p2]], axis=0)
        # p  = tf.squeeze(p)
        # p  = tf.transpose(p)
        # return p
        G0 = p0*p1 + p1*p2 + p0*p2                                                          
        G1 = p0*p1*p2                                                                       
        G2 = p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2 
        G3 = p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3
        G4 = p0**2*p1*p2 + p0*p1**2*p2 + p0*p1*p2**2
        G5 = p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2
        #G  = tf.concat([[G0],[G1],[G2]], axis=0)
        G  = tf.concat([[G0],[G1],[G2],[G3],[G4],[G5]], axis=0)
        G  = tf.squeeze(G)
        G  = tf.transpose(G)
        return G 
    def compute_output_shape(self, input_shape):
        shape = tf.TensorShape(input_shape).as_list()
        shape[-1] = self.output_dim
        return tf.TensorShape(shape)
    def get_config(self):
        base_config = super(MorseFun_Layer, self).get_config()
        base_config['output_dim'] = self.output_dim
        return base_config
    @classmethod
    def from_config(cls, config):
        return cls(**config)


class MyLayer(layers.Layer):
  def __init__(self, output_dim, **kwargs):
    self.output_dim = output_dim
    super(MyLayer, self).__init__(**kwargs)
  def build(self, input_shape):
    shape = tf.TensorShape((input_shape[1], self.output_dim))
    # Create a trainable weight variable for this layer.
    self.kernel = self.add_weight(name='kernel',
                                  shape=shape,
                                  initializer='uniform',
                                  trainable=True)
    # Make sure to call the `build` method at the end
    super(MyLayer, self).build(input_shape)
  def call(self, inputs):
    return tf.matmul(inputs, self.kernel)
  def compute_output_shape(self, input_shape):
    shape = tf.TensorShape(input_shape).as_list()
    shape[-1] = self.output_dim
    return tf.TensorShape(shape)
  def get_config(self):
    base_config = super(MyLayer, self).get_config()
    base_config['output_dim'] = self.output_dim
    return base_config
  @classmethod
  def from_config(cls, config):
    return cls(**config)        

print(NNInput.NLayers)
Level1 = MorseFun_Layer(6)
Level2 = layers.Dense(units=NNInput.NLayers[3])
Level3 = layers.Dense(units=NNInput.NLayers[4])
Level4 = layers.Dense(units=NNInput.NLayers[5])

Level4(Level3(Level2(Level1(RSetTrainValid.astype('float32')))))


model = tf.keras.Sequential([Level1, Level2])



model.compile(loss=tf.keras.losses.MeanSquaredError(), optimizer='adam', metrics=['accuracy'])


history = model.fit(RSetTrainValid.astype('float32'), ySetTrainValid, shuffle=True, batch_size=NNInput.NMiniBatch, epochs=NNInput.NEpoch, validation_split=NNInput.PercValid, verbose=1)