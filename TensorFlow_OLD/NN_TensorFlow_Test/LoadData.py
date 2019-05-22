from __future__ import print_function

import pandas
import numpy
import math

from NNInputObj import NNInputObj
from SaveData   import save_labels
from SaveData   import save_parameters


def load_data(NNInput):
    ''' Loads the dataset

    :type PathToData: string
    :param PathToData: the path to the dataset (here MNIST)
    '''

    def load_labeled_input(PathToLabeledInput):

        print(('    Loading Labeled Input from File: ' + PathToLabeledInput + '\n'))

        xxData = pandas.read_csv(PathToLabeledInput, header=None, skiprows=1)
        #xDatay = pandas.read_csv(PathToData, header=0)
        xxData = xxData.apply(pandas.to_numeric, errors='coerce')
        #xData  = numpy.transpose(xxData.values)
        xData  = xxData.values

        return xData


    def load_labels(PathToLabels):

        print(('    Loading Labels from File: ' + PathToLabels + '\n'))

        yyData = pandas.read_csv(PathToLabels, header=None, skiprows=1)
        yyData = yyData.apply(pandas.to_numeric, errors='coerce')
        #yData  = numpy.transpose(yyData.values)
        yData  = yyData.values

        return yData


    # def generate_fake_data(PathToGenedWeightsFldr, PathToGenedLabels, NLayers, NTot, ActFun):

    #     print(('    Generating Weights and Labels\n'))

    #     NIn        = NLayers[0]
    #     NOut       = NLayers[-1]
    #     WAll       = []
    #     WValuesAll = []
    #     bAll       = []
    #     bValuesAll = []
    #     for i in range(len(NLayers)-2):
    #         WValues    = numpy.asarray(rng.uniform(low=-10.0, high=10.0, size=(NLayers[i], NLayers[i+1]), dtype=theano.config.floatX))
    #         WValuesAll = WValuesAll.append(WValues)
    #         W          = theano.shared(value=WValues, name='W', borrow=True)    
    #         WAll       = [WAll, W]

    #         bValues    = numpy.asarray(rng.uniform(low=-10.0, high=10.0, size=(NLayers[i+1],), dtype=theano.config.floatX))
    #         bValuesAll = bValuesAll.append(bValues)
    #         b          = theano.shared(value=bValues, name='b', borrow=True)
    #         bAll       = [bAll, b]

    #     save_labels(PathToGenedWeightsFldr, 'Generated', WValuesAll, bValuesAll)

    #     yData = []
    #     for i in range(NTot):
    #         yData.append( fwd(train_x, NLayers, ActFun, WAll, bAll) )
        
    #     save_labels(PathToGenedLabels, 'Generated', yData)
    #     return yData


    ##################################################################################################################################
    # LOADING DATA
    ##################################################################################################################################
    PathToLabeledInput = NNInput.PathToDataFldr + '/x.csv'
    xData = load_labeled_input(PathToLabeledInput)

    NTot        = xData.shape[0]
    NIn         = xData.shape[1]
    NTest       = math.floor(NTot * NNInput.PercTest)
    NTrainValid = NTot - (NTest)

    # if (NNInput.GenDataFlg):
    #     yData = generate_fake_data(NNInput.PathToGenedWeightsFldr, NNInput.PathToGenedLabels, NNInput.NLayers, NTot, NNInput.ActFun)
        
    # else:
    #     yData = load_labels(NNInput.PathToLabels)

    PathToLabels = NNInput.PathToDataFldr + '/y.csv'
    yData = load_labels(PathToLabels)

    SetTrainValid = (xData[0:NTrainValid-1,:], yData[0:NTrainValid-1])
    SetTest       = (xData[NTrainValid:,:],    yData[NTrainValid:])

    xSetTrainValid, ySetTrainValid = SetTrainValid
    xSetTest,       ySetTest       = SetTest

    rVal   = [(xSetTrainValid, ySetTrainValid), (xSetTest, ySetTest)]

    if (NNInput.TryNNFlg):
        PathToTryLabeledInput = NNInput.PathToDataFldr + '/xToCompare.csv'
        xPrint                = load_labeled_input(PathToTryLabeledInput)
        PathToTryLabels       = NNInput.PathToDataFldr + '/yToCompare.csv'
        yPrint                = load_labels(PathToTryLabels)
        SetPrint              = (xPrint, yPrint)
        xSetPrint, ySetPrint  = SetPrint
        rPrint                = (xSetPrint, ySetPrint)
        return rVal, rPrint
    else:
        return rVal