from __future__ import print_function

import os
import numpy

import tensorflow as tf
from tensorflow.keras import layers

from NNInput  import NNInput


def MorseFun(R, LambdaVec, reVec):

    p0 = numpy.exp( - LambdaVec[0,0] * (R[:,0] - reVec[0,0]) )
    p1 = numpy.exp( - LambdaVec[0,1] * (R[:,1] - reVec[0,1]) )
    p2 = numpy.exp( - LambdaVec[0,2] * (R[:,2] - reVec[0,2]) )

    return p0, p1, p2


def GaussFun(R, LambdaVec, reVec):

    p0 = numpy.exp( - LambdaVec[0,0] * (R[:,0] - reVec[0,0])**2 )
    p1 = numpy.exp( - LambdaVec[0,1] * (R[:,1] - reVec[0,1])**2 )
    p2 = numpy.exp( - LambdaVec[0,2] * (R[:,2] - reVec[0,2])**2 )

    return p0, p1, p2


def MEGFun(R, LambdaVec, reVec):

    p0 = numpy.exp( - LambdaVec[0,0] * (R[:,0] - reVec[0,0]) - LambdaVec[1,0] * (R[:,0] - reVec[1,0])**2 )
    p1 = numpy.exp( - LambdaVec[0,1] * (R[:,1] - reVec[0,1]) - LambdaVec[1,1] * (R[:,1] - reVec[1,1])**2 )
    p2 = numpy.exp( - LambdaVec[0,2] * (R[:,2] - reVec[0,2]) - LambdaVec[1,2] * (R[:,2] - reVec[1,2])**2 )

    return p0, p1, p2


def SechFun(R, LambdaVec, reVec):

    p0 = numpy.exp( - LambdaVec[0,0] * (R[:,0] - reVec[0,0]) - LambdaVec[0,1] * (R[:,0] - reVec[0,1])**2 )
    p1 = numpy.exp( - LambdaVec[0,1] * (R[:,1] - reVec[0,1]) - LambdaVec[1,1] * (R[:,1] - reVec[1,1])**2 )
    p2 = numpy.exp( - LambdaVec[0,2] * (R[:,2] - reVec[0,2]) - LambdaVec[2,1] * (R[:,2] - reVec[2,1])**2 )

    return p0, p1, p2


def MorsePot(R, LambdaVec, reVec):

    # p0 = LambdaVec[0,1] * ( 1.0 - numpy.exp( - LambdaVec[0,0] * (R[:,0] - reVec[0,0]) ) )**2
    # p1 = LambdaVec[1,1] * ( 1.0 - numpy.exp( - LambdaVec[1,0] * (R[:,1] - reVec[1,0]) ) )**2 
    # p2 = LambdaVec[2,1] * ( 1.0 - numpy.exp( - LambdaVec[2,0] * (R[:,2] - reVec[2,0]) ) )**2

    p0 = ( 1.0 - numpy.exp( - LambdaVec[0,0] * (R[:,0] - reVec[0,0]) ) )**2
    p1 = ( 1.0 - numpy.exp( - LambdaVec[0,1] * (R[:,1] - reVec[0,1]) ) )**2 
    p2 = ( 1.0 - numpy.exp( - LambdaVec[0,2] * (R[:,2] - reVec[0,2]) ) )**2

    return p0, p1, p2


class MorseFun_Layer(layers.Layer):
    def __init__(self, output_dim, **kwargs):
        self.output_dim = output_dim
        super(MorseFun_Layer, self).__init__(**kwargs)
    def build(self, input_shape):
        self.Lambdaa = self.add_weight(name='lambdaa', shape=(1,1), initializer='uniform', trainable=True)
        self.ree     = self.add_weight(name='ree',     shape=(1,1), initializer='uniform', trainable=True)
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