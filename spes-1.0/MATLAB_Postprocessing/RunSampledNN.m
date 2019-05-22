close all
clear all
clc

% N2 Min LeRoy @ 2.073808 (V=-9.8992982); N2 Min LeRoy @ 2.088828 (V=-9.3437497); difference in Minima 0.555545

global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples iFigure ResultsFolder RFile SaveSampledOutputFlg ...
       alphaVec RCutsVec TestFileName NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun NetworkType NOrd System ...
       ShiftScatter AbscissaConverter alphaPlot DiatMin PIPFun RPlotFile
     
System               = 'O3'    
AbscissaConverter    = 1.0;%0.529177

MultErrorFlg         = true
OnlyTriatFlg         = true
  
BondOrderFun         = 'MorseFun'
PIPFun               = 'Simone'
NetworkType          = 'NN'
  %NOrd               = 10
  NHL                  = [6,30,20,1];
  
iFigure              = 1;
SaveSampledOutputFlg = true


if strcmp(System,'N3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/Triat_David/PES_1/'
  TestFileName         = 'RE.csv.120'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIP_Determ_10_10_Triat/N3_1/'
  %Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIPPol_Determ_13_Triat/N3_1/'
  %alphaVec             = [110.0,     170.0,    60.0,     116.75]
  %RCutsVec             = [2.26767, 2.26767, 2.64562, 2.28203327]
  alphaPlot            = [60.0, 120.0, 180.0]
  alphaVec             = [60.0, 120.0, 180.0]
  RCutsVec             = [2.26767] * AbscissaConverter
  RMin                 = 2.073808
  ShiftScatter         = 0.0;
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 30.0];
  PreLogShift          = 1.0
elseif strcmp(System,'O3')
  RFile                = '/Users/sventuri/GoogleDrive/O3_PES9/AbInitioPoints/'
  RPlotFile            = '/Users/sventuri/GoogleDrive/O3_PES9/Vargas/PlotPES/PES_1/'
  TestFileName         = 'RE.csv.60'
  %Network_Folder       = '/Users/sventuri/GoogleDrive/O3_PES9/NeuralNetwork[10,10]/Calibrated_AbInitio/'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIP_Determ_30_20_Triat/O3_9_3020_m35_LogError_0005Noise/'
  %alphaVec             = [110.0,     170.0,    60.0,     116.75]
  %RCutsVec             = [2.26767, 2.26767, 2.64562, 2.28203327]
  alphaPlot            = [[35:5:175],[106.75:10:126.75]]
  alphaVec             = [60,110,116.75,170]
  RCutsVec             = [2.64562, 2.26767, 2.28203327, 2.26767] * AbscissaConverter
  RMin                 = 2.2820248
  ShiftScatter         = 26.3*0.04336411530877
  %EGroupsVec           = [4.336, 8.673, 21.68, 43.364, 200.0];
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 25.0, 30.0, 50.0, 100.0];
  PreLogShift          = -3.5
end

NCuts                = length(RCutsVec)
RStart               = 1.5
REnd                 = 10.0
NPoints              = 150


if strcmp(System,'N3')
  [DiatMin, dE1] = N2_LeRoy(RMin);
  %[DiatMin, dE1] = N2_MRCI(RMin)
elseif strcmp(System,'O3')
  [DiatMin, dE1] = O2_UMN(RMin);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING DATA
[NData, RData, EData, EFitted] = ReadData();
[EDataDiat]                    = ComputeDiat(RData);
RRData                         = sqrt(RData(:,1).^2+RData(:,2).^2+RData(:,3).^2);
[Val,Idx]                      = max(RRData);
EAsymp                         = EData(Idx);             

NPlots = length(alphaPlot);
[RPlot, EDataPlot]   = ReadPlotData();
for iPlot=1:NPlots
  RTemp              = squeeze(RPlot(iPlot,:,:));
  [EPlotDiat]        = ComputeDiat(RTemp);
  EDataPlot(iPlot,:) = EDataPlot(iPlot,:);% + EPlotDiat';
  clear RTemp EPlotDiat
end

% NCuts  = length(RCutsVec)
% NPtCut = 1000;
% [RCut, ECut, EFittedCut, NPoitsVec, RCutPred] = ReadCutData(NPtCut);
% for iCut=1:NCuts
%   RTemp                              = squeeze(RCut(iCut,1:NPoitsVec(iCut),1:3));
%   [ECutDiat]                         = ComputeDiat(RTemp);
%   ECut(iCut,1:NPoitsVec(iCut))       = ECut(iCut,1:NPoitsVec(iCut))       + ECutDiat';
%   EFittedCut(iCut,1:NPoitsVec(iCut)) = EFittedCut(iCut,1:NPoitsVec(iCut)) + ECutDiat';
%   clear RTemp ECutDiat
% end


%% LOADING PIP'S PARAMETERS
%[G_MEAN, G_SD] = ReadScales();

G_MEAN=[0,0,0];
G_SD=[1,1,1];
%% LOADING NN's PARAMETERS
if strcmp(NetworkType,'GP')
  [Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise] = ReadParametersGP();
else
  [Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det] = ReadParametersDeterm();
end


% %% CHECKING DERIVATIVES
% AngVec = [60.0,110,116.75,170];
% ComputePESDerivatives(AngVec, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0)

%% PLOT CUTS
% [iFigure] = PlotCuts(iFigure, G_MEAN, G_SD, Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det)

%% PLOT scatter PLOTS
[iFigure] = PlotScatter(iFigure, RData, EData, EDataDiat, EFitted, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);

figure(100)
PlotDiatomicPot(100, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);

%% ADDING DIATOMIC 
for iPlot=1:length(alphaPlot)
  ComputeOutputAtPlot(iPlot, squeeze(RPlot(iPlot,:,:)), EDataPlot(iPlot,:), Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);
end


% R = linspace(1.5,6.0,3000);
% [VOld,dV]=N2_MRCI(R);
% [VNew,dV]=N2_LeRoy(R);
% figure
% plot(R,VOld)
% hold on
% plot(R,VNew)

% R = linspace(1.5,15.0,3000);
% p = exp( - Lambda_Det(1) .* (R - re_Det(1)) - Lambda_Det(2) .* (R - re_Det(2)).^2 )';
% p = exp( - Lambda_Det(1) .* (R - re_Det(1)) )';
% figure(10)
% plot(R,p)

% NbVecs   = [0,1,2,3,4,6,7,9,11,13,15,17,19,21];
% iEnd   = 0;
% figure
% for iOrd=1:NOrd
%   iStart = iEnd   + 1;
%   iEnd   = iStart + NbVecs(iOrd) - 1;
%   Coeff  = W1_Det(iStart:iEnd);
%   hold on
%   plot(Coeff,'o');
% end