import numpy
import math
import matplotlib.pyplot as plt
import six
from IPython.core.pylabtools import figsize

from DiatPot_O2_UMN import V_O2_UMN
from DiatPot_N2_DS  import V_N2_DS, V_N2_LeRoy 


def V_Diat_MAT(NNInput, RVec):
    
    VVecTemp = numpy.zeros((RVec.shape[0],3))
    dVVec    = numpy.zeros((RVec.shape[0],3))
    for iR in range(RVec.shape[1]):
        VVecTemp[:,iR],  dVVec[:,iR] = NNInput.DiatPot_Fun(RVec[:,iR])
    VVec = numpy.sum(VVecTemp,axis=1,keepdims=True)

    return VVec, dVVec


def V_Diat_MAT_print(NNInput, RVec):
    
    VVecTemp = numpy.zeros((RVec.shape[0],3))
    dVVec    = numpy.zeros((RVec.shape[0],3))
    for iR in range(RVec.shape[1]):
        VVecTemp[:,iR],  dVVec[:,iR] = NNInput.DiatPot_FunPrint(RVec[:,iR])
    VVec = numpy.sum(VVecTemp,axis=1,keepdims=True)

    return VVec, dVVec


def plot_DiatPot(NNInput, rMin, rMax, NPoints):

    rVec        = numpy.linspace(rMin, rMax, num=NPoints)
    VVec, dVVec = NNInput.DiatPot_Fun(rVec)

    fig = plt.figure(figsize(12.5, 5))
    ax = fig.add_subplot(1, 1, 1)
    ax.plot(rVec, VVec, 'b')
    plt.title(r"O2, Diatomic Potential")
    plt.xlim(rMin-0.3, rMax+0.3);

    fig = plt.figure(figsize(12.5, 5))
    ax = fig.add_subplot(1, 1, 1)
    ax.plot(rVec, dVVec, 'b')
    plt.title(r"O2, Derivative of Diatomic Potential")
    plt.xlim(rMin-0.3, rMax+0.3);

    plt.show()


def plot_DiatPot_N2(NNInput, rMin, rMax, NPoints):

    rVec              = numpy.linspace(rMin, rMax, num=NPoints)
    VVec_LeRoy, dVVec = V_N2_LeRoy(rVec)
    VVec_DS,    dVVec = V_N2_DS(rVec)

    fig = plt.figure(figsize(12.5, 5))
    ax = fig.add_subplot(1, 1, 1)
    ax.plot(rVec, VVec_LeRoy, 'g')
    ax.plot(rVec, VVec_DS,    'b')
    plt.title(r"O2, Diatomic Potential")
    plt.xlim(rMin-0.3, rMax+0.3);

    fig = plt.figure(figsize(12.5, 5))
    ax = fig.add_subplot(1, 1, 1)
    ax.plot(rVec, dVVec, 'b')
    plt.title(r"O2, Derivative of Diatomic Potential")
    plt.xlim(rMin-0.3, rMax+0.3);

    plt.show()