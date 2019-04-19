from __future__ import absolute_import, division, print_function

import matplotlib.pyplot as plt
import numpy
import pymc3
from scipy import stats

from NNInput import NNInput


def plot_ADVI_ELBO(NNInput, inference):

    fig = plt.figure()
    ax = fig.add_subplot(111)
    plt.plot(inference.hist)
    plt.ylabel('ELBO')
    plt.xlabel('iteration')
    ax.set_yscale('log')
    if (NNInput.PlotShow):
        plt.show()
    FigPath = NNInput.PathToOutputFldr + '/ADVI_ELBO.png'
    fig.savefig(FigPath)
    if not (NNInput.PlotShow):
        plt.close()


def plot_ADVI_trace(NNInput, ADVITrace):
    
    fig, axs = plt.subplots(9, 2)
    ax = pymc3.traceplot(ADVITrace, ax=axs)
    if (NNInput.PlotShow):
        plt.show()
    FigPath = NNInput.PathToOutputFldr + '/ADVI_Trace.png'
    fig.savefig(FigPath, dpi=1000, papertype='legal')
    if not (NNInput.PlotShow):
        plt.close()


def plot_ADVI_posterior(NNInput, ADVIApprox):

    fig = plt.figure()
    pymc3.plot_posterior(ADVIApprox.sample(NNInput.NApproxSamplesADVI), color='LightSeaGreen');
    if (NNInput.PlotShow):
        plt.show()
    FigPath = NNInput.PathToOutputFldr + '/ADVI_Posterior.png'
    fig.savefig(FigPath)
    if not (NNInput.PlotShow):
        plt.close()


def plot_ADVI_convergence(NNInput, ADVITracker, ADVIInference):

    fig     = plt.figure(figsize=(16, 9))
    mu_ax   = fig.add_subplot(221)
    std_ax  = fig.add_subplot(222)
    hist_ax = fig.add_subplot(212)
    mu_ax.plot(ADVITracker['mean'])
    mu_ax.set_title('Mean track')
    std_ax.plot(ADVITracker['std'])
    std_ax.set_title('Std track')
    hist_ax.plot(ADVIInference.hist)
    hist_ax.set_title('Negative ELBO track');
    if (NNInput.PlotShow):
        plt.show()    
    FigPath = NNInput.PathToOutputFldr + '/ADVI_Convergence.png'
    fig.savefig(FigPath)
    if not (NNInput.PlotShow):
        plt.close()


def plot_SVGD_vs_ADVI(NNInput, ADVIApprox, SVGDApprox):
    
    fig = plt.figure(figsize=(16, 9))
    sns.kdeplot(ADVIApprox.sample(2000), label='ADVI');
    sns.kdeplot(SVGDApprox.sample(2000), label='SVGD');
    if (NNInput.PlotShow):
        plt.show() 
    FigPath = NNInput.PathToOutputFldr + '/SVGD_vs_ADVI.png'
    fig.savefig(FigPath)
    if not (NNInput.PlotShow):
        plt.close()


def plot_ADVI_reconstruction(NNInput, means, sds):

    varnames = means.keys()
    fig, axs = plt.subplots(nrows=len(varnames), figsize=(12, 18))
    for var, ax in zip(varnames, axs):
        mu_arr    = means[var]
        sigma_arr = sds[var]
        ax.set_title(var)
        for i, (mu, sigma) in enumerate(zip(mu_arr.flatten(), sigma_arr.flatten())):
            sd3 = (-4*sigma + mu, 4*sigma + mu)
            x = numpy.linspace(sd3[0], sd3[1], 300)
            y = stats.norm(mu, sigma).pdf(x)
            ax.plot(x, y)
    fig.tight_layout()
    if (NNInput.PlotShow):
        plt.show()     
    FigPath = NNInput.PathToOutputFldr + '/ADVI_Reconstruction.png'
    fig.savefig(FigPath)
    if not (NNInput.PlotShow):
        plt.close()
