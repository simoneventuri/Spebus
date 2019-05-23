from __future__ import print_function

import pandas
import numpy
import theano
import math
import theano.tensor as T
import time

from NNInput         import NNInput
from SaveData        import save_labels
from DiatPot         import V_Diat_MAT, V_Diat_MAT_print
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


    def get_print_data(NNInput, Ang, mean, std):

        PathToTryLabeledInput = NNInput.PathToDataFldr + '/R.csv.' + str(int(numpy.floor(Ang)))
        RPrint                = load_labeled_input(PathToTryLabeledInput)

        PathToTryLabels         = NNInput.PathToDataFldr + '/E.csv.' + str(int(numpy.floor(Ang)))
        yPrint                  = load_labels(PathToTryLabels)
        yPrintDiat, dyPrintDiat = V_Diat_MAT_print(NNInput, RPrint)
        yPrintTriat             = yPrint + 0.0#- yPrintDiat
        yPrint                  = Transformation(NNInput, yPrint, yPrintTriat)

        SetPrint                                = (RPrint, yPrint, yPrintDiat, yPrintTriat)
        RPrint, yPrint, yPrintDiat, yPrintTriat = shared_dataset(SetPrint)
        rPrint                                  = (RPrint, yPrint, yPrintDiat, yPrintTriat)
        return rPrint


    def load_scales(PathToScalingValues):

        xData = pandas.read_csv(PathToScalingValues, header=None, skiprows=1)
        xData = xData.apply(pandas.to_numeric)
        #yData  = numpy.transpose(yyData.values)
        xTemp = xData.values
        NormalizingMean = xTemp[0,:]
        NormalizingSTD  = xTemp[1,:]
        print('Mean = ',NormalizingMean)
        print('SD   = ',NormalizingSTD)

        return NormalizingMean, NormalizingSTD
        

    ##################################################################################################################################
    ###
    def shared_dataset(DataRY, borrow=True):
        """ Function that loads the dataset into shared variables

        The reason we store our dataset in shared variables is to allow Theano to copy it into the GPU memory (when code is run on GPU).
        Since copying data into the GPU is slow, copying a minibatch everytime is needed (the default behaviour if the data is not in a shared variable) would lead to a large decrease in performance.
        """
        RData, yData1, yData2, yData3  = DataRY

        shared_R  = theano.shared(numpy.asarray(RData,  dtype=theano.config.floatX), borrow=borrow)
        shared_y1 = theano.shared(numpy.asarray(yData1, dtype=theano.config.floatX), borrow=borrow)
        shared_y2 = theano.shared(numpy.asarray(yData2, dtype=theano.config.floatX), borrow=borrow)
        shared_y3 = theano.shared(numpy.asarray(yData3, dtype=theano.config.floatX), borrow=borrow)
        # When storing data on the GPU it has to be stored as floats therefore we will store the labels as ``floatX`` as well (``shared_y`` does exactly that). 
        # But during our computations we need them as ints (we use labels as index, and if they are floats it doesn't make sense) therefore instead of returning
        # ``shared_y`` we will have to cast it to int. This little hack lets ous get around this issue
        return shared_R, shared_y1, shared_y2, shared_y3

    ##################################################################################################################################
    # LOADING DATA
    ##################################################################################################################################
    PathToLabeledInput = NNInput.PathToDataFldr + '/R_10000Points.csv'
    RDataOrig          = load_labeled_input(PathToLabeledInput)
    if (NNInput.AddDiatPointsFlg):
        PathToLabeledInput = NNInput.PathToDataFldr + '/DiatPoints.csv'
        RDataDiat          = load_labeled_input(PathToLabeledInput)
        RData              = numpy.concatenate((RDataOrig, RDataDiat), axis=0)
    else:
        RData = RDataOrig + 0.0

    NTot    = RData.shape[0]
    NIn     = RData.shape[1]
    NTrain  = NTot

    # if (NNInput.GenDataFlg):
    #     yData = generate_fake_data(NNInput.PathToGenedWeightsFldr, NNInput.PathToGenedLabels, NNInput.NLayers, NTot, NNInput.ActFun)
        
    # else:
    #     yData = load_labels(NNInput.PathToLabels)

    PathToLabels                  = NNInput.PathToDataFldr + '/EFitted_10000Points.csv'
    yDataOrig                     = load_labels(PathToLabels)
    yDataDiatOrig, dyDataDiatOrig = V_Diat_MAT(NNInput, RDataOrig)
    yDataTriatOrig                = yDataOrig + 0.0 #- yDataDiatOrig
    if (NNInput.AddDiatPointsFlg):
        yDiatDiat, dyDiatDiat = V_Diat_MAT(NNInput, RDataDiat)
        yDiat                 = yDiatDiat + 1.e-10
        yDiatTriat            = yDiat - yDiatDiat
        yData      = numpy.concatenate((yDataOrig,      yDiat),      axis=0)
        yDataDiat  = numpy.concatenate((yDataDiatOrig,  yDiatDiat),  axis=0)
        yDataTriat = numpy.concatenate((yDataTriatOrig, yDiatTriat), axis=0)
    else:
        yData      = yDataOrig      + 0.0
        yDataDiat  = yDataDiatOrig  + 0.0
        yDataTriat = yDataTriatOrig + 0.0
    yData  = Transformation(NNInput, yData, yDataTriat)

    if (NNInput.RandomizeDataFlg):
        # Shuffle the training set
        order     = numpy.argsort(numpy.random.random(NTrain))
        for iR in range(RData.shape[1]):
            RData[:,iR] = RData[order,iR]
        yData = yData[order]

    RSetTrain      = (RData[0:-1,:])
    ySetTrain      = (yData[0:-1])
    ySetTrainDiat  = (yDataDiat[0:-1])
    ySetTrainTriat = (yDataTriat[0:-1])


    SetTrain = (RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat)
    RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat = shared_dataset(SetTrain)

    rVal   = [(RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat)]

    if (NNInput.TryNNFlg):
        rPrint = [get_print_data(NNInput, Ang, 0.0, 1.0) for Ang in NNInput.AngVector]
        return rVal, rPrint, RDataOrig, yDataOrig, yDataDiatOrig
    else:
        return rVal, RDataOrig, yDataOrig, yDataDiatOrig


def abscissa_to_plot(PathToAbscissaPlot):

    #print(('    Loading Abscissa to Plot from File: ' + PathToAbscissaPlot + '\n'))

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


def load_scales(PathToScalingValues):

    print(('    Loading Scaling Values from File: ' + PathToScalingValues))

    xData = pandas.read_csv(PathToScalingValues, header=None, skiprows=1)
    xData = xData.apply(pandas.to_numeric)
    #yData  = numpy.transpose(yyData.values)
    xTemp = xData.values
    NormalizingMean = xTemp[0,:]
    NormalizingSTD  = xTemp[1,:]

    return NormalizingMean, NormalizingSTD
