from __future__ import print_function

import pandas
import numpy
import theano
import math
import lasagne
import theano.tensor as T

from NNInput   import NNInput
import BondOrder 

def PIP_A3(NNInput, R, LambdaVec, reVec):
     
    BondOrderFun = getattr(BondOrder,NNInput.BondOrderStr)
    p0, p1, p2   = BondOrderFun(R, LambdaVec, reVec)

    G0 = p0*p1 + p1*p2 + p0*p2                                                             
    G1 = p0*p1*p2                                                                          
    G2 = p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2
    G3 = p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3
    G4 = p0**2*p1*p2 + p0*p1**2*p2 + p2**2*p1*p0                                        
    G5 = p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2                              

    #G  = numpy.column_stack([G0,G1,G2])
    G  = numpy.column_stack([G0,G1,G2,G3,G4,G5])

    return G


def PIP_A3_Mod(NNInput, R, Lambda, re):
     
    #BondOrderFun = getattr(BondOrder,'MorseFunMod')
    p0, p1, p2   = MorseFunMod(R, Lambda, re)

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


class PIP_A3_Layer(lasagne.layers.Layer):

    def __init__(self, incoming, **kwargs):
        super(PIP_A3_Layer, self).__init__(incoming,  **kwargs)

    def get_output_for(self, incoming, **kwargs):

        p0 = incoming[:,0]
        p1 = incoming[:,1]
        p2 = incoming[:,2]

        G0 = p0*p1 + p1*p2 + p0*p2                                                          
        G1 = p0*p1*p2                                                                       
        G2 = p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2 
        G3 = p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3 
        G4 = p0**2*p1*p2 + p0*p1**2*p2 + p0*p1*p2**2                                        
        G5 = p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2                                        

        #G  = T.concatenate([[G0],[G1],[G2]], axis=0)
        G  = T.concatenate([[G0],[G1],[G2],[G3],[G4],[G5]], axis=0)
        G  = T.squeeze(G).T

        return G 

    def get_output_shape_for(self, input_shape):
        return (input_shape[0], 6)
