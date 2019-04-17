from __future__ import print_function

import pandas
import numpy
import theano
import math
import theano.tensor as T

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


    def get_print_data(NNInput, Ang, G_MEAN, G_SD):

        PathToTryLabeledInput = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
        RPrint                = load_labeled_input(PathToTryLabeledInput)
        RPrint                = RPrint
        PIPFunc               = getattr(PIP,NNInput.PIPTypeStr)
        GPrint                = PIPFunc(NNInput, RPrint, NNInput.Lambda, NNInput.re)
        if (NNInput.NormalizeDataFlg):
            GPrint            = (GPrint - G_MEAN) / G_SD

        PathToTryLabels         = NNInput.PathToDataFldr + '/E.csv.' + str(Ang)
        yPrint                  = load_labels(PathToTryLabels)
        yPrintDiat, dyPrintDiat = V_Diat_MAT_print(NNInput, RPrint)
        yPrintTriat             = yPrint - yPrintDiat
        yPrint                  = Transformation(NNInput, yPrint, yPrintTriat)

        SetPrint                                        = (RPrint, GPrint, yPrint, yPrintDiat, yPrintTriat)
        RPrint, GPrint, yPrint, yPrintDiat, yPrintTriat = shared_dataset(SetPrint)
        rPrint                                          = (RPrint, GPrint, yPrint, yPrintDiat, yPrintTriat)
        return rPrint


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
    ###
    def shared_dataset(DataRGY, borrow=True):
        """ Function that loads the dataset into shared variables

        The reason we store our dataset in shared variables is to allow Theano to copy it into the GPU memory (when code is run on GPU).
        Since copying data into the GPU is slow, copying a minibatch everytime is needed (the default behaviour if the data is not in a shared variable) would lead to a large decrease in performance.
        """
        RData, GData, yData1, yData2, yData3  = DataRGY

        shared_R  = theano.shared(numpy.asarray(RData,  dtype=theano.config.floatX), borrow=borrow)
        shared_G  = theano.shared(numpy.asarray(GData,  dtype=theano.config.floatX), borrow=borrow)
        shared_y1 = theano.shared(numpy.asarray(yData1, dtype=theano.config.floatX), borrow=borrow)
        shared_y2 = theano.shared(numpy.asarray(yData2, dtype=theano.config.floatX), borrow=borrow)
        shared_y3 = theano.shared(numpy.asarray(yData3, dtype=theano.config.floatX), borrow=borrow)
        # When storing data on the GPU it has to be stored as floats therefore we will store the labels as ``floatX`` as well (``shared_y`` does exactly that). 
        # But during our computations we need them as ints (we use labels as index, and if they are floats it doesn't make sense) therefore instead of returning
        # ``shared_y`` we will have to cast it to int. This little hack lets ous get around this issue
        return shared_R, shared_G, shared_y1, shared_y2, shared_y3


    ##################################################################################################################################
    # LOADING DATA
    ##################################################################################################################################
    PathToLabeledInput = NNInput.PathToDataFldr + '/R.csv'
    RDataOrig          = load_labeled_input(PathToLabeledInput)
    RDataOrig          = RDataOrig
    if (NNInput.AddDiatPointsFlg):
        PathToLabeledInput = NNInput.PathToDataFldr + '/DiatPoints.csv'
        RDataDiat          = load_labeled_input(PathToLabeledInput)
        RDataDiat          = RDataDiat
        RData              = numpy.concatenate((RDataOrig, RDataDiat), axis=0)
    else:
        RData = RDataOrig + 0.0
    PIPFunc = getattr(PIP,NNInput.PIPTypeStr)
    GData   = PIPFunc(NNInput, RData, NNInput.Lambda, NNInput.re)

    NTot    = RData.shape[0]
    NIn     = RData.shape[1]
    NTrain  = math.floor(NTot * NNInput.PercTrain)
    NValid  = math.floor(NTot * NNInput.PercValid)
    NTest   = NTot - (NTrain + NValid)

    # if (NNInput.GenDataFlg):
    #     yData = generate_fake_data(NNInput.PathToGenedWeightsFldr, NNInput.PathToGenedLabels, NNInput.NLayers, NTot, NNInput.ActFun)
        
    # else:
    #     yData = load_labels(NNInput.PathToLabels)

    PathToLabels                  = NNInput.PathToDataFldr + '/EOrig.csv'
    yDataOrig                     = load_labels(PathToLabels)
    yDataDiatOrig, dyDataDiatOrig = V_Diat_MAT(NNInput, RDataOrig)
    yDataTriatOrig                = yDataOrig - yDataDiatOrig
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
    yData = Transformation(NNInput, yData, yDataTriat)


    if (NNInput.RandomizeDataFlg):
        # Shuffle the training set
        order = numpy.argsort(numpy.random.random(NTot))
        for iR in range(RData.shape[1]):
            RData[:,iR] = RData[order,iR]
            GData[:,iR] = GData[order,iR]
        yData      = yData[order]   
        yDataTriat = yDataTriat[order]      
        yDataDiat  = yDataDiat[order]    


    if (NNInput.NormalizeDataFlg):
        G_MEAN = GData.mean(axis=0)
        G_SD   = GData.std(axis=0)
        print('    Scale Values: Mean=', G_MEAN, '; StDev=', G_SD, '\n')
    else:
        G_MEAN = numpy.array([0.0, 0.0, 0.0])
        G_SD   = numpy.array([1.0, 1.0, 1.0]) 
        #G_MEAN = numpy.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        #G_SD   = numpy.array([1.0, 1.0, 1.0, 1.0, 1.0, 1.0]) 
    PathToScalingValues = NNInput.PathToOutputFldr + '/ScalingValues.csv'
    save_scales(PathToScalingValues, G_MEAN, G_SD)
    GData = (GData - G_MEAN) / G_SD

    RSetTrain      = (RData[0:NTrain,:])
    GSetTrain      = (GData[0:NTrain,:])
    ySetTrain      = (yData[0:NTrain])
    ySetTrainTriat = (yDataTriat[0:NTrain])
    ySetTrainDiat  = (yDataDiat[0:NTrain])

    RSetValid      = (RData[NTrain:NTrain+NValid,:])
    GSetValid      = (GData[NTrain:NTrain+NValid,:])
    ySetValid      = (yData[NTrain:NTrain+NValid])
    ySetValidTriat = (yDataTriat[NTrain:NTrain+NValid])
    ySetValidDiat  = (yDataDiat[NTrain:NTrain+NValid])

    RSetTest       = (RData[NTrain+NValid:NTrain+NValid+NTest,:])
    GSetTest       = (GData[NTrain+NValid:NTrain+NValid+NTest,:])
    ySetTest       = (yData[NTrain+NValid:NTrain+NValid+NTest])
    ySetTestTriat  = (yDataTriat[NTrain+NValid:NTrain+NValid+NTest])
    ySetTestDiat   = (yDataDiat[NTrain+NValid:NTrain+NValid+NTest])


    SetTrain = (RSetTrain, GSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat)
    SetValid = (RSetValid, GSetValid, ySetValid, ySetValidDiat, ySetValidTriat)
    SetTest  = (RSetTest,  GSetTest,  ySetTest,  ySetTestDiat,  ySetTestTriat)

    RSetTrain, GSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat = shared_dataset(SetTrain)
    RSetValid, GSetValid, ySetValid, ySetValidDiat, ySetValidTriat = shared_dataset(SetValid)
    RSetTest,  GSetTest,  ySetTest,  ySetTestDiat,  ySetTestTriat  = shared_dataset(SetTest)

    rVal   = [(RSetTrain, GSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat), (RSetValid, GSetValid, ySetValid, ySetValidDiat, ySetValidTriat), (RSetTest,  GSetTest,  ySetTest,  ySetTestDiat,  ySetTestTriat)]

    if (NNInput.TryNNFlg > 0):
        rPrint = [get_print_data(NNInput, Ang, G_MEAN, G_SD) for Ang in NNInput.AngVector]
        return rVal, rPrint, G_MEAN, G_SD, RDataOrig, yDataOrig, yDataDiatOrig
    else:
        return rVal, G_MEAN, G_SD, RDataOrig, yDataOrig, yDataDiatOrig


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
