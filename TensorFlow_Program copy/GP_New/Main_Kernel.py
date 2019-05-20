from __future__ import absolute_import, division, print_function

import time
import os
import numpy as np
import tensorflow as tf
from tensorflow_probability import distributions as tfd
from tensorflow_probability import positive_semidefinite_kernels as tfk
print(tf.__version__)
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import scipy.linalg as sla

from NNInput    import NNInput
from LoadData   import load_data, abscissa_to_plot, load_labeled_input_, load_print_R
from SaveData   import save_labels, save_to_plot, save_parameters, save_to_plot_all, save_moments, save_der
from Plot       import plot_history, plot_try_set, plot_error

class InputTransformedKernel(tfk.PositiveSemidefiniteKernel):

  def __init__(self, kernel, transformation, name='InputTransformedKernel'):
    self._kernel = kernel
    self._transformation = transformation
    super(InputTransformedKernel, self).__init__(
        feature_ndims=kernel.feature_ndims,
        dtype=kernel.dtype,
        name=name)

  def apply(self, x1, x2):
    return self._kernel.apply(
        self._transformation(x1),
        self._transformation(x2))

  def matrix(self, x1, x2):
    return self._kernel.matrix(
        self._transformation(x1),
        self._transformation(x2))

  @property
  def batch_shape(self):
    return self._kernel.batch_shape

  def batch_shape_tensor(self):
    return self._kernel.batch_shape_tensor

class InputScaledKernel(InputTransformedKernel):

  def __init__(self, kernel, length_scales):
    self.kernel = kernel
    self.length_scales = length_scales
    super(InputScaledKernel, self).__init__(
        kernel,
        lambda x: x / tf.expand_dims(length_scales, -(kernel.feature_ndims + 1)))

  


def sgd_optimization(NNInput):


    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg):
        datasets, datasetsTry = load_data(NNInput)
    else:
        datasets = load_data(NNInput)

    xSetTrain, ySetTrain = datasets[0]

    NNInput.NIn  = xSetTrain.shape[1]
    NNInput.NOut = ySetTrain.shape[1] 
    print(('    Nb of Input:  %i')    % NNInput.NIn)
    print(('    Nb of Output: %i \n') % NNInput.NOut)

    NTrain = xSetTrain.shape[0]
    print(('    Nb of Training + Validation   Examples: %i')    % NTrain)
   
    # compute number of minibatches for training, validation and testing
    NNInput.NIn  = xSetTrain.shape[1]
    NNInput.NOut = ySetTrain.shape[1] 
    print(('    Nb of Input:  %i')    % NNInput.NIn)
    print(('    Nb of Output: %i \n') % NNInput.NOut)


    ############ GENERATE DATA #################################################################
    #### Multi-D ################################################################################

    sigma = np.float64(0.02)
    conf_priors = np.float64(np.array([[2., 2., 2.], [0.75, 0.75, 0.75]]))
    jitter = np.float64(1e-6)

    observation_index_points  = xSetTrain
    observations              = ySetTrain[:,0] + np.random.normal(np.float64(0), sigma, NTrain)

    amplitude                 = tf.exp(tf.Variable(np.float64(4)), name='amplitude')
    length_scale = (np.finfo(np.float64).tiny + tf.nn.softplus( tf.Variable([0.001, 0.001, 0.001], dtype=np.float64), name='length_scale'))
    #length_scales             = tf.exp(tf.get_variable("length_scale", dtype=tf.float64, initializer=tf.constant([np.float64(1), np.float64(1), np.float64(1)], dtype=tf.float64)))

    # Put Gamma prior on the length scales
    rv_scale = tfd.Gamma(concentration=conf_priors[0], rate=conf_priors[1], name='length_scale_prior')

    se_kernel = tfk.ExponentiatedQuadratic(amplitude)
    kernel    = InputScaledKernel(se_kernel, length_scale)

    observation_noise_variance = tf.exp(tf.Variable(np.float64(-4)), name='observation_noise_variance')

    # We'll use an unconditioned GP to train the kernel parameters.
    gp                 = tfd.GaussianProcess(kernel=kernel, index_points=observation_index_points, observation_noise_variance=observation_noise_variance)
    neg_log_likelihood = - gp.log_prob(observations) #- tf.reduce_sum(rv_scale.log_prob(length_scale)))

    optimizer = tf.train.AdamOptimizer(learning_rate=.08, beta1=.3, beta2=.99)    
    optimize  = optimizer.minimize(neg_log_likelihood)

    gprm = tfd.GaussianProcessRegressionModel(
        kernel                     = kernel,
        index_points               = np.ones((NTrain,3)),
        observation_index_points   = observation_index_points,
        observations               = observations,
        observation_noise_variance = observation_noise_variance)


    with tf.Session() as sess:
        sess.run(tf.global_variables_initializer())
        for i in range(NNInput.NIterations):
            _, lls_ = sess.run([optimize, neg_log_likelihood])
            if i % 100 == 0:
                print("Step {}: NLL = {}".format(i, lls_), "\n")
                print("Kernel Ampl  = ", sess.run(gprm.kernel.kernel.amplitude), "\n")
                print("Length Scale = ", sess.run(gprm.kernel.length_scales), "\n")
                STD = np.sqrt(sess.run(gprm.observation_noise_variance))
                print("Noise STD    = ", STD, "\n")
        length = sess.run(gprm.kernel.length_scales)
        amp    = sess.run(gprm.kernel.kernel.amplitude)
        noise  = sess.run(gprm.observation_noise_variance)
        # cov    = sess.run(gprm.kernel.matrix(observation_index_points, observation_index_points) + (gprm.observation_noise_variance + jitter)*tf.eye(NTrain, dtype=tf.float64))
        # print("Inverting Matrix.........")
        # LL     = tf.linalg.cholesky(gprm.kernel.matrix(observation_index_points, observation_index_points) + (gprm.observation_noise_variance + jitter)*tf.eye(NTrain, dtype=tf.float64))
        # L      = sess.run(LL)
        # L_inv  = sess.run(tf.linalg.inv(LL))
    

    cov        = np.float64(np.zeros((NTrain,NTrain)))
    Gamma      = np.float64(1/length**2)
    Gamma_diag = amp**2 * np.diag(Gamma)

    print(Gamma)
    print(length**2)

    for j in range(NTrain):
            for i in range(NTrain):

                norm = np.multiply(Gamma, observation_index_points[j,:] - observation_index_points[i,:])

                cov[i,j] = (amp**2) * np.exp( - np.dot(observation_index_points[j,:] - observation_index_points[i,:], norm) / (2) )

    cov = cov + (noise + jitter)*np.identity(NTrain)

    L = np.linalg.cholesky(cov)

    print(np.linalg.cond(cov))
    print(np.linalg.cond(L))

    
    # plt.figure(1)
    # plt.imshow(cov, cmap='hot', interpolation='nearest')
    # plt.figure(2)
    # plt.imshow(L, cmap='hot', interpolation='nearest')
    # plt.show()


    print("Predicting............")

    i=-1
    for Ang in NNInput.AngVector:
        i=i+1

        xSetTry,  ySetTry = datasetsTry[i]
        index_points      = xSetTry

        NTest = index_points.shape[0]
        print(('    Nb of Data Test:  %i') % NTest)

        print(ySetTry[:,0].shape)
        print(index_points[:,0].shape)

        k        = np.zeros(NTrain)
        k_der    = np.zeros((3,NTrain))
        Meann    = np.zeros(NTest)
        Mean_der = np.zeros((3,NTest))
        Varr     = np.zeros(NTest)
        Var_der  = np.zeros((NTest,3,3))
        temp1    = sla.solve_triangular(L,observations, lower=True)
        temp1    = sla.solve_triangular(L,temp1, lower=True, trans=1)
        p = 0

        start = time.time()
        
        for j in range(NTest):
            for i in range(NTrain):
                norm = np.multiply(Gamma, index_points[j,:] - observation_index_points[i,:])
                k[i] = (amp**2) * np.exp( - np.dot(index_points[j,:] - observation_index_points[i,:], norm) / (2) )
                k_der[:,i] = - np.multiply(Gamma, index_points[j,:] - observation_index_points[i,:]) * k[i]
            if j % 1000 == 0:
                print("iter  =======", j, "\n")
            Meann[p] = np.dot(k, temp1)
            Mean_der[:,p] = np.matmul(k_der, temp1)
            temp    = sla.solve_triangular(L, k, lower=True)
            Varr[p] = amp**2 - np.dot(temp, temp)
            #temp2   = sla.solve_triangular(L, np.transpose(k_der), lower=True)
            #Var_der[p,:,:] = Gamma_diag - np.matmul(temp2.T, temp2) 
            p       = p + 1
        

        end = time.time()
        print("TIME=============", end - start, "\n")
        
        Varr = np.sqrt(Varr)
        

        num_der_x = np.gradient(ySetTry[:,0], index_points[:,0])
        num_der_x = np.transpose(num_der_x[np.newaxis])
        num_der_y = np.gradient(ySetTry[:,0], index_points[:,1])
        num_der_y = np.transpose(num_der_y[np.newaxis])
        num_der_z = np.gradient(ySetTry[:,0], index_points[:,2])
        num_der_z = np.transpose(num_der_z[np.newaxis])

        sigma_p = Meann + 3*Varr
        sigma_m = Meann - 3*Varr
        # sigma_derxxp = Mean_der[0,:] + 3*np.sqrt(Var_der[:,0,0])
        # sigma_derxxm = Mean_der[0,:] - 3*np.sqrt(Var_der[:,0,0])
        # sigma_derxyp = Mean_der[0,:] + 3*Var_der[:,0,1]
        # sigma_derxym = Mean_der[0,:] - 3*Var_der[:,0,1]
        # sigma_deryxp = Mean_der[0,:] + 3*Var_der[:,1,0]
        # sigma_deryxm = Mean_der[0,:] - 3*Var_der[:,1,0]
        # sigma_deryyp = Mean_der[0,:] + 3*np.sqrt(Var_der[:,1,1])
        # sigma_deryym = Mean_der[0,:] - 3*np.sqrt(Var_der[:,1,1])

        print("Writing Predictions.......")

        xPrint  = load_print_R(NNInput, Ang)
        yMean   = np.transpose(Meann[np.newaxis])
        yStD    = np.transpose(Varr[np.newaxis])
        yMinus  = np.transpose(sigma_m[np.newaxis])
        yPlus   = np.transpose(sigma_p[np.newaxis])

        yMean_der_x = np.transpose(Mean_der[0,:][np.newaxis])

        PathToTryLabels = NNInput.PathToOutputFldr + '/OutputPosts/Post' + str(Ang) + '.csv'
        save_moments(PathToTryLabels, 'yPost', np.column_stack([xPrint, ySetTry, yMean, yStD, yMinus, yPlus]))
        print('Wrote Sampled yPost')

        PathToTryLabels_der = NNInput.PathToOutputFldr + '/OutputPosts/Post_der' + str(Ang) + '.csv'
        save_der(PathToTryLabels_der, 'yPost_der', np.column_stack([xPrint, num_der_x, yMean_der_x]))
        print('Wrote Sampled yPost_der')

        # PathToDer = './Der_3D.csv'
        # with open(PathToDer, 'w') as f:
        #         f.write('R1,R2,der_x,der_y, sigma_derxxp, sigma_derxxm, sigma_derxyp, sigma_derxym\n')
        #         np.savetxt(f, np.concatenate((index_points, np.transpose(Mean_der), np.transpose(sigma_derxxp[np.newaxis]), np.transpose(sigma_derxxm[np.newaxis]), np.transpose(sigma_derxyp[np.newaxis]), np.transpose(sigma_derxym[np.newaxis])), axis=1), delimiter=",")



######################################################################################################################################
### RUNNING
######################################################################################################################################
if __name__ == '__main__':

    if not os.path.exists(NNInput.PathToOutputFldr):
        os.makedirs(NNInput.PathToOutputFldr)

    if (NNInput.TrainFlg):
        sgd_optimization(NNInput)
    else:
        evaluate_model(NNInput)
