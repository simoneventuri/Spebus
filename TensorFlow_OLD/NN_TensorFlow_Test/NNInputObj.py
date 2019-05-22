import tensorflow as tf

class NNInputObj(object):

    TrainFlg               = True

    PathToDataFldr         = '/Users/sventuri/Dropbox/SPES/Data_Test/'
    PathToOutputFldr       = '/Users/sventuri/Dropbox/SPES/TensorFlow_Program/NN_Test/Output/'

    GenDataFlg             = False
    NIn                    = 5
    NOut                   = 3
    PercValid              = 0.1
    PercTest               = 0.05
    RandomizeDataFlg       = True

    NEpoch                 = 5
    NMiniBatch             = 100
    NIterMax               = 100000
    NHid                   = [10,30]
    NLayers                = []
    ActFun                 = [tf.nn.sigmoid, tf.nn.sigmoid]
    LearningRate           = 1.e-4
    kMomentum              = 0.9
    EarlyStoppingFlg       = True
    NPatience              = 1000000   # look as this many examples regardless
    NDeltaPatience         = 2         # wait this much longer when a new best is found
    ImpThold               = 0.995     # a relative improvement of this much is considered significant
    NesterovFlg            = True
    RMSProp                = [0.0, 1.0]
    kWeightDecay           = [0.0, 0.0]
    PrintScrFlg            = True
    NItersBeforePlot       = 500

    TryNNFlg               = True

    CheckpointPath         = PathToOutputFldr + '/training_1/cp.ckpt'

    def __init__(self, 
                 GenDataFlg,
                 PathToDataFldr,
                 NIn, 
                 NOut, 
                 PercValid, 
                 PercTest,
                 RandomizeDataFlg, 
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
                 NesterovFlg, 
                 RMSProp, 
                 kWeightDecay, 
                 PrintScrFlg, 
                 NItersBeforePlot, 
                 PathToOutputFldr, 
                 TryNNFlg,
                 CheckpointPath):
            
            self.GenDataFlg             = GenDataFlg
            self.PathToDataFldr         = PathToDataFldr
            self.NIn                    = NIn
            self.NOut                   = NOut
            self.PercValid              = PercValid
            self.PercTest               = PercTest
            self.RandomizeDataFlg       = RandomizeDataFlg
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
            self.NesterovFlg            = NesterovFlg
            self.RMSProp                = RMSProp
            self.kWeightDecay           = kWeightDecay
            self.PrintScrFlg            = PrintScrFlg
            self.NItersBeforePlot       = NItersBeforePlot

            self.CheckpointPath         = PathToOutputFldr + '/training_1/cp.ckpt'
            self.PathToOutputFldr       = PathToOutputFldr

            self.TryNNFlg               = TryNNFlg