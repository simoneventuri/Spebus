from __future__ import print_function

import pandas
import numpy
import theano
import math

from SaveData import save_labels
from SaveData import save_parameters
from NNInput    import NNInput


def PIP_A3(NNInput, R, LambdaVec):

	p  = numpy.exp( - (R * NNInput.Lambda) )

	G1 = numpy.sum(p, axis=1) / 3.0 
	G2 = ( p[:,0]*p[:,1] + p[:,1]*p[:,2] + p[:,2]*p[:,0]) / 3.0
	G3 = numpy.prod(p, axis=1)

	G  = numpy.column_stack([G1,G2,G3])

	return G


def PIP_A2B(NNInput, R, LambdaVec):

	p  = numpy.exp( - (R * NNInput.Lambda) )

	G1 = (p[:,0] + p[:,1]) / 2.0 
	G2 =  p[:,0] * p[:,1]
	G3 =  p[:,2]

	G  = numpy.column_stack([G1,G2,G3])

	return G