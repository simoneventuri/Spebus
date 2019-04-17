from __future__ import print_function

import pandas
import numpy
import theano
import math

from NNInputObj  import NNInputObj


def save_labels(PathToLabels, DataType, yData):

    numpy.savetxt(PathToLabels, yData, delimiter=",")

    print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))


def save_parameters(PathToWeightsFldr, WeightsType, WAll, bAll):

    PathToFinalW = PathToWeightsFldr + '/' + WeightsType + '_W.csv'
    numpy.savetxt(PathToFinalW, WAll, delimiter=",")

    PathToFinalb = PathToWeightsFldr + '/' + WeightsType + '_b.csv'
    numpy.savetxt(PathToFinalb, bAll, delimiter=",")

    print(('        Wrote '+ WeightsType + ' Weights in Folder: ' + PathToWeightsFldr + '\n'))