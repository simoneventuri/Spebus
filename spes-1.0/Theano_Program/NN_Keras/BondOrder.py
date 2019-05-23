from __future__ import print_function

import pandas
import numpy
import math
import theano
import theano.tensor as T
from keras import backend as K
from keras import layers
from keras import initializers

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


def DiatPotFun(R, LambdaVec, reVec):

    R0 = R[:,0]
    R1 = R[:,1]
    R2 = R[:,2]

    B_To_Ang       = 0.52917721067
    Kcm_To_Hartree = 0.159360144e-2
    VRef           = 0.1915103559
    a              = numpy.array([-1.488979427684798e3, 1.881435846488955e4, -1.053475425838226e5, 2.755135591229064e5, -4.277588997761775e5, 4.404104009614092e5, -2.946204062950765e5, 1.176861219078620e5 ])     
    alpha          = 9.439784362354936e-1
    beta           = 1.262242998506810
    r2r4Scalar     = 2.59361680                                                                                     
    rs6            = 0.5299
    rs8            = 2.20
    c6             = 12.8
    c8Step = 3.0 * c6 * r2r4Scalar**2
    tmp    = math.sqrt(c8Step / c6)  
    tmp6   = (rs6*tmp + rs8)**6  
    tmp8   = (rs6*tmp + rs8)**8

    eS0     = c6     / (R0**6 + tmp6)
    eE0     = c8Step / (R0**8 + tmp8)
    eS1     = c6     / (R1**6 + tmp6)
    eE1     = c8Step / (R1**8 + tmp8)
    eS2     = c6     / (R2**6 + tmp6)
    eE2     = c8Step / (R2**8 + tmp8)
    VDisp0  = (-eS0-2.0*eE0)  
    VDisp1  = (-eS1-2.0*eE1)  
    VDisp2  = (-eS2-2.0*eE2)  

    V0 = numpy.zeros_like(R0)
    V1 = numpy.zeros_like(R1)
    V2 = numpy.zeros_like(R2)
    for k in range(8):
        V0 = V0 + a[k] * numpy.exp(-alpha * beta**k * (R0*B_To_Ang)**2)
        V1 = V1 + a[k] * numpy.exp(-alpha * beta**k * (R1*B_To_Ang)**2)
        V2 = V2 + a[k] * numpy.exp(-alpha * beta**k * (R2*B_To_Ang)**2)
    V0 = V0*1.e-3
    V1 = V1*1.e-3
    V2 = V2*1.e-3

    p0  = (VDisp0 + V0 + VRef/3.0)  * 27.2113839712790 
    p1  = (VDisp1 + V1 + VRef/3.0)  * 27.2113839712790
    p2  = (VDisp2 + V2 + VRef/3.0)  * 27.2113839712790    

    return p0, p1, p2


class MorseFun_Layer(layers.Layer):
    def __init__(self, output_dim, **kwargs):
        self.output_dim = output_dim
        super(MorseFun_Layer, self).__init__(**kwargs)
    def build(self, input_shape):
        self.L  = self.add_weight(name='L',  shape=(1,1), initializer=initializers.Constant(value=0.5), trainable=True)
        self.re = self.add_weight(name='re', shape=(1,1), initializer=initializers.Constant(value=2.0), trainable=True)
        # Make sure to call the `build` method at the end
        print(input_shape)
        super(MorseFun_Layer, self).build(input_shape)
    def call(self, inputs):
        #p  = tf.math.exp( - self.L[0] * (inputs - self.re[0]) - self.L[1] * (inputs - self.re[1])**2  )
        p  = K.exp( - self.L[0] * (inputs - self.re[0]))
        return p
    def compute_output_shape(self, input_shape):
        return (input_shape[0], input_shape[1])
    def get_config(self):
        base_config = super(MorseFun_Layer, self).get_config()
        base_config['output_dim'] = self.output_dim
        return base_config
    @classmethod
    def from_config(cls, config):
        return cls(**config)


# class GaussFun_Layer(lasagne.layers.Layer):

#     def __init__(self, incoming, Lambda, re, **kwargs):
#         super(GaussFun_Layer, self).__init__(incoming,  **kwargs)
#         self.Lambda = self.add_param(Lambda, (1, 1), name='Lambda')
#         self.re     = self.add_param(re,     (1, 1), name='re')

#     def get_output_for(self, incoming, **kwargs):
        
#         p0 = T.exp( - self.Lambda * (incoming[:,0] - self.re)**2 )
#         p1 = T.exp( - self.Lambda * (incoming[:,1] - self.re)**2 )
#         p2 = T.exp( - self.Lambda * (incoming[:,2] - self.re)**2 )

#         p  = T.concatenate([[p0],[p1],[p2]], axis=0)
#         p  = T.squeeze(p).T

#         return p

#     def get_output_shape_for(self, input_shape):
#         return (input_shape[0], input_shape[1])



# class MEGFun_Layer(lasagne.layers.Layer):

#     def __init__(self, incoming, Lambda, re, **kwargs):
#         super(MEGFun_Layer, self).__init__(incoming,  **kwargs)
#         self.Lambda = self.add_param(Lambda, (2, 1), name='Lambda')
#         self.re     = self.add_param(re,     (2, 1), name='re')

#     def get_output_for(self, incoming, **kwargs):
        
#         p0 = T.exp( - self.Lambda[0] * (incoming[:,0] - self.re[0]) - self.Lambda[1] * (incoming[:,0] - self.re[1])**2 )
#         p1 = T.exp( - self.Lambda[0] * (incoming[:,1] - self.re[0]) - self.Lambda[1] * (incoming[:,1] - self.re[1])**2 )
#         p2 = T.exp( - self.Lambda[0] * (incoming[:,2] - self.re[0]) - self.Lambda[1] * (incoming[:,2] - self.re[1])**2 )

#         p  = T.concatenate([[p0],[p1],[p2]], axis=0)
#         p  = T.squeeze(p).T

#         return p

#     def get_output_shape_for(self, input_shape):
#         return (input_shape[0], input_shape[1])



# class SechFun_Layer(lasagne.layers.Layer):

#     def __init__(self, incoming, Lambda, re, **kwargs):
#         super(SechFun_Layer, self).__init__(incoming,  **kwargs)
#         self.Lambda = self.add_param(Lambda, (1, 1), name='Lambda')
#         self.re     = self.add_param(re,     (1, 1), name='re')

#     def get_output_for(self, incoming, **kwargs):
        
#         p0 = T.exp( - self.Lambda * (incoming[:,0] - self.re))
#         p1 = T.exp( - self.Lambda * (incoming[:,1] - self.re))
#         p2 = T.exp( - self.Lambda * (incoming[:,2] - self.re))

#         p  = T.concatenate([[p0],[p1],[p2]], axis=0)
#         p  = T.squeeze(p).T

#         return p

#     def get_output_shape_for(self, input_shape):
#         return (input_shape[0], input_shape[1])



# class MorsePot_Layer(lasagne.layers.Layer):

#     def __init__(self, incoming, Lambda, re, **kwargs):
#         super(MorsePot_Layer, self).__init__(incoming,  **kwargs)
#         self.Lambda = self.add_param(Lambda, (1, 1), name='Lambda')
#         self.re     = self.add_param(re,     (1, 1), name='re')

#     def get_output_for(self, incoming, **kwargs):
        
#         # p0 = self.Lambda[1] * (1.0 - T.exp( - self.Lambda[0] * (incoming[:,0] - self.re[0]) ) )**2
#         # p1 = self.Lambda[1] * (1.0 - T.exp( - self.Lambda[0] * (incoming[:,1] - self.re[0]) ) )**2 
#         # p2 = self.Lambda[1] * (1.0 - T.exp( - self.Lambda[0] * (incoming[:,2] - self.re[0]) ) )**2

#         p0 = (1.0 - T.exp( - self.Lambda * (incoming[:,0] - self.re) ) )**2
#         p1 = (1.0 - T.exp( - self.Lambda * (incoming[:,1] - self.re) ) )**2 
#         p2 = (1.0 - T.exp( - self.Lambda * (incoming[:,2] - self.re) ) )**2

#         p  = T.concatenate([[p0],[p1],[p2]], axis=0)
#         p  = T.squeeze(p).T

#         return p

#     def get_output_shape_for(self, input_shape):
#         return (input_shape[0], input_shape[1])



# class DiatPotFun_Layer(lasagne.layers.Layer):

#     def __init__(self, incoming, Lambda, re, **kwargs):
#         super(DiatPotFun_Layer, self).__init__(incoming,  **kwargs)

#     def get_output_for(self, incoming, **kwargs):
        
#         R0 = incoming[:,0]
#         R1 = incoming[:,1]
#         R2 = incoming[:,2]

#         B_To_Ang       = 0.52917721067
#         Kcm_To_Hartree = 0.159360144e-2
#         VRef           = 0.1915103559
#         a              = numpy.array([-1.488979427684798e3, 1.881435846488955e4, -1.053475425838226e5, 2.755135591229064e5, -4.277588997761775e5, 4.404104009614092e5, -2.946204062950765e5, 1.176861219078620e5 ])     
#         alpha          = 9.439784362354936e-1
#         beta           = 1.262242998506810
#         r2r4Scalar     = 2.59361680                                                                                     
#         rs6            = 0.5299
#         rs8            = 2.20
#         c6             = 12.8
#         c8Step = 3.0 * c6 * r2r4Scalar**2
#         tmp    = math.sqrt(c8Step / c6)  
#         tmp6   = (rs6*tmp + rs8)**6  
#         tmp8   = (rs6*tmp + rs8)**8

#         eS0     = c6     / (R0**6 + tmp6)
#         eE0     = c8Step / (R0**8 + tmp8)
#         eS1     = c6     / (R1**6 + tmp6)
#         eE1     = c8Step / (R1**8 + tmp8)
#         eS2     = c6     / (R2**6 + tmp6)
#         eE2     = c8Step / (R2**8 + tmp8)
#         VDisp0  = (-eS0-2.0*eE0)  
#         VDisp1  = (-eS1-2.0*eE1)  
#         VDisp2  = (-eS2-2.0*eE2)  

#         V0 = T.zeros_like(R0)
#         V1 = T.zeros_like(R1)
#         V2 = T.zeros_like(R2)
#         for k in range(8):
#             V0 = V0 + a[k] * T.exp(-alpha * beta**k * (R0*B_To_Ang)**2)
#             V1 = V1 + a[k] * T.exp(-alpha * beta**k * (R1*B_To_Ang)**2)
#             V2 = V2 + a[k] * T.exp(-alpha * beta**k * (R2*B_To_Ang)**2)
#         V0 = V0*1.e-3
#         V1 = V1*1.e-3
#         V2 = V2*1.e-3

#         p0  = (VDisp0 + V0 + VRef/3.0) * 27.2113839712790 
#         p1  = (VDisp1 + V1 + VRef/3.0) * 27.2113839712790
#         p2  = (VDisp2 + V2 + VRef/3.0) * 27.2113839712790            

#         p  = T.concatenate([[p0],[p1],[p2]], axis=0)
#         p  = T.squeeze(p).T

#         return p

#     def get_output_shape_for(self, input_shape):
#         return (input_shape[0], input_shape[1])