import theano.tensor as T
import lasagne
import numpy
from DiatPot_O2_UMN import V_O2_UMN
from DiatPot_N2_DS  import V_N2_DS, V_N2_LeRoy

class NNInput(object):

    TrainFlg               = True
    GetIniWeightsFlg       = 0
    TryNNFlg               = 0
    WriteFinalFlg          = 1         # Int Flag for Writing Parameters; =0: only at the end; =1: only .npz format at each improved iter; =2 .npz and .csv at each improved iter

    Machine = 'ENTROPY'
    if (Machine == 'MAC'):
        PathToSPES  = '/Users/sventuri/WORKSPACE/SPES/spes/'   
    elif (Machine == 'ENTROPY'):
        PathToSPES  = '/home/venturi/WORKSPACE/SPES/spes/'

    # System                 = 'N3'
    # iPES                   = '1'
    # DiatPot_Fun            = V_N2_DS
    # DiatPot_FunPrint       = V_N2_LeRoy
    # PreLogShift            = 1.0
    # PathToDataFldr         = PathToSPES + '/Data_PES/'  + System  + '/Triat_David/PES_' + iPES + '/'
    System                 = 'O3'
    iPES                   = '9'
    DiatPot_Fun            = V_O2_UMN
    DiatPot_FunPrint       = V_O2_UMN
    PreLogShift            = 1.0
    PathToDataFldr         = PathToSPES + '/Data_PES/'  + System  + '/Triat/PES_' + iPES + '/'

    Model                  = 'ModPIP'
    BondOrderStr           = 'MorseFun'
    if (Model=='ModPIP'):
        LayersName             = ['InputLayer',              'BondOrderLayer',                    'PIPLayer',              'HiddenLayer1',              'HiddenLayer2',                 'OutputLayer']
        ActFun                 = [              lasagne.nonlinearities.linear, lasagne.nonlinearities.linear, lasagne.nonlinearities.tanh, lasagne.nonlinearities.tanh, lasagne.nonlinearities.linear]
        NHid                   = [                                          3,                             6,                          10,                          10                               ]
        NLayers                = []
        Lambda                 = numpy.array([[1.0, 1.0, 1.0],[1.0, 1.0, 1.0]])
        re                     = numpy.array([[1.0, 1.0, 0.0],[1.0, 1.0, 1.0]])
        BiasesFlg              = True
        PathToOutputFldr       = PathToSPES + '/../Output_FINAL/Case_2/Theano/'
        PathToWeightFldr       = PathToSPES + '/../Output_FINAL/Case_2/Theano/'
    elif (Model=='ModPIPPol'):
        LayersName             = ['InputLayer', 'BondOrderLayer', 'PolLayer']
        NLayers                = [3,1,1]
        Lambda                 = numpy.array([[1.0, 1.0, 1.0],[1.0, 1.0, 1.0]])
        re                     = numpy.array([[0.0, 0.0, 0.0],[0.0, 0.0, 0.0]])
        NOrd                   = 10
        BiasesFlg              = False
        PathToOutputFldr       = PathToSPES + '/../Output_' + Machine + '/ModPIPPol_Determ_' + str(NOrd) + '_Triat/' + System + '_' + iPES + '/'
        PathToWeightFldr       = PathToSPES + '/../Output_' + Machine + '/ModPIPPol_Determ_' + str(NOrd) + '_Triat/' + System + '_' + iPES + '/'
    elif (Model=='PIP'):
        LayersName             = ['InputLayer',              'HiddenLayer1',              'HiddenLayer2',                 'OutputLayer']
        ActFun                 = [              lasagne.nonlinearities.tanh, lasagne.nonlinearities.tanh, lasagne.nonlinearities.linear]
        NHid                   = [                                       30,                          20                               ]
        NLayers                = []
        Lambda                 = numpy.array([[1.0, 1.0, 1.0],[1.0, 1.0, 1.0]])
        re                     = numpy.array([[0.0, 0.0, 0.0],[0.0, 0.0, 0.0]])
        BiasesFlg              = True
        PathToOutputFldr       = PathToSPES + '/../Output_' + Machine + '/PIP_Determ_' + str(NHid[0]) + '_' + str(NHid[1]) + '_Triat/' + System + '_' + iPES + '/'
        PathToWeightFldr       = PathToSPES + '/../Output_' + Machine + '/PIP_Determ_' + str(NHid[0]) + '_' + str(NHid[1]) + '_Triat/' + System + '_' + iPES + '/'
 
    GenDataFlg             = False
    NIn                    = 3
    NOut                   = 1
    PercTrain              = 0.80
    PercValid              = 0.20
    RandomizeDataFlg       = 2
    NormalizeDataFlg       = False
    CheckpointPath         = PathToOutputFldr + '/training_1/cp.ckpt'    

    NEpoch                 = 30000
    NMiniBatch             = 30
    fvalid                 = -2
    NIterMax               = 10000000000
    NPatience              = 1000000   
    NDeltaPatience         = 2        
    ImpThold               = 0.995    
    NoiseFlg               = 0
    NoiseSigma             = 0.01

    Method                 = 'adam'   # nesterov, rmsprop, adamax, amsgrad, adadelta
    LearningRate           = 1.e-4
    kMomentum              = 0.9
    EarlyStoppingFlg       = False
    RMSProp                = [0.85, 0.1]
    kWeightDecay           = [0.0, 1.e-5]

    LossFunction           = 'squared_error' # squared_error, normalized_squared_error, huber_loss, weighted_squared_error
    OutputExpon            = 0.0
    Power                  = 5.0
    Shift                  = 7.27216

    OnlyTriatFlg           = False
    MultErrorFlg           = True
    AddDiatPointsFlg       = False

    #AngVector              = [60,80,100,120,140,160,180]
    AngVector              = [60]
    #AnglesCuts             = numpy.array([110.0,     170.0,    60.0,     116.75])
    #RCuts                  = numpy.array([2.26767, 2.26767, 2.64562, 2.28203327])
    AnglesCuts             = numpy.array([120.0])
    RCuts                  = numpy.array([2.073808])

    AbscissaConverter      = 1.0

    if (System == 'O3') or (System == 'N3'):
        PIPTypeStr = 'PIP_A3'
    elif (System == 'CO2'):
        PIPTypeStr = 'PIP_A2B'

    def __init__(self,
                 System,
                 DiatPot_Fun, 
                 Model,
                 Lambda,
                 re,
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
                 CheckpointPath,
                 Method,
                 LossFunction,
                 GetIniWeightsFlg,
                 PathToWeightFldr,
                 OnlyTriatFlg,
                 MultErrorFlg,
                 PreLogShift,
                 iPES,
                 AnglesCuts,
                 RCuts,
                 AddDiatPointsFlg,
                 OutputExpon,
                 BondOrderStr,
                 PIPTypeStr,
                 Power,
                 Shift,
                 BiasesFlg, 
                 DiatPot_FunPrint,
                 NOrd,
                 AbscissaConverter, 
                 NoiseFlg, 
                 NoiseSigma,
                 fvalid):
            
            self.Model                  = Model
            self.System                 = Sytem
            self.DiatPot_Fun            = DiatPot_Fun
            self.Lambda                 = Lambda
            self.re                     = re
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
            self.CheckpointPath         = PathToOutputFldr + '/training_1/cp.ckpt'
            self.PathToOutputFldr       = PathToOutputFldr
            self.TryNNFlg               = TryNNFlg
            self.GetIniWeightsFlg       = GetIniWeightsFlg
            self.PathToWeightFldr       = PathToWeightFldr
            self.OnlyTriatFlg           = OnlyTriatFlg
            self.MultErrorFlg           = MultErrorFlg
            self.PreLogShift            = PreLogShift
            self.AnglesCuts             = AnglesCuts
            self.RCuts                  = RCuts
            self.iPES                   = iPES
            self.AddDiatPointsFlg       = AddDiatPointsFlg
            self.OutputExpon            = OutputExpon
            self.BondOrderStr           = BondOrderStr
            self.PIPTypeStr             = PIPTypeStr
            self.Shift                  = Shift
            self.Power                  = Power
            self.BiasesFlg              = BiasesFlg
            self.DiatPot_FunPrint       = DiatPot_FunPrint
            self.NOrd                   = NOrd
            self.AbscissaConverter      = AbscissaConverter
            self.NoiseFlg               = NoiseFlg 
            self.NoiseSigma             = NoiseSigma
            self.fvalid                 = fvalid