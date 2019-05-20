from __future__ import absolute_import, division, print_function

import numpy
import tensorflow as tf
print(tf.__version__)
from tensorflow import keras

from NNInputObj import NNInputObj
from LoadData   import load_data
from SaveData   import save_labels
from MLP        import build_MLP_model
from Plot       import plot_history, plot_try_set, plot_error


def sgd_optimization(NNInput):


    ##################################################################################################################################
    ### LOADING DATA
    ##################################################################################################################################
    print('\nLoading Data ... \n')

    if (NNInput.TryNNFlg):
        datasets, datasetsTry = load_data(NNInput)
        xSetTry,  ySetTry     = datasetsTry
        NTry                  = xSetTry.shape[0]
        NBatchTry             = NTry // NNInput.NMiniBatch
    else:
        datasets = load_data(NNInput)

    xSetTrainValid, ySetTrainValid = datasets[0]
    xSetTest,  ySetTest            = datasets[1]

    NNInput.NIn  = xSetTrainValid.shape[1]
    NNInput.NOut = ySetTrainValid.shape[1] 
    print(('    Nb of Input:  %i')    % NNInput.NIn)
    print(('    Nb of Output: %i \n') % NNInput.NOut)
    NNInput.NLayers = NNInput.NHid
    NNInput.NLayers.insert(0,NNInput.NIn)
    NNInput.NLayers.append(NNInput.NOut)

    NTrainValid = xSetTrainValid.shape[0]
    NTest       = xSetTest.shape[0]
    print(('    Nb of Training + Validation   Examples: %i')    % NTrainValid)
    print(('    Nb of Test                    Examples: %i \n') % NTest)
    if (NNInput.TryNNFlg):
        print(('    Nb of NTry                    Examples: %i \n')    % NTry)


    NBatchTrainValid = NTrainValid // NNInput.NMiniBatch
    print(('    Nb of Training + Validation  Batches: %i') % NBatchTrainValid)



    ######################
    # BUILD ACTUAL MODEL #
    ######################
    print('\nBuilding the Model ... \n')

    model = build_MLP_model(NNInput)
    model.summary()


    ###############
    # TRAIN MODEL #
    ###############
    print('\nTraining the Model ... \n')

    #early_stop  = keras.callbacks.EarlyStopping(monitor='val_loss', patience=NNInput.NPatience)
    cp_callback = tf.keras.callbacks.ModelCheckpoint(NNInput.CheckpointPath, save_weights_only=True, verbose=0)

    ### Training the NN
    history = model.fit(xSetTrainValid, ySetTrainValid, epochs=NNInput.NEpoch, validation_split=NNInput.PercValid, verbose=1, callbacks=[cp_callback])

    ### Plotting History
    plot_history(NNInput, history)

    [loss, mae] = model.evaluate(xSetTest, ySetTest, verbose=0)
    print("Testing set Mean Abs Error: ${:7.2f}".format(mae * 1000))

    
    ### Evaluating Model for a Particular Data-Set
    if (NNInput.TryNNFlg):
        yPredTry = model.predict(xSetTry)

        ### Saving Predicted Output
        PathToTryLabels = NNInput.PathToOutputFldr + '/yToCompare.csv'
        save_labels(PathToTryLabels, 'Generated', yPredTry)

        ### Plotting Results
        plot_try_set(NNInput, ySetTry, yPredTry)
        
        error = ySetTry - yPredTry
        plot_error(NNInput, error)



def evaluate_model(NNInput):

    datasets, datasetsTry = load_data(NNInput)
    xSetTry,  ySetTry     = datasetsTry
    NTry                  = xSetTry.shape[0]
    NBatchTry             = NTry // NNInput.NMiniBatch
    print(('    Nb of NTry:  %i')    % NTry)
    print(('    Nb of NBatchTry: %i \n') % NBatchTry)

    ### Evaluating Model for a Particular Data-Set
    model = build_MLP_model(NNInput)
    model.summary()
    model.load_weights(NNInput.CheckpointPath)
    yPredTry = model.predict(xSetTry)

    ### Saving Predicted Output
    PathToTryLabels = NNInput.PathToOutputFldr + '/yEvaluated.csv'
    save_labels(PathToTryLabels, 'Evaluated', yPredTry)

    ### Plotting Results
    plot_try_set(NNInput, ySetTry, yPredTry)
    
    error = ySetTry - yPredTry
    plot_error(NNInput, error)


######################################################################################################################################
### RUNNING
######################################################################################################################################
if __name__ == '__main__':

    if (NNInputObj.TrainFlg):
        sgd_optimization(NNInputObj)
    else:
        evaluate_model(NNInputObj)