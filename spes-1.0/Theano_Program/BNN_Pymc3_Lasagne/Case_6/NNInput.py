import theano.tensor as T
import pymc3
import numpy
import lasagne

from DiatPot_O2_UMN import V_O2_UMN
from DiatPot_N2_DS  import V_N2_DS, V_N2_LeRoy

class NNInput(object):

    TrainFlg         = True
    TryNNFlg         = True
    ReadIniParamsFlg = False
    SaveInference    = False

    Machine = 'ENTROPY'
    if (Machine == 'MAC'):
        PathToSPES  = '/Users/sventuri/WORKSPACE/SPES/spes/'   
        NStepsADVI             = 500
        NTraceADVI             = 1000
        NParPostSamples        = 100
        NOutPostSamples        = 100
        PlotShow               = False
        AddNoiseToPredsFlg     = False
    elif (Machine == 'ENTROPY'):
        PathToSPES  = '/home/venturi/WORKSPACE/SPES/spes/'
        NStepsADVI             = 10000000
        NTraceADVI             = 0
        NParPostSamples        = 500
        NOutPostSamples        = 3000
        PlotShow               = False
        AddNoiseToPredsFlg     = False

    # System                 = 'N3'
    # iPES                   = '1'
    # DiatPot_Fun            = V_N2_DS
    # DiatPot_FunPrint       = V_N2_LeRoy
    # PreLogShift            = 1.0
    # PathToDataFldr         = PathToSPES + '/Data_PES/'  + System  + '/Triat_David/PES_' + iPES + '/'
    # AngVector              = [60.0,120.0,180.0] #[60]
    # AnglesCuts             = numpy.array([120.0])
    # RCuts                  = numpy.array([2.073808])
    System                 = 'O3'
    iPES                   = '9'
    DiatPot_Fun            = V_O2_UMN
    DiatPot_FunPrint       = V_O2_UMN
    PreLogShift            = +1.0
    PathToDataFldr         = PathToSPES + '/Data_PES/'  + System  + '/Triat/PES_' + iPES + '/'
    AngVector              = [60.0,110.0,116.75,170.0] #[60]
    AnglesCuts             = numpy.array([110.0,     170.0,    60.0,     116.75])
    RCuts                  = numpy.array([2.26767, 2.26767, 2.64562, 2.28203327])

    Model                  = 'ModPIP'
    BondOrderStr           = 'MorseFun'
    TwoLevelsFlg           = True
    if (Model=='ModPIP'):
        LayersName             = ['InputLayer',              'BondOrderLayer',                    'PIPLayer',              'HiddenLayer1',              'HiddenLayer2',                 'OutputLayer']
        ActFun                 = [              lasagne.nonlinearities.linear, lasagne.nonlinearities.linear, lasagne.nonlinearities.tanh, lasagne.nonlinearities.tanh, lasagne.nonlinearities.linear]
        NHid                   = [                                          3,                             6,                          10,                           10                              ]
        NLayers                = []
        LambdaVec              = numpy.array([[1.0, 1.0, 1.0],[1.0, 1.0, 1.0]])
        reVec                  = numpy.array([[1.0, 1.0, 0.0],[1.0, 1.0, 1.0]])
        BiasesFlg              = True
        PathToOutputFldr       = PathToSPES + '/../Output_TESTS/Case_6/Pymc3/'
        PathToWeightFldr       = PathToSPES + '/../Output_' + Machine + '/ModPIP_Determ_' + str(NHid[2]) + '_' + str(NHid[3]) + '_Triat/' + System + '_' + iPES + '/'
    elif (Model=='ModPIPPol'):
        LayersName             = ['InputLayer', 'BondOrderLayer', 'PolLayer']
        NLayers                = [3,1,1]
        LambdaVec              = numpy.array([[1.0, 1.0, 1.0],[1.0, 1.0, 1.0]])
        reVec                  = numpy.array([[0.0, 0.0, 0.0],[0.0, 0.0, 0.0]])
        NOrd                   = 10
        BiasesFlg              = False
        PathToOutputFldr       = PathToSPES + '/../Output_' + Machine + '/ModPIPPol_Stoch_' + str(NOrd) + '_Triat/' + System + '_' + iPES + '/'
        PathToWeightFldr       = PathToSPES + '/../Output_' + Machine + '/ModPIPPol_Stoch_' + str(NOrd) + '_Triat/' + System + '_' + iPES + '/'
    elif (Model=='PIP'):
        LayersName             = ['InputLayer',              'HiddenLayer1',              'HiddenLayer2',                 'OutputLayer']
        ActFun                 = [              lasagne.nonlinearities.tanh, lasagne.nonlinearities.tanh, lasagne.nonlinearities.linear]
        NHid                   = [                                       10,                          10                               ]
        NLayers                = []
        LambdaVec              = numpy.array([[1.0, 1.0, 1.0],[1.0, 1.0, 1.0]])
        reVec                  = numpy.array([[0.0, 0.0, 0.0],[0.0, 0.0, 0.0]])
        BiasesFlg              = True
        PathToOutputFldr       = PathToSPES + '/../Output_' + Machine + '/PIP_Stoch_' + str(NHid[0]) + '_' + str(NHid[1]) + '_Triat/' + System + '_' + iPES + '/'
        PathToWeightFldr       = PathToSPES + '/../Output_' + Machine + '/PIP_Stoch_' + str(NHid[0]) + '_' + str(NHid[1]) + '_Triat/' + System + '_' + iPES + '/'
    elif (Model=='LEPS'):
        NLayers                = []
        DeVec                  = 9.9044
        betaVec                = 1.4223
        reVec                  = 2.0743
        k                      = -0.023
        PathToOutputFldr       = PathToSPES + '/../Output_' + Machine + '/LEPS_' + str(NHid[0]) + '_' + str(NHid[1]) + '_Triat/' + System + '_' + iPES + '/'
        PathToWeightFldr       = PathToSPES + '/../Output_' + Machine + '/LEPS_' + str(NHid[0]) + '_' + str(NHid[1]) + '_Triat/' + System + '_' + iPES + '/'

    NMiniBatch             = 0
    RandomizeDataFlg       = True
    NormalizedDataFlg      = False
    OnlyTriatFlg           = False
    MultErrorFlg           = True

    NIn                    = 3
    NOut                   = 1

    AbscissaConverter      = 1.0
    AddDiatPointsFlg       = False

    GenDataFlg             = 0#False
    OutputExpon            = 0#0.0
    Power                  = 0#5.0
    Shift                  = 0#7.27216

    if (System == 'O3') or (System == 'N3'):
        PIPTypeStr = 'PIP_A3'
    elif (System == 'CO2'):
        PIPTypeStr = 'PIP_A2B'

    def __init__(self,
                 TrainFlg,
                 System,
                 DiatPot_Fun,
                 Model,
                 LambdaVec,
                 reVec,
                 DeVec,
                 betaVec,
                 ki,
                 GenDataFlg,
                 PathToDataFldr,
                 PathToWeightFldr,
                 NIn, 
                 NOut, 
                 RandomizeDataFlg, 
                 NormalizedDataFlg,
                 ReadIniParamsFlg,
                 AngVector, 
                 LayersName,
                 NStepsADVI, 
                 NTraceADVI,
                 NApproxSamplesADVI,
                 NMiniBatch, 
                 NIterMax, 
                 NHid, 
                 NLayers, 
                 ActFun, 
                 PathToOutputFldr, 
                 TryNNFlg,
                 PlotShow,
                 NOutPostSamples,
                 ModPIPFlg,
                 OnlyTriatFlg,
                 MultErrorFlg,
                 PreLogShift,
                 iPES,
                 AnglesCuts,
                 RCuts,
                 OutputExpon,
                 AddDiatPointsFlg,
                 DiatPot_FunPrint,
                 BondOrderStr,
                 BiasesFlg,
                 AbscissaConverter, 
                 Shift, 
                 Power,
                 NBatchTrain,
                 TwoLevelsFlg, 
                 SaveInference):

            self.TrainFlg               = TrainFlg
            self.TryNNFlg               = TryNNFlg
            self.ReadIniParamsFlg       = ReadIniParamsFlg

            self.System                 = System
            self.iPES                   = iPES
            self.DiatPot_Fun            = DiatPot_FunPrint
            self.DiatPot_FunPrint       = DiatPot_FunPrint
            self.PreLogShift            = PreLogShift
            self.PathToDataFldr         = PathToDataFldr

            self.Model                  = Model
            self.BondOrderStr           = BondOrderStr
            self.LayersName             = LayersName
            self.ActFun                 = ActFun
            self.NHid                   = NHid
            self.NLayers                = NLayers
            self.LambdaVec              = LambdaVec
            self.reVec                  = reVec
            self.DeVec                  = DeVec
            self.betaVec                = betaVec
            self.k                      = k
            self.BiasesFlg              = BiasesFlg    
            self.PathToOutputFldr       = PathToOutputFldr    
            self.PathToWeightFldr       = PathToWeightFldr

            self.GenDataFlg             = GenDataFlg
            self.NIn                    = NIn
            self.NOut                   = NOut
            self.RandomizeDataFlg       = RandomizeDataFl
            self.NormalizedDataFlg      = NormalizedDataFlg
            
            self.NStepsADVI             = NStepsADVI
            self.NTraceADVI             = NTraceADVI
            self.NApproxSamplesADVI     = NApproxSamplesADVI
            self.NMiniBatch             = NMiniBatch
            
            self.PlotShow               = PlotShow
            self.NOutPostSamples        = NOutPostSamples

            self.OnlyTriatFlg           = OnlyTriatFlg
            self.MultErrorFlg           = MultErrorFlg
            self.AddDiatPointsFlg       = AddDiatPointsFlg

            self.OutputExpon            = OutputExpon
            self.Power                  = Power
            self.Shift                  = Shift

            self.AnglesCuts             = AnglesCuts
            self.RCuts                  = RCuts
            self.AngVector              = AngVector
            
            self.AbscissaConverter      = AbscissaConverter
            self.NBatchTrain            = 0

            self.TwoLevelsFlg           = TwoLevelsFlg

            self.SaveInference          = SaveInference
