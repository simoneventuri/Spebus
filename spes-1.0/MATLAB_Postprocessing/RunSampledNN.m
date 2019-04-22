close all
clear all
clc

% N2 Min LeRoy @ 2.073808 (V=-9.8992982); N2 Min LeRoy @ 2.088828 (V=-9.3437497); difference in Minima 0.555545

global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples iFigure ResultsFolder RFile SaveSampledOutputFlg ...
       alphaVec RCutsVec TestFileName NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun NetworkType NOrd System ...
       ShiftScatter AbscissaConverter

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


if strcmp(System,'N3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/Triat_David/PES_1/'
  TestFileName         = 'RE.csv.120'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIP_Determ_10_10_Triat/N3_1/'
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
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat/PES_9/'
  TestFileName         = 'RE.csv.60'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/ModPIP_Determ_10_10_Triat/O3_9/'
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
%% LOADING LABELED DATA
[NData, RData, EData, EFitted] = ReadData();
[EDataDiat]                    = ComputeDiat(RData);

%% LOADING PIP'S PARAMETERS
[G_MEAN, G_SD] = ReadScales();
%% LOADING NN's PARAMETERS
[Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det] = ReadParametersDeterm();

%% PLOT CUTS
% [iFigure] = PlotCuts(iFigure, G_MEAN, G_SD, Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det)

%% PLOT scatter PLOTS
[iFigure] = PlotScatter(iFigure, RData, EData, EDataDiat, EFitted, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det);

figure(100)
PlotDiatomicPot(100, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det);

%% ADDING DIATOMIC 
for iAng=alphaVec
  iAng
  ComputeOutputAtPlot(iAng, RLambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);
                      (iAng, R, E, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)
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