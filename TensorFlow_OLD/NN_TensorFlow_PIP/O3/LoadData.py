from __future__ import print_function

import pandas
import numpy
import math

from NNInput    import NNInput
from SaveData   import save_labels, save_parameters, save_scales
from PIP        import PIP_A3, PIP_A2B

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


    def get_print_data(NNInput, Ang, mean, std):

        PathToTryLabeledInput = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
        xPrint                = load_labeled_input(PathToTryLabeledInput)
        xPrint                = PIP_A3(NNInput, xPrint, NNInput.Lambda)
        if (NNInput.NormalizeDataFlg):
            xPrint            = (xPrint - mean) / std
        PathToTryLabels       = NNInput.PathToDataFldr + '/E.csv.' + str(Ang)
        yPrint                = load_labels(PathToTryLabels)
        SetPrint              = (xPrint, yPrint)
        xSetPrint, ySetPrint  = SetPrint
        rPrint                = (xSetPrint, ySetPrint)
        return rPrint


    def get_print_data(NNInput, Ang, G_MEAN, G_SD):

        PathToTryLabeledInput = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
        RPrint                = load_labeled_input(PathToTryLabeledInput)
        if (NNInput.NormalizeDataFlg):
            RPrint  = (RPrint - R_MEAN) / R_SD

        PathToTryLabels         = NNInput.PathToDataFldr + '/E.csv.' + str(Ang)
        yPrint                  = load_labels(PathToTryLabels)
        yPrintDiat, dyPrintDiat = V_Diat_MAT_print(NNInput, RPrint)
        yPrintTriat             = yPrint - yPrintDiat
        yPrint                  = Transformation(NNInput, yPrint, yPrintTriat)

        SetPrint              = (RPrint, yPrint)
        xSetPrint, ySetPrint  = SetPrint
        rPrint                = (xSetPrint, ySetPrint)

        return rPrint



    ##################################################################################################################################
    # LOADING DATA
    ##################################################################################################################################
    PathToLabeledInput = NNInput.PathToDataFldr + '/R.csv'
    xData = load_labeled_input(PathToLabeledInput)
    xData = PIP_A3(NNInput, xData, NNInput.Lambda)

    NTot        = xData.shape[0]
    NIn         = xData.shape[1]
    NTest       = math.floor(NTot * NNInput.PercTest)
    NTrainValid = NTot - (NTest)

    # if (NNInput.GenDataFlg):
    #     yData = generate_fake_data(NNInput.PathToGenedWeightsFldr, NNInput.PathToGenedLabels, NNInput.NLayers, NTot, NNInput.ActFun)
        
    # else:
    #     yData = load_labels(NNInput.PathToLabels)

    PathToLabels = NNInput.PathToDataFldr + '/E.csv'
    yData = load_labels(PathToLabels)


    if (NNInput.RandomizeDataFlg):
        # Shuffle the training set
        order = numpy.argsort(numpy.random.random(NTot))
        xData = xData[order]
        yData = yData[order]     

    SetTrainValid = (xData[0:NTrainValid-1,:], yData[0:NTrainValid-1])
    SetTest       = (xData[NTrainValid:,:],    yData[NTrainValid:])

    xSetTrainValid, ySetTrainValid = SetTrainValid
    xSetTest,       ySetTest       = SetTest


    if (NNInput.NormalizeDataFlg):
        mean = xData.mean(axis=0)
        std  = xData.std(axis=0)
        PathToScalingValues = NNInput.PathToOutputFldr + '/ScalingValues.csv'
        save_scales(PathToScalingValues, mean, std)
        xSetTrainValid = (xSetTrainValid - mean) / std
        xSetTest       = (xSetTest       - mean) / std
    else:
        mean = 0.0
        std  = 1.0

    ySetTrainValid = yData[0:NTrainValid-1]
    ySetTest       = yData[NTrainValid:]

    rVal   = [(xSetTrainValid, ySetTrainValid), (xSetTest, ySetTest)]

    if (NNInput.TryNNFlg):
        rPrint = [get_print_data(NNInput, Ang, mean, std) for Ang in NNInput.AngVector]
        return rVal, rPrint
    else:
        return rVal


def abscissa_to_plot(PathToAbscissaPlot):

    #print(('    Loading Abscissa to Plot from File: ' + PathToAbscissaPlot + '\n'))

    xData = pandas.read_csv(PathToAbscissaPlot, header=None, skiprows=1)
    xData = xData.apply(pandas.to_numeric, errors='coerce')
    #yData  = numpy.transpose(yyData.values)
    xPlot  = xData.values

    return xPlot


def load_parameters(PathToParametersFldr):

    print(('    Loading Parameters from Fldr: ' + PathToParametersFldr + '\n'))

    PathToFinalW = PathToParametersFldr + '/W.csv'
    WData = pandas.read_csv(PathToFinalW, header=None)
    WData = WData.apply(pandas.to_numeric, errors='coerce')
    #yData  = numpy.transpose(yyData.values)
    WData  = WData.values

    PathToFinalb = PathToParametersFldr + '/b.csv'
    bData = pandas.read_csv(PathToFinalb, header=None)
    bData = bData.apply(pandas.to_numeric, errors='coerce')
    #yData  = numpy.transpose(yyData.values)
    bData  = bData.values[:,0]

    return WData, bData