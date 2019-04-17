from __future__ import absolute_import, division, print_function

import matplotlib.pyplot as plt
import numpy
import math

from NNInput     import NNInput


def plot_history(NNInput, TrainEpochVec, Train, ValidEpochVec, Valid):
    fig = plt.figure()
    plt.xlabel('Epoch')
    plt.ylabel('Mean Abs Error [1000$]')
    plt.plot(TrainEpochVec, numpy.array(Train), label='Train Error')
    plt.plot(ValidEpochVec, numpy.array(Valid), label='Validation Error')
    plt.legend()
    #plt.ylim([0, 5])
    #plt.show()
    FigPath = NNInput.PathToOutputFldr + '/ErrorHistory.png'
    fig.savefig(FigPath)


def plot_try_set(NNInput, ySetTry, yPredTry):
    fig = plt.figure()
    plt.plot(ySetTry)
    plt.xlabel('True Values [1000$]')
    plt.ylabel('Predictions [1000$]')
    #plt.axis('equal')
    plt.xlim(plt.xlim())
    plt.ylim(plt.ylim())
    #_ = plt.plot([-100, 100], [-100, 100])
    FigPath = NNInput.PathToOutputFldr + '/ySetTry.png'
    fig.savefig(FigPath)
    #plt.show()

    fig = plt.figure()
    plt.plot(yPredTry)
    plt.xlabel('True Values [1000$]')
    plt.ylabel('Predictions [1000$]')
    #plt.axis('equal')
    plt.xlim(plt.xlim())
    plt.ylim(plt.ylim())
    #_ = plt.plot([-100, 100], [-100, 100])
    FigPath = NNInput.PathToOutputFldr + '/yPredTry.png'
    fig.savefig(FigPath)
    #plt.show()


def plot_error(NNInput, error, ErrorType):
    fig = plt.figure()
    plt.hist(error, bins = 50)
    plt.xlabel("Prediction Error [1000$]")
    #_ = plt.ylabel("Count")
    FigPath = NNInput.PathToOutputFldr + '/' + ErrorType + '_Error.png'
    fig.savefig(FigPath)
    #plt.show()


def plot_scatter(NNInput, yPred, yData):
    fig = plt.figure()
    plt.scatter(yData, yPred, s=10, c="b")
    #plt.plot([-5.0,90.0], [-5.0,90.0], 'k-')
    plt.plot([-5.0,20.0], [-5.0,20.0], 'k-')
    #plt.xlabel("Prediction Error [1000$]")
    #_ = plt.ylabel("Count")
    FigPath = NNInput.PathToOutputFldr + '/ScatterPlot.png'
    fig.savefig(FigPath, dpi=900)
    #plt.show()


def plot_overall_error(NNInput, yPred, ySet):

    # EnRange     = numpy.array([100.0, 200.0, 500.0, 1000.0, 1.e10])
    # EnRangeConv = (EnRange-26.3) * 0.04336411530877
    # MUE         = numpy.zeros(EnRange.shape[0])
    # RMSE        = numpy.zeros(EnRange.shape[0])
    # NPointsVec  = numpy.zeros(EnRange.shape[0])

    # iPoint = 0
    # for y in ySet:
    #     iRange = 0
    #     while (y >= EnRangeConv[iRange]):
    #         iRange=iRange+1
    #     MUE[iRange]        = MUE[iRange]        +  abs(ySet[iPoint] - yPred[iPoint]) / 0.04336411530877
    #     RMSE[iRange]       = RMSE[iRange]       + (abs(ySet[iPoint] - yPred[iPoint]) / 0.04336411530877)**2
    #     NPointsVec[iRange] = NPointsVec[iRange] + 1
    #     iPoint=iPoint+1
    # NPoints = iPoint
    # MUE  =             MUE / NPointsVec
    # RMSE = numpy.sqrt(RMSE / NPointsVec)

    # iRange=0
    # for iMUE in MUE:
    #     print('Range ', iRange+1, '; NOP=', NPointsVec[iRange], '; RMSE=', RMSE[iRange], '; MUE=', MUE[iRange])
    #     iRange=iRange+1

    EnRange     = numpy.array([3.0, 6.0, 10.0, 30.0])
    EnRangeConv = (EnRange)
    MUE         = numpy.zeros(EnRange.shape[0])
    RMSE        = numpy.zeros(EnRange.shape[0])
    NPointsVec  = numpy.zeros(EnRange.shape[0])

    iPoint = 0
    for y in ySet:
        iRange = 0
        while (y >= EnRangeConv[iRange]):
            iRange=iRange+1
        MUE[iRange]        = MUE[iRange]        +  abs(ySet[iPoint] - yPred[iPoint])
        RMSE[iRange]       = RMSE[iRange]       + (abs(ySet[iPoint] - yPred[iPoint]))**2
        NPointsVec[iRange] = NPointsVec[iRange] + 1
        iPoint=iPoint+1
    NPoints = iPoint
    MUE  =             MUE / NPointsVec
    RMSE = numpy.sqrt(RMSE / NPointsVec)

    iRange=0
    for iMUE in MUE:
        print('Range ', iRange+1, '; NOP=', NPointsVec[iRange], '; RMSE=', RMSE[iRange], '; MUE=', MUE[iRange])
        iRange=iRange+1


def plot_set(NNInput, xSetTrain, ySetTrain, xSetValid, ySetValid, xSetTest, ySetTest):
    fig = plt.figure()
    plt.scatter(xSetTrain[:,0], ySetTrain, c="b")
    plt.scatter(xSetValid[:,0], ySetValid, c="r")
    plt.scatter(xSetTest[:,0],  ySetTest,  c="g")
    plt.scatter(xSetTrain[:,1], ySetTrain, c="b")
    plt.scatter(xSetValid[:,1], ySetValid, c="r")
    plt.scatter(xSetTest[:,1],  ySetTest,  c="g")
    plt.scatter(xSetTrain[:,2], ySetTrain, c="b")
    plt.scatter(xSetValid[:,2], ySetValid, c="r")
    plt.scatter(xSetTest[:,2],  ySetTest,  c="g")
    FigPath = NNInput.PathToOutputFldr + '/Data.png'
    fig.savefig(FigPath)
    #plt.show()
