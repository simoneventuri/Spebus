from __future__ import print_function

import pandas
import numpy
import math
import time

from DiatPot         import V_Diat_MAT, V_Diat_MAT_print
from NNInput         import NNInput
from SaveData        import save_labels, save_parameters, save_scales
import PIP      
from TransformOutput import Transformation

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
        xData  = xxData.values * NNInput.AbscissaConverter
        return xData


    def load_labels(PathToLabels):
        print(('    Loading Labels from File: ' + PathToLabels + '\n'))
        yyData = pandas.read_csv(PathToLabels, header=None, skiprows=1)
        yyData = yyData.apply(pandas.to_numeric, errors='coerce')
        #yData  = numpy.transpose(yyData.values)
        yData  = yyData.values
        return yData


    def get_print_data(NNInput, Ang):

        PathToTryLabeledInput = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
        RPrint                = load_labeled_input(PathToTryLabeledInput)

        PathToTryLabels         = NNInput.PathToDataFldr + '/E.csv.' + str(Ang)
        yPrint                  = load_labels(PathToTryLabels)
        yPrintDiat, dyPrintDiat = V_Diat_MAT_print(NNInput, RPrint)
        yPrintTriat             = yPrint - yPrintDiat
        yPrint                  = Transformation(NNInput, yPrint, yPrintTriat)

        SetPrint                = (RPrint, yPrint, yPrintDiat, yPrintTriat)
        rPrint                  = (RPrint, yPrint, yPrintDiat, yPrintTriat)
        return rPrint



    ##################################################################################################################################
    # LOADING DATA
    ##################################################################################################################################
    PathToLabeledInput = NNInput.PathToDataFldr + '/R.csv'
    RData              = load_labeled_input(PathToLabeledInput)
    RDataOrig          = RData + 0.0

    NTot         = RData.shape[0]
    NIn          = RData.shape[1]
    NTrainValid  = math.floor(NTot * (NNInput.PercTrain+NNInput.PercValid))
    NTest        = NTot - (NTrainValid)

    PathToLabels                  = NNInput.PathToDataFldr + '/EFitted.csv'
    yDataOrig                     = load_labels(PathToLabels)
    yDataOrig                     = numpy.squeeze(yDataOrig)
    yDataDiatOrig, dyDataDiatOrig = V_Diat_MAT(NNInput, RData)
    yDataTriatOrig                = yDataOrig - yDataDiatOrig
    yData = Transformation(NNInput, yDataOrig, yDataTriatOrig)

    order      = numpy.argsort(yData)
    for iR in range(3):
        RData[:,iR]      = numpy.squeeze(RDataOrig[order,iR])

    yData      = yData[order]
    yDataDiat  = yDataDiatOrig[order]
    yDataTriat = yDataTriatOrig[order]

    ValidPerCent = int(numpy.floor(NNInput.PercValid*100))
    TrainPerCent = 100 - ValidPerCent

    RSetTrain      = numpy.empty((0,3), dtype=numpy.float64)
    ySetTrain      = numpy.empty((0,1), dtype=numpy.float64)
    ySetTrainTriat = numpy.empty((0,1), dtype=numpy.float64)
    ySetTrainDiat  = numpy.empty((0,1), dtype=numpy.float64)
    RSetValid      = numpy.empty((0,3), dtype=numpy.float64)
    ySetValid      = numpy.empty((0,1), dtype=numpy.float64)
    ySetValidTriat = numpy.empty((0,1), dtype=numpy.float64)
    ySetValidDiat  = numpy.empty((0,1), dtype=numpy.float64)

    NBatches = int(numpy.floor(NTot / 100))
    iStart   = 0
    for iBatch in range(NBatches):
        iEnd    = iStart+100
        RDataTemp = numpy.empty((100,3), dtype=numpy.float64)
        for iR in range(3):
            RDataTemp[:,iR] = numpy.squeeze(RData[iStart:iEnd,iR])
        yDataTemp      = yData[iStart:iEnd]
        yDataTriatTemp = yDataTriat[iStart:iEnd]
        yDataDiatTemp  = yDataDiat[iStart:iEnd]
        iStart  = iEnd
        if (NNInput.RandomizeDataFlg):
            order = numpy.argsort(numpy.random.random(100))
        else:
            order = numpy.arange(100)
        RSetTrain      = numpy.append(RSetTrain,      RDataTemp[order[0:TrainPerCent],:], axis=0)
        ySetTrain      = numpy.append(ySetTrain,      yDataTemp[order[0:TrainPerCent]])
        ySetTrainTriat = numpy.append(ySetTrainTriat, yDataTriatTemp[order[0:TrainPerCent]])
        ySetTrainDiat  = numpy.append(ySetTrainDiat,  yDataDiatTemp[order[0:TrainPerCent]])
        RSetValid      = numpy.append(RSetValid,      RDataTemp[order[TrainPerCent:],:], axis=0)
        ySetValid      = numpy.append(ySetValid,      yDataTemp[order[TrainPerCent:]])
        ySetValidTriat = numpy.append(ySetValidTriat, yDataTriatTemp[order[TrainPerCent:]])
        ySetValidDiat  = numpy.append(ySetValidDiat,  yDataDiatTemp[order[TrainPerCent:]])

    if (iStart<NTot):
        RDataTemp      = RData[iStart:,:]
        yDataTemp      = yData[iStart:]
        yDataTriatTemp = yDataTriat[iStart:]
        yDataDiatTemp  = yDataDiat[iStart:]
        RSetTrain      = numpy.append(RSetTrain,      RDataTemp, axis=0)
        ySetTrain      = numpy.append(ySetTrain,      yDataTemp)
        ySetTrainTriat = numpy.append(ySetTrainTriat, yDataTriatTemp)
        ySetTrainDiat  = numpy.append(ySetTrainDiat,  yDataDiatTemp)


    # if (NNInput.RandomizeDataFlg):
    #     # Shuffle the training set
    #     order = numpy.argsort(numpy.random.random(NTot))
    #     for iR in range(RData.shape[1]):
    #         RData[:,iR] = RDataOrig[order,iR]
    #     yData      = yData[order]   
    #     yDataTriat = yDataTriatOrig[order]      
    #     yDataDiat  = yDataDiatOrig[order]    

    # RSetTrain      = (RData[0:NTrainValid-1,:])
    # ySetTrain      = (yData[0:NTrainValid-1])
    # ySetTrainTriat = (yDataTriat[0:NTrainValid-1])
    # ySetTrainDiat  = (yDataDiat[0:NTrainValid-1])

    # RSetValid      = (RData[0:NTrainValid-1,:])
    # ySetValid      = (yData[0:NTrainValid-1])
    # ySetValidTriat = (yDataTriat[0:NTrainValid-1])
    # ySetValidDiat  = (yDataDiat[0:NTrainValid-1])

    # RSetTest       = (RData[NTrainValid:-1,:])
    # ySetTest       = (yData[NTrainValid:-1])
    # ySetTestTriat  = (yDataTriat[NTrainValid:-1])
    # ySetTestDiat   = (yDataDiat[NTrainValid:-1])

    # DataML   = [(RSetTrainValid, ySetTrainValid, ySetTrainValidDiat, ySetTrainValidTriat), (RSetTest, ySetTest, ySetTestDiat, ySetTestTriat), (RDataOrig, yDataOrig, yDataDiatOrig, yDataTriatOrig)]
    DataML   = [(RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat), (RSetValid, ySetValid, ySetValidDiat, ySetValidTriat), (RDataOrig, yDataOrig, yDataDiatOrig, yDataTriatOrig)]

    if (NNInput.TryNNFlg > 0):
        DataPlots = [get_print_data(NNInput, Ang) for Ang in NNInput.AngVector]
        return DataML, DataPlots
    else:
        return DataML



def abscissa_to_plot(PathToAbscissaPlot):

    print(('    Loading Abscissa to Plot from File: ' + PathToAbscissaPlot + '\n'))

    xData = pandas.read_csv(PathToAbscissaPlot, header=None, skiprows=1)
    xData = xData.apply(pandas.to_numeric, errors='coerce')
    #yData  = numpy.transpose(yyData.values)
    xPlot  = xData.values * NNInput.AbscissaConverter

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



def load_parameters_NoBiases(PathToParametersFldr):

    print(('    Loading Parameters from Fldr: ' + PathToParametersFldr + '\n'))

    PathToFinalW = PathToParametersFldr + '/W.csv'
    WData = pandas.read_csv(PathToFinalW, header=None)
    WData = WData.apply(pandas.to_numeric, errors='coerce')
    #yData  = numpy.transpose(yyData.values)
    WData  = WData.values

    return WData



def load_parameters_PIP(PathToParametersFldr):

    print(('    Loading PIP Parameters from Fldr: ' + PathToParametersFldr + '\n'))

    PathToFinalLambda = PathToParametersFldr + '/Lambda.csv'
    LambdaData = pandas.read_csv(PathToFinalLambda, header=None)
    LambdaData = LambdaData.apply(pandas.to_numeric, errors='coerce')
    #yData  = numpy.transpose(yyData.values)
    LambdaData = LambdaData.values

    PathToFinalre = PathToParametersFldr + '/re.csv'
    reData = pandas.read_csv(PathToFinalre, header=None)
    reData = reData.apply(pandas.to_numeric, errors='coerce')
    #yData  = numpy.transpose(yyData.values)
    reData = reData.values

    return LambdaData, reData
