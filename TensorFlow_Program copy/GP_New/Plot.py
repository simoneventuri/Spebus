from __future__ import absolute_import, division, print_function

import tensorflow as tf
from tensorflow import keras
import matplotlib.pyplot as plt
import numpy

from NNInput    import NNInput

def plot_history(NNInput, history):
    fig = plt.figure()
    plt.xlabel('Epoch')
    plt.ylabel('Mean Abs Error [1000$]')
    plt.plot(history.epoch, numpy.array(history.history['mean_squared_error']), label='Train Loss')
    plt.plot(history.epoch, numpy.array(history.history['val_mean_squared_error']), label = 'Validation Loss')
    # plt.plot(history.epoch, numpy.array(history.history['mean_absolute_error']), label='Train Loss')
    # plt.plot(history.epoch, numpy.array(history.history['val_mean_absolute_error']), label = 'Validation Loss')
    plt.legend()
    plt.ylim([0, 5])
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


def plot_error(NNInput, error):
    fig = plt.figure()
    plt.hist(error, bins = 50)
    plt.xlabel("Prediction Error [1000$]")
    #_ = plt.ylabel("Count")
    FigPath = NNInput.PathToOutputFldr + '/Error.png'
    fig.savefig(FigPath)
    #plt.show()