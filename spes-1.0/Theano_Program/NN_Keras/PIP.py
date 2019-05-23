from __future__ import print_function

import pandas
import numpy
import math
import theano
import theano.tensor as T
from keras import backend as K
from keras import layers
from keras import initializers


from NNInput   import NNInput
from SaveData  import save_labels, save_parameters
import BondOrder 

def PIP_A3(NNInput, R, LambdaVec, reVec):
     
    BondOrderFun = getattr(BondOrder,NNInput.BondOrderStr)
    p0, p1, p2   = BondOrderFun(R, LambdaVec, reVec)

    # GNo = p0 + p1 + p2
    # G0  = GNo**2 - (p0**2 + p1**2 + p2**2)
    # G1  = GNo**3 - (p0**3 + p1**3 + p2**3)
    # G2  = GNo**4 - (p0**4 + p1**4 + p2**4)
    # G3  = GNo**5 - (p0**5 + p1**5 + p2**5)
    # G4  = GNo**6 - (p0**6 + p1**6 + p2**6)
    # G5  = GNo**7 - (p0**7 + p1**7 + p2**7)

    G0 = p0*p1 + p1*p2 + p0*p2
    G1 = p0*p1*p2
    G2 = p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2
    G3 = p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3
    G4 = p0**2*p1*p2 + p0*p1**2*p2 + p2**2*p1*p0
    G5 = p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2

    #G  = numpy.column_stack([G0,G1,G2])
    G  = numpy.column_stack([G0,G1,G2,G3,G4,G5])

    return G


def PIP_A2B(NNInput, R, LambdaVec):

    BondOrderFun = getattr(BondOrder,NNInput.BondOrderStr)
    p0, p1, p2   = BondOrderFun(R, LambdaVec, reVec)

    G0 = (p0 + p1) / 2.0 
    G1 =  p0 * p1
    G2 =  p2
    G  = numpy.column_stack([G0,G1,G2])

    return G


class PIP_A3_Layer(layers.Layer):
    def __init__(self, output_dim, **kwargs):
        self.output_dim = output_dim
        super(PIP_A3_Layer, self).__init__(**kwargs)
    def call (self, inputs, training=False):
        p0 = inputs[:,0]
        p1 = inputs[:,1]
        p2 = inputs[:,2]
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
        base_config = super(PIP_A3_Layer, self).get_config()
        base_config['output_dim'] = self.output_dim
        return base_config
    @classmethod
    def from_config(cls, config):
        return cls(**config)
