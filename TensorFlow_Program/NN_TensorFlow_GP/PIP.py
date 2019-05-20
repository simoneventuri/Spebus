from __future__ import print_function

import pandas
import numpy
import theano
import math

from SaveData import save_labels
from SaveData import save_parameters
from NNInput  import NNInput
from LeRoy    import V_LeRoy


def PIP_A3(NNInput, R, LambdaVec):

	p  = numpy.exp( - (R * NNInput.Lambda) )
	q  = V_LeRoy(R) 

	G1 = numpy.sum(p, axis=1)
	G2 = p[:,0]*p[:,1] + p[:,1]*p[:,2] + p[:,2]*p[:,0]
	G3 = numpy.prod(p, axis=1)

	G4 = numpy.sum(q, axis=1)
	G5 = q[:,0]*q[:,1] + q[:,1]*q[:,2] + q[:,2]*q[:,0]
	G6 = numpy.prod(q, axis=1)

	#G  = numpy.column_stack([G1,G2,G3])
	G  = numpy.column_stack([G1,G2,G3,G4,G5,G6])

	return G


def PIP_A2B(NNInput, R, LambdaVec):

	p  = numpy.exp( - (R * NNInput.Lambda) )

	G1 = (p[:,0] + p[:,1]) / 2.0 
	G2 =  p[:,0] * p[:,1]
	G3 =  p[:,2]

	G  = numpy.column_stack([G1,G2,G3])

	return G