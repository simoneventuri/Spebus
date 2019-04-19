from __future__ import print_function

import pandas
import numpy
import theano
import math
import lasagne
import theano.tensor as T

from NNInput   import NNInput
import BondOrder 

def PIP_A3(NNInput, R, LambdaVec, reVec, G_MEAN, G_SD):
     
    BondOrderFun = getattr(BondOrder,NNInput.BondOrderStr)
    p0, p1, p2   = BondOrderFun(R, LambdaVec, reVec)

    # GNo = p0 + p1 + p2
    # G0  = GNo**2 - (p0**2 + p1**2 + p2**2)
    # G1  = GNo**3 - (p0**3 + p1**3 + p2**3)
    # G2  = GNo**4 - (p0**4 + p1**4 + p2**4)
    # G3  = GNo**5 - (p0**5 + p1**5 + p2**5)
    # G4  = GNo**6 - (p0**6 + p1**6 + p2**6)
    # G5  = GNo**7 - (p0**7 + p1**7 + p2**7)

    G0 = (p0*p1 + p1*p2 + p0*p2                                                             - G_MEAN[0]) / G_SD[0]
    G1 = (p0*p1*p2                                                                          - G_MEAN[1]) / G_SD[1]
    G2 = (p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2    - G_MEAN[2]) / G_SD[2]
    G3 = (p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3    - G_MEAN[3]) / G_SD[3]
    G4 = (p0**2*p1*p2 + p0*p1**2*p2 + p2**2*p1*p0                                           - G_MEAN[4]) / G_SD[4]
    G5 = (p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2                                           - G_MEAN[5]) / G_SD[5]

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

    def __init__(self, incoming, G_MEAN, G_SD, **kwargs):
        super(PIP_A3_Layer, self).__init__(incoming,  **kwargs)
        self.G_MEAN = G_MEAN
        self.G_SD   = G_SD

    def get_output_for(self, incoming, **kwargs):

        p0 = incoming[:,0]
        p1 = incoming[:,1]
        p2 = incoming[:,2]

        # GNo = p0 + p1 + p2
        # G0  = GNo**2 - (p0**2 + p1**2 + p2**2)
        # G1  = GNo**3 - (p0**3 + p1**3 + p2**3)
        # G2  = GNo**4 - (p0**4 + p1**4 + p2**4)
        # G3  = GNo**5 - (p0**5 + p1**5 + p2**5)
        # G4  = GNo**6 - (p0**6 + p1**6 + p2**6)
        # G5  = GNo**7 - (p0**7 + p1**7 + p2**7)

        G0 = (p0*p1 + p1*p2 + p0*p2                                                          - self.G_MEAN[0]) / self.G_SD[0]
        G1 = (p0*p1*p2                                                                       - self.G_MEAN[1]) / self.G_SD[1]
        G2 = (p0**2*p1    + p0*p1**2    + p2**2*p1    + p2*p1**2    + p0**2*p2    + p0*p2**2 - self.G_MEAN[2]) / self.G_SD[2]
        G3 = (p0**3*p1    + p0*p1**3    + p2**3*p1    + p2*p1**3    + p0**3*p2    + p0*p2**3 - self.G_MEAN[3]) / self.G_SD[3]
        G4 = (p0**2*p1*p2 + p0*p1**2*p2 + p0*p1*p2**2                                        - self.G_MEAN[4]) / self.G_SD[4]
        G5 = (p0**2*p1**2 + p2**2*p1**2 + p0**2*p2**2                                        - self.G_MEAN[5]) / self.G_SD[5]

        #G  = T.concatenate([[G0],[G1],[G2]], axis=0)
        G  = T.concatenate([[G0],[G1],[G2],[G3],[G4],[G5]], axis=0)
        G  = T.squeeze(G).T

        return G 

    def get_output_shape_for(self, input_shape):
        return (input_shape[0], 6)
