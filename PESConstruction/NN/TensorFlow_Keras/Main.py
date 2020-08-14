from __future__ import absolute_import, division, print_function

import os
import numpy
from time import time
import tensorflow as tf
print(tf.__version__)

from NNInput         import NNInput
from LoadData        import load_data, abscissa_to_plot, load_parameters, load_parameters_PIP
from MLP             import build_MLP_model
from SaveData        import save_labels, save_parameters, save_parameters_NoBiases, save_parameters_PIP, save_to_plot
from Plot            import plot_history, plot_try_set, plot_error, plot_scatter, plot_overall_error, plot_set
from TransformOutput import InverseTransformation

def sgd_optimization(NNInput):


    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg > 0):
        datasets, datasetsTry = load_data(NNInput)
    else:
        datasets = load_data(NNInput)


    # RSetTrainValid, ySetTrainValid, ySetTrainValidDiat, ySetTrainValidTriat = datasets[0]
    # RSetTest,       ySetTest,       ySetTestDiat,       ySetTestTriat       = datasets[1]
    # RDataOrig,      yDataOrig,      yDataDiatOrig,      yDataTriatOrig      = datasets[2]

    # NNInput.NIn  = RSetTrainValid.shape[1]
    # NNInput.NOut = ySetTrainValid.shape[1] 
    # print(('  Nb of Input:  %i')    % NNInput.NIn)
    # print(('  Nb of Output: %i \n') % NNInput.NOut)

    # NNInput.NLayers = NNInput.NHid
    # NNInput.NLayers.insert(0,NNInput.NIn)
    # NNInput.NLayers.append(NNInput.NOut)
    # print('  Network Shape: ', NNInput.NLayers, '\n')

    # NTrainValid = RSetTrainValid.shape[0]
    # NTest       = RSetTest.shape[0]
    # print(('  Nb of Training + Validation Examples: %i')    % NTrainValid)
    # print(('  Nb of Test                  Examples: %i \n') % NTest)

    # NBatchTrainValid = NTrainValid // NNInput.NMiniBatch
    # print(('  Nb of Training + Validation Batches: %i') % NBatchTrainValid)


    RSetTrain, ySetTrain, ySetTrainDiat, ySetTrainTriat = datasets[0]
    RSetValid, ySetValid, ySetValidDiat, ySetValidTriat = datasets[1]
    RDataOrig, yDataOrig, yDataDiatOrig, yDataTriatOrig = datasets[2]

    NNInput.NIn  = RSetTrain.shape[1]
    #NNInput.NOut = ySetTrain.shape[1] 
    print(('  Nb of Input:  %i')    % NNInput.NIn)
    print(('  Nb of Output: %i \n') % 1)

    NNInput.NLayers = NNInput.NHid
    NNInput.NLayers.insert(0,NNInput.NIn)
    NNInput.NLayers.append(NNInput.NOut)
    print('  Network Shape: ', NNInput.NLayers, '\n')

    NTrain = RSetTrain.shape[0]
    NValid = RSetValid.shape[0]
    print('  Nb of Training + Validation Examples: ', NTrain + NValid, '; of which: ', NTrain, ' for Training and ', NValid, ' for Validation')
    #NTest  = RSetTest.shape[0]
    #print(('  Nb of Test                  Examples: %i \n') % NTest)



    ######################
    # BUILD ACTUAL MODEL #
    ######################
    print('\nBuilding the Model ... \n')

    model = build_MLP_model(NNInput)
    #model.summary()



    ###############
    # TRAIN MODEL #
    ###############

    early_stop   = tf.keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=NNInput.ImpThold, patience=NNInput.NPatience, restore_best_weights=True, verbose=1)

    WeightsPath  = NNInput.CheckpointFldr + '/weights.csv'
    mc_callback  = tf.keras.callbacks.ModelCheckpoint(filepath=NNInput.CheckpointFilePath, monitor='val_loss', save_best_only=True, save_weights_only=True, verbose=1)

    lr_callback  = tf.keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.7, patience=500, mode='auto', min_delta=1.e-6, cooldown=0, min_lr=1.e-8, verbose=1)

    tb_callback  = tf.keras.callbacks.TensorBoard(log_dir=NNInput.CheckpointFilePath, histogram_freq=100, batch_size=NNInput.NMiniBatch, write_graph=True, write_grads=True, write_images=True, embeddings_freq=0, embeddings_layer_names=None, embeddings_metadata=None, embeddings_data=None)

    callbacksVec = [mc_callback, early_stop, tb_callback]

    ### Training the NN
    print('\nTraining the Model ... \n')
    # history = model.fit(RSetTrainValid, ySetTrainValid, shuffle=True, batch_size=NNInput.NMiniBatch, epochs=NNInput.NEpoch, validation_split=NNInput.PercValid, verbose=1, callbacks=callbacksVec)
    xTrain = RSetTrain #tf.convert_to_tensor(RSetTrain, tf.float32)
    yTrain = ySetTrain #tf.convert_to_tensor(ySetTrain, tf.float32)
    xValid = RSetValid #tf.convert_to_tensor(RSetValid, tf.float32)
    yValid = ySetValid #tf.convert_to_tensor(ySetValid, tf.float32)
    history = model.fit(xTrain, yTrain, shuffle=True, batch_size=NNInput.NMiniBatch, epochs=NNInput.NEpoch, validation_data=(xValid, yValid), verbose=1, callbacks=callbacksVec)

    ### Plotting History
    #plot_history(NNInput, history)

    #ErrorTest = model.evaluate(RSetTest, ySetTest, verbose=1)
    #print("TensorBoard LogDir: ", NNInput.CheckpointFldr)

    
    model.load_weights(NNInput.CheckpointFilePath)
    jLayer = -1
    for iLayer in [1,3,4,5]:
        jLayer = jLayer+1
        Params = model.get_layer(index=jLayer).get_weights()
        PathToFldr = NNInput.PathToOutputFldr + NNInput.LayersName[iLayer] + '/'
        if not os.path.exists(PathToFldr):
            os.makedirs(PathToFldr)
        PathToFile = PathToFldr + 'Weights.npz'
        numpy.savez(PathToFile, Params[0], Params[1])
        if (NNInput.WriteFinalFlg > 0):
            if (jLayer==0): 
                save_parameters_PIP(PathToFldr, Params[0], Params[1])
            else:
                save_parameters(PathToFldr, Params[0], Params[1])


    yPredOrig   = model.predict(RDataOrig)
    yPredOrig   = InverseTransformation(NNInput, yPredOrig, yDataDiatOrig)
    plot_scatter(NNInput, yPredOrig, yDataOrig)



    ### Evaluating Model for a Particular Data-Set
    if (NNInput.TryNNFlg > 0):
        
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            xSetTry, ySetTry, ySetTryDiat, ySetTryTriat = datasetsTry[i]
            yPredTry = model.predict(xSetTry)
            yPredTry = InverseTransformation(NNInput, yPredTry, ySetTryDiat)
            ### Saving Predicted Output
            #PathToTryLabels = NNInput.PathToOutputFldr + '/yEvaluated.csv'
            #save_labels(PathToTryLabels, 'Generated', yPredTry)
            PathToAbscissaToPlot = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
            xPlot = abscissa_to_plot(PathToAbscissaToPlot)
            #PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestAll.csv.' + str(Ang)
            # ErrorAbs    =  ySetTry - yPredTry
            # ErrorRel    = (ySetTry - yPredTry) / ySetTry
            # AbsErrorAbs = abs(  ySetTry - yPredTry            )
            # AbsErrorRel = abs( (ySetTry - yPredTry) / ySetTry )
            save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry), axis=1))
            #save_to_plot_all(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry, ErrorAbs, ErrorRel, AbsErrorAbs, AbsErrorRel), axis=1))
            
            # ### Plotting Results
            # plot_try_set(NNInput, ySetTry, yPredTry)
    
        error = ySetTry - yPredTry
        plot_error(NNInput, error)



def evaluate_model(NNInput):

    
    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg > 0):
        datasets, datasetsTry = load_data(NNInput)
    else:
        datasets = load_data(NNInput)

    RSetTrainValid, ySetTrainValid, ySetTrainValidDiat, ySetTrainValidTriat = datasets[0]
    RSetTest,       ySetTest,       ySetTestDiat,       ySetTestTriat       = datasets[1]
    RDataOrig,      yDataOrig,      yDataDiatOrig,      yDataTriatOrig      = datasets[2]


    NNInput.NIn  = RSetTrainValid.shape[1]
    NNInput.NOut = ySetTrainValid.shape[1] 
    print(('  Nb of Input:  %i')    % NNInput.NIn)
    print(('  Nb of Output: %i \n') % NNInput.NOut)

    NNInput.NLayers = NNInput.NHid
    NNInput.NLayers.insert(0,NNInput.NIn)
    NNInput.NLayers.append(NNInput.NOut)
    print('  Network Shape: ', NNInput.NLayers, '\n')

    NTrainValid = RSetTrainValid.shape[0]
    NTest       = RSetTest.shape[0]
    print(('  Nb of Training + Validation Examples: %i')    % NTrainValid)
    print(('  Nb of Test                  Examples: %i \n') % NTest)

    NBatchTrainValid = NTrainValid // NNInput.NMiniBatch
    print(('  Nb of Training + Validation Batches: %i') % NBatchTrainValid)



    ######################
    # BUILD ACTUAL MODEL #
    ######################
    print('\nBuilding the Model ... \n')

    model = build_MLP_model(NNInput)
    #model.summary()

    

    ###############
    # TRAIN MODEL #
    ###############
    
    model.load_weights(NNInput.CheckpointFilePath)
    jLayer = -1
    for iLayer in [1,3,4,5]:
        jLayer = jLayer+1
        Params = model.get_layer(index=jLayer).get_weights()
        PathToFldr = NNInput.PathToOutputFldr + NNInput.LayersName[iLayer] + '/'
        if not os.path.exists(PathToFldr):
            os.makedirs(PathToFldr)
        PathToFile = PathToFldr + 'Weights.npz'
        numpy.savez(PathToFile, Params[0], Params[1])
        if (NNInput.WriteFinalFlg > 0):
            if (jLayer==0): 
                save_parameters_PIP(PathToFldr, Params[0], Params[1])
            else:
                save_parameters(PathToFldr, Params[0], Params[1])


    yPredOrig   = model.predict(RDataOrig)
    yPredOrig   = InverseTransformation(NNInput, yPredOrig, yDataDiatOrig)
    plot_scatter(NNInput, yPredOrig, yDataOrig)


    ### Evaluating Model for a Particular Data-Set
    if (NNInput.TryNNFlg > 0):
        
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            xSetTry, ySetTry, ySetTryDiat, ySetTryTriat = datasetsTry[i]
            yPredTry = model.predict(xSetTry)
            yPredTry = InverseTransformation(NNInput, yPredTry, ySetTryDiat)
            ### Saving Predicted Output
            #PathToTryLabels = NNInput.PathToOutputFldr + '/yEvaluated.csv'
            #save_labels(PathToTryLabels, 'Generated', yPredTry)
            PathToAbscissaToPlot = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
            xPlot = abscissa_to_plot(PathToAbscissaToPlot)
            #PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestAll.csv.' + str(Ang)
            # ErrorAbs    =  ySetTry - yPredTry
            # ErrorRel    = (ySetTry - yPredTry) / ySetTry
            # AbsErrorAbs = abs(  ySetTry - yPredTry            )
            # AbsErrorRel = abs( (ySetTry - yPredTry) / ySetTry )
            save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry), axis=1))
            #save_to_plot_all(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry, ErrorAbs, ErrorRel, AbsErrorAbs, AbsErrorRel), axis=1))
            
            # ### Plotting Results
            # plot_try_set(NNInput, ySetTry, yPredTry)
    
        error = ySetTry - yPredTry
        plot_error(NNInput, error)

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
