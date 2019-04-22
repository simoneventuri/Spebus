close all
clear all
clc


global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples iFigure RFile SaveSampledOutputFlg ...
       alphaVec RCutsVec NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun NetworkType NOrd System ...
       DataShift AbscissaConverter MomentaFileName NN_Folder ComputeCut NSigma NSigmaInt alphaPlot NPlots TestFileName

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
FinalSample          = 10
NSamples             = FinalSample-StartSample+1;
NSigma               = 1  
SaveSampledOutputFlg = false
ComputeCut           = false

NSigmaInt            = 5.0

if strcmp(System,'N3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/Triat_David/PES_1/'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/ModPIP_Stoch_10_10_Triat/N3_1/'
  alphaPlot            = [60.0, 120.0, 180.0]
  alphaVec             = [60.0, 120.0, 180.0]
  RCutsVec             = [2.26767] * AbscissaConverter
  RMin                 = 2.073808
  DataShift         = 0.0;
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 30.0];
  PreLogShift          = 1.0
elseif strcmp(System,'O3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat/PES_9/'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/ModPIP_Stoch_10_10_Triat/O3_9/'
  alphaPlot            = [60,110,116.75,170]
  alphaVec             = [60,110,116.75,170]
  RCutsVec             = [2.64562, 2.26767, 2.28203327, 2.26767] * AbscissaConverter
  RMin                 = 2.2820248
  DataShift            = 5.303339519764099%26.3*0.04336411530877
  EGroupsVec           = [4.336, 8.673, 21.68, 43.364, 100.0];
  %EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 25.0, 30.0, 50.0, 100.0];
  PreLogShift          = -3.0
end

RStart               = 1.5
REnd                 = 10.0
NPoints              = 150

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING DATA
[NData, RData, EData, EFitted]        = ReadData();
[EDataDiat]                           = ComputeDiat(RData);
RRData                                = sqrt(RData(:,1).^2+RData(:,2).^2+RData(:,3).^2);
[Val,Idx]                             = max(RRData);
EAsymp                                = EData(Idx);             

NPlots = length(alphaPlot);
[RPlot, EDataPlot]                    = ReadPlotData();
for iPlot=1:NPlots
  RTemp                        = RPlot(:,:,iPlot);
  [EPlotDiat]                  = ComputeDiat(RTemp);
  EDataPlot(:,iPlot)           = EDataPlot(:,iPlot) + EPlotDiat;
  clear RTemp EPlotDiat
end

NCuts  = length(RCutsVec)
NPtCut = 1000;
[RCut, ECut, NPoitsVec, RCutPred]     = ReadCutData(NPtCut);
for iCut=1:NCuts
  RTemp                        = RCut(1:NPoitsVec(iCut),iCut);
  [ECutDiat]                   = ComputeDiat([RTemp,RTemp.*0.0+100.0,RTemp.*0.0+100.0,]);
  ECut(1:NPoitsVec(iCut),iCut) = ECut(1:NPoitsVec(iCut),iCut) + ECutDiat;
  clear RTemp ECutDiat
end


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
%EDataPred  = zeros(size(RData,1),NSamples);
EDataSum   = zeros(size(RData,1),1);
EDataSqSum = zeros(size(RData,1),1);
%EPlot      = zeros(size(RPlot,1),NPlots,NSamples);
EPlotSum   = zeros(size(RPlot,1),NPlots);
EPlotSqSum = zeros(size(RPlot,1),NPlots);
%ECut       = zeros(NPtCut,NCuts,NSamples);
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
  [EPred]              = ComputeOutput(RData, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
  %EDataPred(:,iSample) = EPred;
  EDataSum(:)          = EDataSum(:)   + EPred;
  EDataSqSum(:)        = EDataSqSum(:) + EPred.^2;
  
  % COMPUTING OUTPUT @ PLOTTING DATA
  RMaxVec              = [50.0, 50.0, 50.0];
  [PredShift]          = ComputeOutput(RMaxVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, 0.0);
  for iPlot=1:NPlots
    [EPred]                = ComputeOutput(RPlot(:,:,iPlot), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma) - DataShift;
    %EPlot(:,iPlot,iSample) = EPred;
    EPlotSum(:,iPlot)      = EPlotSum(:,iPlot)   + EPred;
    EPlotSqSum(:,iPlot)    = EPlotSqSum(:,iPlot) + EPred.^2;
    clear EPred
  end
  
  % COMPUTING OUTPUT @ CUT DATA
  for iCut=1:NCuts
    [EPred]                  = ComputeOutput(RCutPred(:,:,iCut), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
    %ECutPred(:,iCut,iSample) = EPred;
    ECutSum(:,iCut)          = ECutSum(:,iCut)   + EPred;
    ECutSqSum(:,iCut)        = ECutSqSum(:,iCut) + EPred.^2;
    clear EPred
  end
  
end
EDataMean =      EDataSum   ./ NSamples;
EDataSD   = sqrt(EDataSqSum ./ NSamples - (EDataMean).^2 );
for iPlot=1:NPlots
  EPlotMean(:,iPlot) =      EPlotSum(:,iPlot)   ./ NSamples;
  EPlotSD(:,iPlot)   = sqrt(EPlotSqSum(:,iPlot) ./ NSamples - (EPlotMean(:,iPlot)).^2 );
end
for iCut=1:NCuts
  ECutMean(:,iCut)  =      ECutSum(:,iCut)   ./ NSamples;
  ECutSD(:,iCut)    = sqrt(ECutSqSum(:,iCut) ./ NSamples - (ECutMean(:,iCut)).^2 );
end 

%% PLOTTING DATA
EDataPred = 0.0;
[iFigure] = PlotScatterStoch(iFigure, RData, EData, EDataDiat, EFitted, EDataPred, EDataMean, EDataSD);

%% PLOT PLOT
WriteOutputStats(RPlot, EDataPlot, EPlotMean, EPlotSD);

%% PLOT CUT
ECutPred  = 0.0;
[iFigure] = PlotCutsStoch(iFigure, RCut, ECut, NPoitsVec, RCutPred, ECutPred, ECutMean, ECutSD);