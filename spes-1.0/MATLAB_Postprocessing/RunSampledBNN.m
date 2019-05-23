close all
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
iFigure      = 1;


%% Variables for Postprocessing 
global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples RFile SaveSampledOutputFlg ...
       alphaCutsVec RCutsVec NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun ...
       NetworkType NOrd System AbscissaConverter MomentaFileName NN_Folder ComputeCu NSigmaInt alphaPlot ...
       NPlots TestFileName DiatMin DiatMax CheckPostVec ShiftForError PIPFun RPlotFile ComputePlot ComputeScatter ComputeCut
     
System            = 'O3'    
MultErrorFlg      = true
OnlyTriatFlg      = true
BondOrderFun      = 'MorseFun'
PIPFun            = 'Simone'
NetworkType       = 'NN'
  NHL                  = [6,10,10,1];
  %NOrd                 = 10
PreLogShift       = +2


AbscissaConverter = 1.0;%0.529177
RFile             = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat/PES_9/'                                                    % Where to Find R.csv, EOrig.csv and EFitted.csv
Network_Folder    = '/Users/sventuri/WORKSPACE/SPES/Output_TESTS/Case_3/O3_9/'                                                        % Where to Find Parameters
RPlotFile         = '/Users/sventuri/GoogleDrive/O3_PES9/Vargas/PlotPES/PES_1/'                                                       % Where to Find PESFromGrid.csv.* and RECut.csv.*
  
  
UseSamplesFlg     = 3 % =0: Samples from Pymc3's Posteriors; =1: Computes Latin Hypercube Samples; =2: Reads Samples from Pymc3; =3: Max Posterior from Pymc3's Posteriors.
  StartSample          = 1
  FinalSample          = 1
  SaveSampledOutputFlg = false
  

ComputeScatter    = true  
  NSigmaInt            = 3.0
  CheckPostVec         = []%[100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]
  ShiftForError        = 26.3*0.04336411530877
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 25.0, 30.0, 50.0, 100.0]; %[4.336, 8.673, 21.68, 43.364, 100.0]

  
ComputePlot       = true
  alphaPlot            = [[35:5:175],[106.75:10:126.75]]
  RStart               = 1.5
  REnd                 = 10.0
  NPoints              = 150

  
ComputeCut       = true
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
  [DiatMin, dE1] = O2_UMN(RMin);
  [DiatMax, dE1] = O2_UMN(100.0);
end

FigDirPath = strcat(Network_Folder, '/Figs/')
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING DATA
[NData, RData, EData, EFitted] = ReadData();
EData                          = EData;
EFitted                        = EFitted;
[EDataDiat]                    = ComputeDiat(RData);
RRData                         = sqrt(RData(:,1).^2+RData(:,2).^2+RData(:,3).^2);
[Val,Idx]                      = max(RRData);
EAsymp                         = EData(Idx);             

NPlots = length(alphaPlot);
[RPlot, EDataPlot]   = ReadPlotData();
for iPlot=1:NPlots
  RTemp              = squeeze(RPlot(iPlot,:,:));
  [EPlotDiat]        = ComputeDiat(RTemp);
  EDataPlot(iPlot,:) = EDataPlot(iPlot,:);% + EPlotDiat' - DiatMin;
  clear RTemp EPlotDiat
end

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


%% LOADING PIP'S PARAMETERS
%[G_MEAN, G_SD] = ReadScales();
G_MEAN=0.0;G_SD=0.0;

%% LOADING PARAMETER'S POSTERIOR DISTRIBUTIONS
if (UseSamplesFlg < 2) || (UseSamplesFlg == 3)
  [Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD] = ReadParametersStats();
  %[iFigure] = PlotParametersPosterior(iFigure, Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD)
 
  NSamplesLHS  = FinalSample-StartSample+1;
  [LHSSamples, Lambda_LHS, re_LHS, W1_LHS, W2_LHS, W3_LHS, b1_LHS, b2_LHS, b3_LHS, Sigma_LHS] = ComputeLHS(NSamplesLHS, Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD);
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
Noise_Hist  = [];
EDataPred  = zeros(NSamples,size(RData,1));
EDataSum   = zeros(1,size(RData,1));
EDataSqSum = zeros(1,size(RData,1));
%EPlotPred  = zeros(NSamples,NPlots,size(RPlot,1));
EPlotSum   = zeros(NPlots,size(RPlot,2));
EPlotSqSum = zeros(NPlots,size(RPlot,2));
ECutPred   = zeros(NCuts,NSamples,NPtCut);
ECutSum    = zeros(NCuts,NPtCut);
ECutSqSum  = zeros(NCuts,NPtCut);
iSample    = StartSample;
while iSample <= FinalSample
  iSample
  
  
  %% OBTAINING PARAMETERS
  if (UseSamplesFlg == 3)
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ComputeParametersMaxPost(iSample, Lambda_MEAN, Lambda_SD, re_MEAN, re_SD, W1_MEAN, W1_SD, W2_MEAN, W2_SD, W3_MEAN, W3_SD, b1_MEAN, b1_SD, b2_MEAN, b2_SD, b3_MEAN, b3_SD, Sigma_MEAN, Sigma_SD, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist);
    Noise  = 0.0;
  
  elseif (UseSamplesFlg == 2)
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Noise, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist, Noise_Hist] = ReadParametersSamples(iSample, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist, Noise_Hist);
    Noise  = normrnd(0.0, Sigma);
  
  elseif (UseSamplesFlg == 1)
    Lambda = ones(3,1) .* Lambda_LHS(iSample);
    re     = ones(3,1) .* re_LHS(iSample);
    W1     = squeeze(W1_LHS(iSample,:,:));
    W2     = squeeze(W2_LHS(iSample,:,:));
    W3     = W3_LHS(iSample,:)';
    b1     = b1_LHS(iSample,:)';
    b2     = b2_LHS(iSample,:)';
    b3     = b3_LHS(iSample);
    Sigma  = Sigma_LHS(iSample);
    W1_Hist(iSample,:,:) = W1;
    W2_Hist(iSample,:,:) = W2;
    W3_Hist(iSample,:,:) = W3;
    b1_Hist(iSample,:)   = b1;
    b2_Hist(iSample,:)   = b2;
    b3_Hist(iSample,:)   = b3;
    Sigma_Hist(iSample)  = Sigma;
    Noise  = normrnd(0.0, Sigma);  
    %WriteSampledParams(OutputFolder, iSample, Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Noise);
    
  elseif (UseSamplesFlg == 0)
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ComputeParametersSamples(iSample, Lambda_MEAN, Lambda_SD, re_MEAN, re_SD, W1_MEAN, W1_SD, W2_MEAN, W2_SD, W3_MEAN, W3_SD, b1_MEAN, b1_SD, b2_MEAN, b2_SD, b3_MEAN, b3_SD, Sigma_MEAN, Sigma_SD, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist);
    Noise = normrnd(0.0, Sigma);
    %WriteSampledParams(OutputFolder, iSample, Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Noise);
    
  end
  %%
  
  
  %% CHECKING DERIVATIVES
  %AngVecCheckDer = [60.0,110,116.75,170];
  %ComputePESDerivatives(AngVecCheckDer, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, 0.0)
  %pause
  
  %% ADDING SHIFTS
  RMaxVec      = [RMin, 100.0, 100.0];
  [PredAsympt] = ComputeOutput(RMaxVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Noise);
  % PredAsympt   = 0.0;
  
  %% COMPUTING OUTPUT @ TRAINING DATA
  [EPred]              = ComputeOutput(RData, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Noise) - PredAsympt;
  EDataPred(iSample,:) = EPred;
  EDataSum(:)          = EDataSum(:)   + EPred;
  EDataSqSum(:)        = EDataSqSum(:) + EPred.^2;
  
  
  %% COMPUTING OUTPUT @ 3D VIEWS DATA
  if (ComputePlot)
    for iPlot=1:NPlots
      [EPred]                = ComputeOutput(squeeze(RPlot(iPlot,:,:)), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Noise) - PredAsympt;
      %EPlot(iSample,iPlot,:) = EPred;
      EPlotSum(iPlot,:)      = EPlotSum(iPlot,:)   + EPred';
      EPlotSqSum(iPlot,:)    = EPlotSqSum(iPlot,:) + EPred'.^2;
      clear EPred
    end
  end
  %%
  
  
  %% COMPUTING OUTPUT @ CUT DATA
  if (ComputeCut)
    for iCut=1:NCuts
      [EPred]                  = ComputeOutput(squeeze(RCutPred(iCut,:,:)), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Noise) - PredAsympt;
      ECutPred(iCut,iSample,:) = EPred';
      ECutSum(iCut,:)          = ECutSum(iCut,:)   + EPred';
      ECutSqSum(iCut,:)        = ECutSqSum(iCut,:) + EPred'.^2;
      clear EPred
    end
  end
  %%
  

  iSample = iSample+1;
end
iSample   = iSample - StartSample;
EDataMean =      EDataSum   ./ iSample;
EDataSD   = sqrt(EDataSqSum ./ iSample - (EDataMean).^2 );
for iPlot=1:NPlots
  EPlotMean(iPlot,:) =      EPlotSum(iPlot,:)   ./ iSample;
  EPlotSD(iPlot,:)   = sqrt(EPlotSqSum(iPlot,:) ./ iSample - (EPlotMean(iPlot,:)).^2 );
end
for iCut=1:NCuts
  ECutMean(iCut,:)  =      ECutSum(iCut,:)   ./ iSample;
  ECutSD(iCut,:)    = sqrt(ECutSqSum(iCut,:) ./ iSample - (ECutMean(iCut,:)).^2 );
end 


%% PLOTTING SCATTERS & COMPUTING ERROR
if (ComputeScatter)
  EDataPredTemp = 0.0;
  [iFigure] = PlotScatterStoch(iFigure, RData, EData, EDataDiat, EFitted, EDataPred, EDataMean, EDataSD);
end
%%

  
%% WRITING 3D VIEWS
if (ComputePlot)
  WriteOutputStats(RPlot, EDataPlot, EPlotMean, EPlotSD);
end
%%

  
%% PLOTTING CUTS
if (ComputeCut)
  %ECutPred  = 0.0;
  [iFigure] = PlotCutsStoch(iFigure, RCut, ECut, EFittedCut, NPoitsVec, RCutPred, ECutPred, ECutMean, ECutSD);
end
%%