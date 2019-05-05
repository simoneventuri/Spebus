close all
clear all
clc

% N2 Min LeRoy @ 2.073808 (V=-9.8992982); N2 Min LeRoy @ 2.088828 (V=-9.3437497); difference in Minima 0.555545

global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples iFigure ResultsFolder RFile SaveSampledOutputFlg ...
       alphaVec RCutsVec TestFileName NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun NetworkType NOrd System ...
       ShiftScatter AbscissaConverter alphaPlot DiatMin PIPFun
     
System               = 'O3'    
AbscissaConverter    = 1.0;%0.529177

MultErrorFlg         = true
OnlyTriatFlg         = true
  
BondOrderFun         = 'MorseFun'
PIPFun               = 'Alberto'
NetworkType          = 'GP'
  %NOrd               = 10
  %NHL                = [6,10,10,1];
  
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
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat_Fake_10000Points/PES_9/'
  TestFileName         = 'RE.csv.60'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIP_Determ_10_10_Triat_FAKEFAKE/O3_9/'
  %Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/ModPIP_Stoch_10_10_Triat/O3_1/ParamsPosts/'
  %Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIPPol_Determ_10_Triat/O3_1'
  %alphaVec             = [110.0,     170.0,    60.0,     116.75]
  %RCutsVec             = [2.26767, 2.26767, 2.64562, 2.28203327]
  alphaPlot            = [[35:5:175],[106.75:10:126.75]]
  alphaVec             = [60,110,116.75,170]
  RCutsVec             = [2.64562, 2.26767, 2.28203327, 2.26767] * AbscissaConverter
  RMin                 = 2.2820248
  ShiftScatter         = 26.3*0.04336411530877
  %EGroupsVec           = [4.336, 8.673, 21.68, 43.364, 100.0];
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
%% LOADING LABELED DATA
[NData, RData, EData, EFitted]        = ReadData();
[EDataDiat]                           = ComputeDiat(RData);
RRData                                = sqrt(RData(:,1).^2+RData(:,2).^2+RData(:,3).^2);
%[Val,Idx]                             = max(RRData);
%EAsymp                                = EData(Idx);   
% [Val,Idx]                             = min(EData);
% EAsymp                                = Val;   
% EData = EData - EAsymp;
% [Val,Idx]                             = min(EFitted);
% EAsymp                                = Val;   
% EFitted = EFitted - EAsymp;


NPlots = length(alphaPlot);
[RPlot, EDataPlot]   = ReadPlotData();
for iPlot=1:NPlots
  RTemp              = squeeze(RPlot(iPlot,:,:));
  [EPlotDiat]        = ComputeDiat(RTemp);
  EDataPlot(iPlot,:) = EDataPlot(iPlot,:)+2.0.*DiatMin;% + EPlotDiat';
  clear RTemp EPlotDiat
end


%% LOADING PIP'S PARAMETERS
[G_MEAN, G_SD] = ReadScales();

%% LOADING GP's PARAMETERS
[Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise] = ReadParameters_GP();

%% CHECKING DERIVATIVES
%AngVec = [60.0,110,116.75,170];
%ComputePESDerivatives(AngVec, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 1.0)

% PLOT CUTS
[iFigure] = PlotCuts_GP(iFigure, G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise)

%% PLOT scatter PLOTS
[iFigure] = PlotScatter_GP(iFigure, RData, EData, EDataDiat, EFitted, G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise);

figure(100)
PlotDiatomicPot_GP(100, G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise);

%% ADDING DIATOMIC 
for iPlot=1:length(alphaPlot)
  ComputeOutputAtPlot_GP(iPlot, squeeze(RPlot(iPlot,:,:)), EDataPlot(iPlot,:), G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise);
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