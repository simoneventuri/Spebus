from __future__ import absolute_import, division, print_function

import os
import numpy
import tensorflow as tf
print(tf.__version__)
from tensorflow import keras as keras
from keras.utils import plot_model

from NNInput    import NNInput
from LoadData   import load_data, abscissa_to_plot, load_labeled_input_
from SaveData   import save_labels, save_to_plot, save_parameters, save_to_plot_all
from MLP        import build_MLP_model
from Plot       import plot_history, plot_try_set, plot_error
from LeRoy      import V_LeRoy

def sgd_optimization(NNInput):


    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg):
        datasets, datasetsTry = load_data(NNInput)
    else:
        datasets = load_data(NNInput)

    xSetTrainValid, ySetTrainValid = datasets[0]
    xSetTest,  ySetTest            = datasets[1]

    NNInput.NIn  = xSetTrainValid.shape[1]
    NNInput.NOut = ySetTrainValid.shape[1] 
    print(('    Nb of Input:  %i')    % NNInput.NIn)
    print(('    Nb of Output: %i \n') % NNInput.NOut)

    NTrainValid = xSetTrainValid.shape[0]
    NTest       = xSetTest.shape[0]
    print(('    Nb of Training + Validation   Examples: %i')    % NTrainValid)
    print(('    Nb of Test                    Examples: %i \n') % NTest)
   
    # compute number of minibatches for training, validation and testing
    NNInput.NIn  = xSetTrainValid.shape[1]
    NNInput.NOut = ySetTrainValid.shape[1] 
    print(('    Nb of Input:  %i')    % NNInput.NIn)
    print(('    Nb of Output: %i \n') % NNInput.NOut)
    NNInput.NLayers = NNInput.NHid
    NNInput.NLayers.insert(0,NNInput.NIn)
    NNInput.NLayers.append(NNInput.NOut)
    NBatchTrainValid = NTrainValid // NNInput.NMiniBatch
    print(('    Nb of Training + Validation  Batches: %i') % NBatchTrainValid)



    ######################
    # BUILD ACTUAL MODEL #
    ######################
    print('\nBuilding the Model ... \n')

    model = build_MLP_model(NNInput)
    model.summary()

    PathToFileWriter = NNInput.PathToOutputFldr + '/TB1.png'
    #plot_model(model, to_file=PathToFileWriter)
    #writer = tf.summary.FileWriter(PathToFileWriter)
    #writer.add_graph(sess.graph)


    ###############
    # TRAIN MODEL #
    ###############
    print('\nTraining the Model ... \n')
    early_stop  = keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=NNInput.ImpThold, patience=NNInput.NPatience)
    filepath = NNInput.CheckpointFldr + '/weights.{epoch:02d}-{val_loss:.2f}.csv',
    mc_callback = tf.keras.callbacks.ModelCheckpoint(filepath=NNInput.CheckpointFilePath, monitor='val_loss', save_best_only=True, save_weights_only=True, verbose=0)
    tb_callback = keras.callbacks.TensorBoard(log_dir=NNInput.CheckpointFldr, histogram_freq=100, batch_size=NNInput.NMiniBatch, write_graph=True, write_grads=True, write_images=True, embeddings_freq=0, embeddings_layer_names=None, embeddings_metadata=None, embeddings_data=None)
    lr_callback = keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=100, verbose=0, mode='auto', min_delta=0.0001, cooldown=0, min_lr=1.e-8)


    ### Training the NN
    history = model.fit(xSetTrainValid, ySetTrainValid, shuffle=True, batch_size=NNInput.NMiniBatch, epochs=NNInput.NEpoch, validation_split=NNInput.PercValid, verbose=1, callbacks=[mc_callback, early_stop, tb_callback, ])

    ### Plotting History
    #plot_history(NNInput, history)

    [loss, ErrorTest] = model.evaluate(xSetTest, ySetTest, verbose=1)
    print("Testing set Mean Abs Error: ${:7.2f}".format(ErrorTest))

    
    ### Evaluating Model for a Particular Data-Set
    if (NNInput.TryNNFlg):

        model.load_weights(NNInput.CheckpointFilePath)
        for iLayer in range(len(NNInput.LayersName)):

            Params = model.get_layer(index=iLayer).get_weights()

            PathToFldr = NNInput.PathToOutputFldr + NNInput.LayersName[iLayer] + '/'
            if not os.path.exists(PathToFldr):
                os.makedirs(PathToFldr)
            PathToFile = PathToFldr + 'Weights.npz'
            numpy.savez(PathToFile, Params[0], Params[1])

            if (NNInput.WriteFinalFlg > 1):
                save_parameters(PathToFldr, Params[0], Params[1])
        
        i=-1
        for Ang in NNInput.AngVector:
            i=i+1
            xSetTry, ySetTry = datasetsTry[i]
            yPredTry = model.predict(xSetTry)
            ### Saving Predicted Output
            #PathToTryLabels = NNInput.PathToOutputFldr + '/yEvaluated.csv'
            #save_labels(PathToTryLabels, 'Generated', yPredTry)
            PathToAbscissaToPlot = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
            xPlot = abscissa_to_plot(PathToAbscissaToPlot)
            #PathToTryLabels = NNInput.PathToOutputFldr + '/REBestDet.csv.' + str(Ang)
            PathToTryLabels = NNInput.PathToOutputFldr + '/REBestAll.csv.' + str(Ang)
            ErrorAbs    =  ySetTry - yPredTry
            ErrorRel    = (ySetTry - yPredTry) / ySetTry
            AbsErrorAbs = abs(  ySetTry - yPredTry            )
            AbsErrorRel = abs( (ySetTry - yPredTry) / ySetTry )
            #save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, yPredTry), axis=1))
            save_to_plot_all(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry, ErrorAbs, ErrorRel, AbsErrorAbs, AbsErrorRel), axis=1))
            
            # ### Plotting Results
            # plot_try_set(NNInput, ySetTry, yPredTry)
    
    error = ySetTry - yPredTry
    plot_error(NNInput, error)



def evaluate_model(NNInput):

    datasets, datasetsTry = load_data(NNInput)

    NNInput.NLayers = NNInput.NHid
    NNInput.NLayers.insert(0,NNInput.NIn)
    NNInput.NLayers.append(NNInput.NOut)

    ### Evaluating Model for a Particular Data-Set
    model = build_MLP_model(NNInput)
    model.summary()
    model.load_weights(NNInput.CheckpointFilePath)

    for iLayer in range(len(NNInput.LayersName)):

        Params = model.get_layer(index=iLayer).get_weights()

        PathToFldr = NNInput.PathToWeightFldr + NNInput.LayersName[iLayer] + '/'
        if not os.path.exists(PathToFldr):
            os.makedirs(PathToFldr)
        PathToFile = PathToFldr + 'Weights.npz'
        numpy.savez(PathToFile, Params[0], Params[1])

        if (NNInput.WriteFinalFlg > 1):
            save_parameters(PathToFldr, Params[0], Params[1])

    i=-1
    for Ang in NNInput.AngVector:
        i=i+1

        xSetTry,  ySetTry = datasetsTry[i]

        yPredTryTemp      = model.predict(xSetTry)
        
        PathToTryLabeledInput = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
        RSetTry               = load_labeled_input_(PathToTryLabeledInput)
        yPredTemp = numpy.concatenate( ( (V_LeRoy(RSetTry[:,0])[numpy.newaxis]).T, (V_LeRoy(RSetTry[:,1])[numpy.newaxis]).T, (V_LeRoy(RSetTry[:,2])[numpy.newaxis]).T ), axis=1)
        yPredTemp = (numpy.sum(yPredTemp, axis=1)[numpy.newaxis]).T

        yPredTry  = (yPredTemp-V_LeRoy(1.e10)) * 27.2113839712790 + 0.3554625704*27.2113839712790 +  yPredTryTemp
        
        ### Saving Predicted Output
        #PathToTryLabels = NNInput.PathToOutputFldr + '/yEvaluated.csv'
        #save_labels(PathToTryLabels, 'Generated', yPredTry)
        PathToAbscissaToPlot = NNInput.PathToDataFldr + '/R.csv.' + str(Ang)
        xPlot = abscissa_to_plot(PathToAbscissaToPlot)
        #PathToTryLabels = NNInput.PathToOutputFldr + '/REEvaluated.csv.' + str(Ang)
        PathToTryLabels = NNInput.PathToOutputFldr + '/REEvalAll.csv.' + str(Ang)
        ErrorAbs    =  ySetTry - yPredTry
        ErrorRel    = (ySetTry - yPredTry) / ySetTry
        AbsErrorAbs = abs(  ySetTry - yPredTry            )
        AbsErrorRel = abs( (ySetTry - yPredTry) / ySetTry )
        #save_to_plot(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, yPredTry), axis=1))
        save_to_plot_all(PathToTryLabels, 'Evaluated', numpy.concatenate((xPlot, ySetTry, yPredTry, ErrorAbs, ErrorRel, AbsErrorAbs, AbsErrorRel), axis=1))


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
