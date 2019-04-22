close all
clear all
clc


global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples iFigure RFile SaveSampledOutputFlg ...
       alphaVec RCutsVec TestFileName NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun NetworkType NOrd System ...
       ShiftScatter AbscissaConverter MomentaFileName NN_Folder ComputeCut NSigma

AbscissaConverter    = 1.0;%0.529177
     
System               = 'O3'    
 
NHL                  = [6,10,10,1];
MultErrorFlg         = true
OnlyTriatFlg         = true
  
BondOrderFun         = 'MorseFun'
NetworkType          = 'NN'
  NOrd               = 10
  
iFigure              = 1;
SaveSampledOutputFlg = true

UseSamplesFlg        = false
StartSample          = 1
FinalSample          = 100
NSamples             = FinalSample-StartSample+1;
NSigma               = 100  
SaveSampledOutputFlg = false
ComputeCut           = false

if strcmp(System,'N3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/Triat_David/PES_1/'
  TestFileName         = 'RE.csv.120'
  MomentaFileName      = 'PostFromSamples.csv.110'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/ModPIP_Stoch_10_10_Triat/N3_1/'
  %Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIPPol_Determ_13_Triat/N3_1/'
  %alphaVec             = [110.0,     170.0,    60.0,     116.75]
  %RCutsVec             = [2.26767, 2.26767, 2.64562, 2.28203327]
  alphaVec             = [60.0, 120.0, 180.0]
  RCutsVec             = [2.26767] * AbscissaConverter
  RMin                 = 2.073808
  ShiftScatter         = 0.0;
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 30.0];
  PreLogShift          = 1.0
elseif strcmp(System,'O3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat/PES_1/'
  TestFileName         = 'RE.csv.60'
  MomentaFileName      = 'yPred.csv.110'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIP_Stoch_Long_10_10_Triat/O3_1/'
  %Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIPPol_Determ_10_Triat/O3_1'
  %alphaVec             = [110.0,     170.0,    60.0,     116.75]
  %RCutsVec             = [2.26767, 2.26767, 2.64562, 2.28203327]
  alphaVec             = [60,110,116,170]
  RCutsVec             = [2.64562, 2.26767, 2.28203327, 2.26767] * AbscissaConverter
  RMin                 = 2.2820248
  ShiftScatter         = 26.3*0.04336411530877
  EGroupsVec           = [4.336, 8.673, 21.68, 43.364, 100.0];
  %EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 25.0, 30.0, 50.0, 100.0];
  PreLogShift          = -3.0
end

NCuts                = length(RCutsVec)
RStart               = 1.5
REnd                 = 10.0
NPoints              = 150

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING DATA
[NData, RData, EData, EFitted] = ReadData();
[EDataDiat]                    = ComputeDiat(RData);
[RPlot, EDataPlot]             = ReadPlotData();
NPlots = size(alphaVec,1);
%[RCut,  EDataCut]             = ReadCutData();
Ncuts  = 0;%size(RCutsVec,1);
NPtCut = 1;

%% LOADING PIP'S PARAMETERS
%[G_MEAN, G_SD] = ReadScales();
G_MEAN=0.0;G_SD=0.0;


%% LOADING PARAMETER'S POSTERIOR DISTRIBUTIONS
if (UseSamplesFlg == false)
  [Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD] = ReadParametersStats();
end

Lambda_Hist = [];
re_Hist     = [];
W1_Hist     = [];
W2_Hist     = [];
W3_Hist     = [];
b1_Hist     = [];
b2_Hist     = [];
b3_Hist     = [];
Sigma_Hist  = [];
EDataPred  = zeros(size(RData,1),NSamples);
EDataSum   = zeros(size(RData,1),1);
EDataSqSum = zeros(size(RData,1),1);
EPlot      = zeros(size(RPlot,1),NPlots,NSamples);
EPlotSum   = zeros(size(RPlot,1),NPlots);
EPlotSqSum = zeros(size(RPlot,1),NPlots);
ECut       = zeros(NPtCut,NCuts,NSamples);
ECutSum    = zeros(NPtCut,NCuts);
ECutSqSum  = zeros(NPtCut,NCuts);
for iSample = StartSample:FinalSample
  
  % OBTAINING PARAMETERS
  if (UseSamplesFlg)
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ReadParametersSamples(iSample, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist);
  else
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma] = ComputeParametersSamples(Lambda_MEAN, Lambda_SD, re_MEAN, re_SD, W1_MEAN, W1_SD, W2_MEAN, W2_SD, W3_MEAN, W3_SD, b1_MEAN, b1_SD, b2_MEAN, b2_SD, b3_MEAN, b3_SD, Sigma_MEAN, Sigma_SD);
  end
  
  % COMPUTING OUTPUT @ TRAINING DATA
  RMinVec              = [RMin, 50.0, 50.0];
  [PredShift]          = ComputeOutput(RMinVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, 0.0);
  [EPred]              = ComputeOutput(RData, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma) - PredShift;
  EDataPred(:,iSample) = EPred;
  EDataSum(:)          = EDataSum(:)   + EPred;
  EDataSqSum(:)        = EDataSqSum(:) + EPred.^2;
  
  % COMPUTING OUTPUT @ PLOTTING DATA
  for iPlot=1:NPlots
    [EPred]                = ComputeOutput(RPlot(:,:,iPlot), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
    EPlot(:,iPlot,iSample) = EPred;
    EPlotSum(:,iPlot)      = EPlotSum(:,iPlot)   + EPred;
    EPlotSqSum(:,iPlot)    = EPlotSqSum(:,iPlot) + EPred.^2;
    clear EPred
  end
  
  % COMPUTING OUTPUT @ CUT DATA
  for iCut=1:Ncuts
    [EPred]                = ComputeOutput(RCut(:,:,iCut), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
    ECut(:,iCut,iSample)   = EPred;
    ECutSum(:,iCut)        = ECutSum(:,iCut)   + EPred;
    ECutSqSum(:,iCut)      = ECutSqSum(:,iCut) + EPred.^2;
    clear EPred
  end
  
end
EDataMean =      EDataSum   ./ NSamples;
EDataSD   = sqrt(EDataSqSum ./ NSamples - (EDataMean).^2 );
for iPlot=1:NPlots
  EPlotMean(:,iPlot) =      EPlotSum(:,iPlot)   ./ NSamples;
  EPlotSD(:,iPlot)   = sqrt(EPlotSqSum(:,iPlot) ./ NSamples - (EPlotMean(:,iPlot)).^2 );
end
for iCut=1:Ncuts
  ECutMean(:,iCut)  =      ECutSum(:,iCut)   ./ NSamples;
  ECutSD(:,iCut)    = sqrt(ECutSqSum(:,iCut) ./ NSamples - (ECutMean(:,iCut)).^2 );
end 

%% SCATTER PLOT
[iFigure] = PlotScatterStoch(iFigure, RData, EData, EDataDiat, EFitted, EDataPred, EDataMean, EDataSD)





  %% COMPUTING ERROR
  %[RMSE, MUE] = ComputeError(NPointss, Rangee, EData, EPred)
  
  % SAVING SAMPLED OUTPUT
  if (SaveSampledOutputFlg)
    SaveSampledOutput(RTest, ETestData, EPred, iSample);
  end
  
  % COMPUTE CUT
  if (ComputeCut)
    [iFigure, ECutSum, ECutSumSqr] = ComputeCutsSample(iFigureTemp, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma, ECutSum, ECutSumSqr);
    iFigure = iFigureTemp + NCuts; 
  end







%% PLOTTING PARAMETER'S POSTERIORS
% if (UseSamplesFlg)
%   [iFigure] = PlotSampledParameters(iFigure, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist);
% else
%   [iFigure] = PlotParametersPosterior(iFigure, Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD);
% end

%% COMPUTING AND SAVING MOMENTA
SaveMomenta(RTest,ETestData, ETestSum, ETestSqrSum);

%% PLOTTING CUTS
if (ComputeCut)
  [iFigure] = PlotCuts(iFigureTemp, ECutSum, ECutSumSqr);
end

%% WRITING POINTS
WritePointsPerAngle(RData, EData)
WritePointsDiatPerAngle(RDiatData, EDiatData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%