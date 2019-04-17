from __future__ import absolute_import, division, print_function

import matplotlib.pyplot as plt
import numpy
import math
import lasagne
import pandas
import theano.tensor as T

from NNInput         import NNInput
from SaveData        import save_cut
from PIP             import PIP_A3, PIP_A2B
from DiatPot         import V_Diat_MAT
from TransformOutput import InverseTransformation


def compute_cut(alpha, RIn, Layers, G_MEAN, G_SD):

    R1    = RIn
    R3    = numpy.linspace(1.5, 10.0, num=1000)
    R2    = numpy.sqrt(  R1**2 + numpy.power(R3,2) - 2.0 * R1 * R3 * math.cos( alpha/180.0*math.pi ) )
    R1    = R3*0.0 + R1
    R1    = numpy.expand_dims(R1, axis=1) 
    R2    = numpy.expand_dims(R2, axis=1) 
    R3    = numpy.expand_dims(R3, axis=1) 
    RTry  = numpy.concatenate((R1,R2,R3), axis=1)
    GTry  = PIP_A3(NNInput, RTry, NNInput.Lambda, NNInput.re)
    GTry  = (GTry - G_MEAN) / G_SD
    ETry  = lasagne.layers.get_output(Layers[-1], inputs=GTry) 
    ETry  = T.cast(ETry, 'float64')
    ETry  = ETry.eval() 
    ETryDiat, dETryDiat = V_Diat_MAT(NNInput, RTry)
    ETry  = InverseTransformation(NNInput, ETry, ETryDiat)

    return R3, ETry


def compute_cuts(NNInput, AnglesCuts, RCuts, Layers, G_MEAN, G_SD):

    PathToCuts = NNInput.PathToDataFldr + '/../'
    print(('    Loading Cuts from Folder: ' + PathToCuts + '\n'))

    for i in range(AnglesCuts.shape[0]):

        iTemp      = i+1
        PathToCut  = PathToCuts + '/Cut_' + str(iTemp) + '.csv.' + NNInput.iPES
        CutData    = pandas.read_csv(PathToCut, header=None, skiprows=1)
        CutData    = CutData.apply(pandas.to_numeric, errors='coerce')
        CutData    = CutData.values
        RData      = CutData[:,3]
        RData      = numpy.expand_dims(RData, axis=1) 
        EData      = CutData[:,4]
        EData      = numpy.expand_dims(EData, axis=1) 
        R3, ETry   = compute_cut(AnglesCuts[i], RCuts[i], Layers, G_MEAN, G_SD)
        save_cut(NNInput, iTemp, True,  numpy.concatenate((RData, EData), axis=1))
        save_cut(NNInput, iTemp, False, numpy.concatenate((R3, ETry), axis=1))