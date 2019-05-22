from __future__ import print_function

import pandas
import numpy
import math

from NNInput    import NNInput

def save_labels(PathToLabels, DataType, yData):

    numpy.savetxt(PathToLabels, yData, delimiter=",")

    print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))


def save_parameters(PathToWeightsFldr, WAll, bAll):

    PathToFinalW = PathToWeightsFldr + '/W.csv'
    numpy.savetxt(PathToFinalW, WAll, delimiter=",")

    PathToFinalb = PathToWeightsFldr + '/b.csv'
    numpy.savetxt(PathToFinalb, bAll, delimiter=",")

    #print(('        Wrote Weights in Folder: ' + PathToWeightsFldr + '\n'))


def save_to_plot(PathToLabels, DataType, xyData):
    
    with open(PathToLabels, 'w') as f:
        f.write('R1,R2,R3,E\n')
        numpy.savetxt(f, xyData, delimiter=",")

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))

def save_to_plot_all(PathToLabels, DataType, xyData):
    
    with open(PathToLabels, 'w') as f:
        f.write('R1,R2,R3,EData,EPred,ErrorAbs,ErrorRel,AbsErrorAbs,AbsErrorRel\n')
        numpy.savetxt(f, xyData, delimiter=",")

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))

def save_scales(PathToScalingValues, Mean, SD):
    
    with open(PathToScalingValues, 'w') as f:
        f.write('Mean,SD\n')
        numpy.savetxt(f, numpy.array([Mean,SD]), delimiter=",")

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))

def save_moments(PathToLabels, DataType, xyData):
    
    with open(PathToLabels, 'w') as f:
        f.write('R1,R2,R3,EData,EMean,ESD,EMinus,EPlus\n')
        numpy.savetxt(f, xyData, delimiter=",")

def save_der(PathToLabels, DataType, xyData):
    
    with open(PathToLabels, 'w') as f:
        f.write('R1,R2,R3,Der_x,Mean_x\n')
        numpy.savetxt(f, xyData, delimiter=",")


    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))