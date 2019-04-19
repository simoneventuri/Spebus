from __future__ import print_function

import pandas
import numpy
import theano
import math
import theano.tensor as T

from NNInput import NNInput


def save_labels(PathToLabels, DataType, yData):

    numpy.savetxt(PathToLabels, yData, delimiter=",")

    print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))


def save_ADVI_reconstruction_PIP(NNInput, PathToADVI, ADVIApprox, Params):

    n                = T.iscalar('n')
    n.tag.test_value = 100
    NParamsStats     = 3000#NNInput.NParPostSamples

    for var in ['Lambda', 're', 'W1', 'W2', 'W3', 'b1', 'b2', 'b3', 'Sigma']:
        #
        _sample_proba = ADVIApprox.sample_node(Params.get(var), size=n)
        sample_proba  = theano.function([n], _sample_proba)
        Pred          = sample_proba(NParamsStats)
        #
        mu_arr        = numpy.atleast_1d(numpy.mean(Pred,axis=0))
        sigma_arr     = numpy.atleast_1d(numpy.std(Pred,axis=0))
        #
        print('    Parameter: ', var, ';\n      Mean = ', mu_arr, ';\n      Std. Dev. = ', sigma_arr,'\n\n')
        #
        PathToADVImeans = PathToADVI + '/' + str(var) + '_mu.csv'
        PathToADVIsds   = PathToADVI + '/' + str(var) + '_sd.csv'
        #
        numpy.savetxt(PathToADVImeans,    mu_arr, delimiter=",")
        numpy.savetxt(PathToADVIsds,   sigma_arr, delimiter=",")
        #
    print(('    Wrote Means and Std.Devs from ADVI reconstruction in Folder: ' + PathToADVI + '\n'))


def save_ADVI_sample_PIP(NNInput, PathToADVI, ADVIApprox, Params):

    n                = T.iscalar('n')
    n.tag.test_value = 100
    NPSamples        = NNInput.NParPostSamples

    for var in ['Lambda', 're', 'W1', 'W2', 'W3', 'b1', 'b2', 'b3', 'Sigma']:
        #
        _sample_proba = ADVIApprox.sample_node(Params.get(var), size=n)
        sample_proba  = theano.function([n], _sample_proba)
        Pred          = sample_proba(NPSamples)
        #
        for iSample in range(NPSamples):
            sample_arr    = numpy.atleast_1d(Pred[iSample,])
            PathToSamples = PathToADVI + '/' + str(var) + '.csv.'  + str(iSample+1)
            numpy.savetxt(PathToSamples, sample_arr, delimiter=",")
        #
    print(('    Wrote Samples from ADVI reconstruction in Folder: ' + PathToADVI + '\n'))


# def save_ADVI_reconstruction_PIP(PathToADVI, ADVITrace, model):

#     n = T.iscalar('n')
#     n.tag.test_value = 100

#     if (NNInput.Model == 'PIP'):
#         for var in ['W1', 'W2', 'W3', 'b1', 'b2', 'b3', 'Sigma']:

#             mu_arr    = numpy.atleast_1d(numpy.mean(ADVITrace[var],axis=0))
#             sigma_arr = numpy.atleast_1d(numpy.std(ADVITrace[var],axis=0))

#             print(var,mu_arr,sigma_arr)

#             PathToADVImeans = PathToADVI + '/' + str(var) + '_mu.csv'
#             PathToADVIsds   = PathToADVI + '/' + str(var) + '_sd.csv'

#             numpy.savetxt(PathToADVImeans,    mu_arr, delimiter=",")
#             numpy.savetxt(PathToADVIsds,   sigma_arr, delimiter=",")

#     elif (NNInput.Model == 'ModPIP'):
#         for var in ['Lambda', 're', 'W1', 'W2', 'W3', 'b1', 'b2', 'b3', 'Sigma']:

#             mu_arr    = numpy.atleast_1d(numpy.mean(ADVITrace[var],axis=0))
#             sigma_arr = numpy.atleast_1d(numpy.std(ADVITrace[var],axis=0))

#             print(var,mu_arr,sigma_arr)

#             PathToADVImeans = PathToADVI + '/' + str(var) + '_mu.csv'
#             PathToADVIsds   = PathToADVI + '/' + str(var) + '_sd.csv'

#             numpy.savetxt(PathToADVImeans,    mu_arr, delimiter=",")
#             numpy.savetxt(PathToADVIsds,   sigma_arr, delimiter=",")

#     print(('        Wrote Means and Std.Devs from ADVI reconstruction in Folder: ' + PathToADVI + '\n'))



# def save_ADVI_sample_PIP(PathToADVI, ADVITrace, NTraceADVI, NParPostSamples, model):
    
#     for iSample in range(NParPostSamples):

#         if (NNInput.Model == 'PIP'):
#             for var in ['W1', 'W2', 'W3', 'b1', 'b2', 'b3', 'Sigma']:

#                 sample_arr      = numpy.atleast_1d(ADVITrace[var][NTraceADVI-iSample-1])
#                 PathToADVImeans = PathToADVI + '/' + str(var) + '.csv.'  + str(iSample+1)
#                 numpy.savetxt(PathToADVImeans,    sample_arr, delimiter=",")

#         elif (NNInput.Model == 'ModPIP'):
#             for var in ['Lambda', 're', 'W1', 'W2', 'W3', 'b1', 'b2', 'b3', 'Sigma']:

#                 sample_arr      = numpy.atleast_1d(ADVITrace[var][NTraceADVI-iSample-1])
#                 PathToADVImeans = PathToADVI + '/' + str(var) + '.csv.'  + str(iSample+1)
#                 numpy.savetxt(PathToADVImeans,    sample_arr, delimiter=",")

#     print(('        Wrote Samples from ADVI reconstruction in Folder: ' + PathToADVI + '\n'))



def save_ADVI_reconstruction_LEPS(PathToADVI, ADVITrace, model):

    for var in ['De', 'beta', 're', 'k', 'b', 'Sigma']:

        mu_arr    = numpy.atleast_1d(numpy.mean(ADVITrace[var],axis=0))
        sigma_arr = numpy.atleast_1d(numpy.std(ADVITrace[var],axis=0))

        print(var,mu_arr,sigma_arr)

        PathToADVImeans = PathToADVI + '/' + str(var) + '_mu.csv'
        PathToADVIsds   = PathToADVI + '/' + str(var) + '_sd.csv'

        numpy.savetxt(PathToADVImeans,    mu_arr, delimiter=",")
        numpy.savetxt(PathToADVIsds,   sigma_arr, delimiter=",")

    print(('        Wrote means and sds from ADVI reconstruction in Folder: ' + PathToADVI + '\n'))



def save_to_plot(PathToLabels, DataType, xyData):
    
    with open(PathToLabels, 'w') as f:
        f.write('R1,R2,R3,EData,EIni,\n')
        numpy.savetxt(f, xyData, delimiter=",")

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))



def save_moments(PathToLabels, DataType, xyData):
    
    with open(PathToLabels, 'w') as f:
        f.write('R1,R2,R3,EData,EMean,ESD,EMinus,EPlus\n')
        numpy.savetxt(f, xyData, delimiter=",")

    #print(('        Wrote '+ DataType + ' Labels in File: ' + PathToLabels + '\n'))
