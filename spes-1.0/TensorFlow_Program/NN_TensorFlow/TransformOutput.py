from __future__ import print_function

import pandas
import numpy
import math

from NNInput     import NNInput

def Transformation(NNInput, yData, yDataTriat):

    if (NNInput.OnlyTriatFlg):
        yData = yDataTriat
    if (NNInput.MultErrorFlg):
        yData = yData + NNInput.PreLogShift
        #yData = numpy.log(yData)

    return yData


def InverseTransformation(NNInput, yData, yDataDiat):

    if (NNInput.MultErrorFlg):
        #yData = numpy.exp(yData) 
        yData = yData - NNInput.PreLogShift
    if (NNInput.OnlyTriatFlg):
        yData = yData + yDataDiat

    return yData