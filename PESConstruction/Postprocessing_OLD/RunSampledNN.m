%close all
clear all
clc

%% Parameters for Plots
global AxisFontSz AxisFontNm AxisLabelSz AxisLabelNm LegendFontSz LegendFontNm SaveFigs FigDirPath RedClr GreenClr iFigure

AxisFontSz   = 25;
AxisFontNm   = 'Arial';
AxisLabelSz  = 25;
AxisLabelNm  = 'Arial';
LegendFontSz = 25;
LegendFontNm = 'Arial';
SaveFigs     = 2
RedClr       = [190, 35, 30]./256
GreenClr     = [0.0, 0.498, 0.0]
iFigure      = 1000;


%% Variables for Postprocessing 
global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples ResultsFolder RFile SaveSampledOutputFlg ...
       alphaCutsVec RCutsVec TestFileName NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun ... 
       NetworkType NOrd System ShiftScatter AbscissaConverter alphaPlot DiatMin PIPFun RPlotFile ComputePlot ComputeScatter ComputeCut ...
       ShiftForError NPlots
     
     
System            = 'O3'    
MultErrorFlg      = true
OnlyTriatFlg      = true
BondOrderFun      = 'MorseFun'
PIPFun            = 'Simone'
NetworkType       = 'NN'
  NHL                  = [6,20,10,1];
  %NOrd                 = 10
PreLogShift       = 1

AbscissaConverter = 1.0;%0.529177
RFile             = 'home/venturi/WORKSPACE/Spebus/PESConstruction/AbInitio_Data/O3/UMN_AbInitio/Triat/PES_9' % Where to Find R.csv, EOrig.csv and EFitted.csv
Network_Folder    = '/home/venturi/WORKSPACE/Spebus_OUTPUT/Output_FINAL/PES9/TensorFlow/'                            % Where to Find Parameters
RPlotFile         = '/home/venturi/GoogleDrive/O3_PES9/Vargas/PlotPES/PES_1/'                                 % Where to Find PESFromGrid.csv.* and RECut.csv.*

ComputeScatter    = true  
  ShiftForError        = 26.3*0.04336411530877
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 25.0, 30.0, 50.0, 100.0, 1000.0]; %[4.336, 8.673, 21.68, 43.364, 100.0]

  
ComputePlot       = false
  alphaPlot            = [50:20:160] %[[35:5:175],[106.75:10:126.75]]
  RStart               = 1.5
  REnd                 = 10.0
  NPoints              = 150

 
ComputeCut       = false
  alphaCutsVec         = [60,110,116.75,170]
  RCutsVec             = [2.64562, 2.26767, 2.28203327, 2.26767] * AbscissaConverter
%%


%% Computing Remeaing Variables
NSamples = FinalSample-StartSample+1;

if strcmp(System,'N3')
  RMin           = 2.073808;
  [DiatMin, dE1] = N2_LeRoy(RMin);
  [DiatMax, dE1] = N2_LeRoy(100.0);
elseif strcmp(System,'O3')
  RMin           = 2.2820248;
  [DiatMin, dE1] = O2_UMN_Spebus(RMin);
  [DiatMax, dE1] = O2_UMN_Spebus(100.0);
end

FigDirPath = strcat(Network_Folder, '/Figs/')
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING DATA
fprintf("  Loading Ab Initio Data\n")
[NData, RData, EData, EFitted] = ReadData();
EData                          = EData;% + DiatMin;
EFitted                        = EFitted;
[EDataDiat]                    = ComputeDiat(RData);
RRData                         = sqrt(RData(:,1).^2+RData(:,2).^2+RData(:,3).^2);
[Val,Idx]                      = max(RRData);
EAsymp                         = EData(Idx);             
fprintf("  Loaded Ab Initio Data\n")


fprintf("  Loading Plotting Data\n")
NPlots = length(alphaPlot);
[RPlot, EDataPlot]   = ReadPlotData();
for iPlot=1:NPlots
  RTemp              = squeeze(RPlot(iPlot,:,:));
  [EPlotDiat]        = ComputeDiat(RTemp);
  EDataPlot(iPlot,:) = EDataPlot(iPlot,:);% + EPlotDiat' - DiatMin;
  clear RTemp EPlotDiat
end
fprintf("  Loaded Plotting Data\n")


fprintf("  Loading Cut Data\n")
NCuts  = length(RCutsVec)
NPtCut = 1000;
[RCut, ECut, EFittedCut, NPoitsVec, RCutPred] = ReadCutData(RData, EData, EFitted, NPtCut);
for iCut=1:NCuts
  RTemp                              = squeeze(RCut(iCut,1:NPoitsVec(iCut),1:3));
  [ECutDiat]                         = ComputeDiat(RTemp);
  ECut(iCut,1:NPoitsVec(iCut))       = ECut(iCut,1:NPoitsVec(iCut))       + ECutDiat';
  EFittedCut(iCut,1:NPoitsVec(iCut)) = EFittedCut(iCut,1:NPoitsVec(iCut)) + ECutDiat';
  clear RTemp ECutDiat
end
fprintf("  Loaded Cut Data\n")


%% LOADING PIP'S PARAMETERS
%[G_MEAN, G_SD] = ReadScales();
G_MEAN=0.0;G_SD=0.0;


%% LOADING NN's PARAMETERS
fprintf("  Reading Parameters\n")
if strcmp(NetworkType,'GP')
  [Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise] = ReadParametersGP();
else
  [Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det] = ReadParametersDeterm();
end
fprintf("  Read Parameters\n\n")

% %% CHECKING DERIVATIVES
% AngVec = [60.0,110,116.75,170];
% ComputePESDerivatives(AngVec, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0)


%% ADDING SHIFTS
fprintf("  Adding Shifts\n")
RMaxVec      = [RMin, 100.0, 100.0];
[Temp, PredAsympt] = ComputeOutput(RMaxVec, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);
% PredAsympt   = 0.0;
fprintf("  Added Shifts\n\n")


%% COMPUTING OUTPUT FOR SCATTER
[EDataPred, EDataPredTot] = ComputeOutput(RData, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);
EDataPredTot              = EDataPredTot - PredAsympt;

%% COMPUTING OUTPUT @ 3D VIEWS DATA
if (ComputePlot)
  EPredPlot = zeros(NPlots,size(RPlot,2));
  for iPlot=1:NPlots
    [Temp, EPredPlot(iPlot,:)] = ComputeOutput(squeeze(RPlot(iPlot,:,:)), Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);
    clear EPred
    EPredPlot(iPlot,:) = EPredPlot(iPlot,:) - PredAsympt;
  end
end
%%


%% COMPUTING OUTPUT @ CUT DATA
if (ComputeCut)
  ECutPred = zeros(NCuts,NPtCut);
  for iCut=1:NCuts
    [Temp, ECutPred(iCut,:)] = ComputeOutput(squeeze(RCutPred(iCut,:,:)), Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);
    clear EPred
    ECutPred(iCut,:) = ECutPred(iCut,:) - PredAsympt;
  end
end


%% PLOT scatter PLOTS
[iFigure] = PlotScatter(iFigure, RData, EData, EDataDiat, EFitted, EDataPred, EDataPredTot);


%% WRITING 3D VIEWS
if (ComputePlot)
  WriteOutput(RPlot, EDataPlot, EPredPlot);
end
%%

  
%% PLOTTING CUTS
if (ComputeCut)
  %ECutPred  = 0.0;
  [iFigure] = PlotCuts(iFigure, RCut, ECut, EFittedCut, NPoitsVec, RCutPred, ECutPred);
end
%%



%figure(100)
%PlotDiatomicPot(100, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0);


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