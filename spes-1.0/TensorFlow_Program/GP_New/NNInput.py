import tensorflow as tf

class NNInput(object):

    Lambda                 = [1.0, 1.0, 1.0]

    TrainFlg               = True
    GetIniWeightsFlg       = False
    TryNNFlg               = True

    PathToSPES             = '/home/aracca/WORKSPACE/SPES/spes/'
    PathToDataFldr         = PathToSPES + '/Data_PES/N3/NASA_LH_NoDiat_1000/'
    PathToOutputFldr       = PathToSPES + '/../Output_DELL/GP/'
    PathToWeightFldr       = PathToSPES + '/../Output_DELL/GP'
    # PathToSPES             = '/Users/sventuri/WORKSPACE/SPES_Temp/spes/'
    # PathToDataFldr         = PathToSPES + '/Data_PES/N3/NASA_LH_5000/'
    # PathToOutputFldr       = PathToSPES + '/../Output_MAC/DetTF/N3/'
    # PathToWeightFldr       = PathToSPES + '/../Output_MAC/DetTF/N3/'
    AngVector              = [120]

    GenDataFlg             = False
    NIn                    = 3
    NOut                   = 1
    PercValid              = 0.09
    PercTest               = 0.08
    RandomizeDataFlg       = False
    NormalizeDataFlg       = False
    WriteFinalFlg          = 2          # Int Flag for Writing Parameters; =-1: never; =0: only at the end; =1: only .npz format, at each improved iter; =2 .npz and .csv
    CheckpointFilePath     = PathToOutputFldr + '/training_1/cp.ckpt'    
    CheckpointFldr         = PathToOutputFldr + '/training_1/'    

    NHid                   = [20, 20]
    NLayers                = []
    LossFunction           = 'rmse' # mse, rmse, rmsenorm, logcosh
    ActFun                 = [tf.nn.tanh, tf.nn.tanh]
    LayersName             = ['InputLayer', 'HiddenLayer1', 'HiddenLayer2']

    NIterations            = 800
    NMiniBatch             = 30
    NIterMax               = 10000000000
    NPatience              = 500       # look as this many examples regardless
    NDeltaPatience         = 2         # wait this much longer when a new best is found
    ImpThold               = 1.e-5     # a relative improvement of this much is considered significant

    Method                 = 'adadelta'   #  rmsprop, adadelta, adam, proximal
    LearningRate           = 1.0
    kMomentum              = 0.95
    EarlyStoppingFlg       = False
    RMSProp                = [0.75, 0.1]
    kWeightDecay           = [1.e-10, 1.e-10]

    def __init__(self, 
                 Lambda,
                 GenDataFlg,
                 PathToDataFldr,
                 AngVector,
                 NIn, 
                 NOut, 
                 PercValid, 
                 PercTest,
                 RandomizeDataFlg, 
                 NormalizeDataFlg,
                 WriteFinalFlg, 
                 LayersName,
                 NEpoch, 
                 NMiniBatch, 
                 NIterMax, 
                 NHid, 
                 NLayers, 
                 ActFun, 
                 LearningRate,
                 kMomentum, 
                 EarlyStoppingFlg, 
                 NPatience, 
                 NDeltaPatience, 
                 ImpThold, 
                 RMSProp, 
                 kWeightDecay, 
                 PathToOutputFldr, 
                 TryNNFlg,
                 CheckpointFldr,
                 CheckpointFilePath,
                 Method,
                 LossFunction,
                 GetIniWeightsFlg,
                 PathToWeightFldr):
            
            self.Lambda                 = Lambda
            self.GenDataFlg             = GenDataFlg
            self.PathToDataFldr         = PathToDataFldr
            self.AngVector              = AngVector
            self.NIn                    = NIn
            self.NOut                   = NOut
            self.PercValid              = PercValid
            self.PercTest               = PercTest
            self.RandomizeDataFlg       = RandomizeDataFl
            self.NormalizeDataFlg       = NormalizeDataFlg
            self.WriteFinalFlg          = WriteFinalFlg
            self.LayersName             = LayersName

            self.NEpoch                 = NEpoch
            self.NMiniBatch             = NMiniBatch
            self.NIterMax               = NIterMax
            self.NHid                   = NHid
            self.NLayers                = NLayers
            self.ActFun                 = ActFun
            self.LearningRate           = LearningRate
            self.kMomentum              = kMomentum
            self.EarlyStoppingFlg       = EarlyStoppingFlg
            self.NPatience              = NPatience
            self.NDeltaPatience         = NDeltaPatience
            self.ImpThold               = ImpThold
            self.LossFunction           = LossFunction

            self.Method                 = Method
            self.RMSProp                = RMSProp
            self.kWeightDecay           = kWeightDecay

            self.CheckpointFldr         = PathToOutputFldr + '/training_1/'
            self.CheckpointFilePath     = PathToOutputFldr + '/training_1/cp.ckpt'
            self.PathToOutputFldr       = PathToOutputFldr

            self.TryNNFlg               = TryNNFlg
            self.GetIniWeightsFlg       = GetIniWeightsFlg
            self.PathToWeightFldr       = PathToWeightFldr
