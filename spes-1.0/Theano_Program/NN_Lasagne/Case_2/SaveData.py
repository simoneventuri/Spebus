from __future__ import print_function

import pandas
import numpy
import theano
import math
import theano.tensor as T

from NNInput import NNInput


def save_labels(PathToLabels, DataType, yData):

    numpy.savetxt(PathToLabels, yData, delimiter=",")

    print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))


def save_parameters_PIP(PathToWeightsFldr, Lambda, re):

    PathToFinalLambda = PathToWeightsFldr + '/Lambda.csv'
    numpy.savetxt(PathToFinalLambda, Lambda, delimiter=",")

    PathToFinalre = PathToWeightsFldr + '/re.csv'
    numpy.savetxt(PathToFinalre, re, delimiter=",")

    #print(('        Wrote Weights in Folder: ' + PathToWeightsFldr + '\n'))


def save_parameters(PathToWeightsFldr, WAll, bAll):

    PathToFinalW = PathToWeightsFldr + '/W.csv'
    numpy.savetxt(PathToFinalW, WAll, delimiter=",")

    PathToFinalb = PathToWeightsFldr + '/b.csv'
    numpy.savetxt(PathToFinalb, bAll, delimiter=",")

    #print(('        Wrote Weights in Folder: ' + PathToWeightsFldr + '\n'))


def save_parameters_NoBiases(PathToWeightsFldr, WAll):

    PathToFinalW = PathToWeightsFldr + '/W.csv'
    numpy.savetxt(PathToFinalW, WAll, delimiter=",")

    #print(('        Wrote Weights in Folder: ' + PathToWeightsFldr + '\n'))


def save_to_plot(PathToLabels, DataType, xyData):
    
    with open(PathToLabels, 'w') as f:
        f.write('R1,R2,R3,EData,EPred\n')
        numpy.savetxt(f, xyData, delimiter=",")

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))


def save_scales(PathToScalingValues, Mean, SD):
    
    with open(PathToScalingValues, 'w') as f:
        f.write('Mean,SD\n')
        numpy.savetxt(f, numpy.array([Mean,SD]), delimiter=",")

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))


def save_cut(NNInput, Temp, Flgg, CutData):
    
    if (Flgg):
        PathToCut = NNInput.PathToOutputFldr + '/CutData_' + str(Temp) + '.csv'
        with open(PathToCut, 'w') as f:
            f.write('R1,EData\n')
            numpy.savetxt(f, CutData, delimiter=",")   
    else:
        PathToCut = NNInput.PathToOutputFldr + '/Cut_' + str(Temp) + '.csv'
        with open(PathToCut, 'w') as f:
            f.write('R1,EPred\n')
            numpy.savetxt(f, CutData, delimiter=",")   

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))