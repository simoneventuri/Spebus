close all
clear all
clc


global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples iFigure RFile SaveSampledOutputFlg ...
       alphaVec RCutsVec NCuts RStart REnd NPoints Network_Folder GP_Folder PES_Folder RMin EGroupsVec BondOrderFun NetworkType NOrd System ...
       DataShift AbscissaConverter MomentaFileName NN_Folder ComputeCut NSigma NSigmaInt alphaPlot NPlots TestFileName DiatMin CheckPostVec ...
       ShiftScatter

AbscissaConverter    = 1.0;%0.529177
     
System               = 'O3'    
 
NHL                  = [6,4,3,1];
MultErrorFlg         = true
OnlyTriatFlg         = true
  
BondOrderFun         = 'MorseFun'
NetworkType          = 'NN'
  NOrd               = 10
  
iFigure              = 1;

UseSamplesFlg        = 1
StartSample          = 1
FinalSample          = 300
NSamples             = FinalSample-StartSample+1;
NSigma               = 1  
SaveSampledOutputFlg = false
ComputeCut           = false

%CheckPostVec         = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]
CheckPostVec         = [100]

NSigmaInt            = 3.0

if strcmp(System,'N3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/Triat_David/PES_1/'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/ModPIP_Stoch_10_10_Triat/N3_1/'
  alphaPlot            = [60.0, 120.0, 180.0]
  alphaVec             = [60.0, 120.0, 180.0]
  RCutsVec             = [2.26767] * AbscissaConverter
  RMin                 = 2.073808
  DataShift            = 0.0;
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 30.0];
  PreLogShift          = 1.0
  ShiftScatter         = 0.0
elseif strcmp(System,'O3')
  RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat/PES_9/'
  Network_Folder       = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/ModPIP_Stoch_4_3_Triat_2Levels_Tris/O3_9/'
  alphaPlot            = [60,110,116.75,170]
  alphaVec             = [60,110,116.75,170]
  RCutsVec             = [2.64562, 2.26767, 2.28203327, 2.26767] * AbscissaConverter
  RMin                 = 2.2820248
  DataShift            = 5.303339519764099 %26.3*0.04336411530877
  ShiftScatter         = 26.3*0.04336411530877
  %EGroupsVec           = [4.336, 8.673, 21.68, 43.364, 100.0];
  EGroupsVec           = [2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 25.0, 30.0, 50.0, 100.0];
  PreLogShift          = -3.0
  OutputFolder         = '/Users/sventuri/WORKSPACE/CG-QCT/cg-qct/dtb/O3/PESs/BNN/PES9_AbInitio_4_3/CalibratedParams/'
end

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
[NData, RData, EData, EFitted]        = ReadData();
[EDataDiat]                           = ComputeDiat(RData);
RRData                                = sqrt(RData(:,1).^2+RData(:,2).^2+RData(:,3).^2);
[Val,Idx]                             = max(RRData);
EAsymp                                = EData(Idx);             

NPlots = length(alphaPlot);
[RPlot, EDataPlot]             = ReadPlotData();
for iPlot=1:NPlots
  RTemp                        = squeeze(RPlot(iPlot,:,:));
  [EPlotDiat]                  = ComputeDiat(RTemp);
  EDataPlot(iPlot,:)           = EDataPlot(iPlot,:) + EPlotDiat';
  clear RTemp EPlotDiat
end

NCuts  = length(RCutsVec)
NPtCut = 1000;
[RCut, ECut, EFittedCut, NPoitsVec, RCutPred] = ReadCutData(NPtCut);
for iCut=1:NCuts
  RTemp                        = squeeze(RCut(iCut,1:NPoitsVec(iCut),1:3));
  [ECutDiat]                   = ComputeDiat(RTemp);
  ECut(iCut,1:NPoitsVec(iCut))       = ECut(iCut,1:NPoitsVec(iCut))       + ECutDiat';
  EFittedCut(iCut,1:NPoitsVec(iCut)) = EFittedCut(iCut,1:NPoitsVec(iCut)) + ECutDiat';
  clear RTemp ECutDiat
end


%% LOADING PIP'S PARAMETERS
%[G_MEAN, G_SD] = ReadScales();
G_MEAN=0.0;G_SD=0.0;

%% LOADING PARAMETER'S POSTERIOR DISTRIBUTIONS
if (UseSamplesFlg < 2)
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
  
  %% OBTAINING PARAMETERS
  if (UseSamplesFlg == 2)
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ReadParametersSamples(iSample, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist);
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
    
%     W1(:,[1,4,6,7,9,10])   = 0.0d0;
%     W2(:,[1,4,6,7,8,9,10]) = 0.0d0;
%     b1([1,4,6,7,9,10])     = 0.0d0;
%     b2([1,4,6,7,8,9,10])   = 0.0d0;
%     W1(:,[1,3,4,6,10])     = 0.0d0;
%     W2(:,[4,5,6,7,8,9,10]) = 0.0d0;
%     b1([1,3,4,6,10])       = 0.0d0;
%     b2([4,5,6,7,8,9,10])   = 0.0d0;
    
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
  
  %% CHECKING DERIVATIVES
  % AngVecCheckDer = [60.0,110,116.75,170];
  % ComputePESDerivatives(AngVecCheckDer, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.0)
  
  %% ADDING SHIFTS
  RMaxVec      = [RMin, 100.0, 100.0];
  [PredAsympt] = ComputeOutput(RMaxVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Noise);
  % PredAsympt   = 0.0;
  
  %% COMPUTING OUTPUT @ TRAINING DATA
  [EPred]              = ComputeOutput(RData, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Noise);
  EDataPred(iSample,:) = EPred;
  EDataSum(:)          = EDataSum(:)   + EPred;
  EDataSqSum(:)        = EDataSqSum(:) + EPred.^2;
%   
%   %% COMPUTING OUTPUT @ 3D VIEWS DATA
%   for iPlot=1:NPlots
%     [EPred]                = ComputeOutput(squeeze(RPlot(iPlot,:,:)), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
%     %EPlot(iSample,iPlot,:) = EPred;
%     EPlotSum(iPlot,:)      = EPlotSum(iPlot,:)   + EPred';
%     EPlotSqSum(iPlot,:)    = EPlotSqSum(iPlot,:) + EPred'.^2;
%     clear EPred
%   end
%   
%   %% COMPUTING OUTPUT @ CUT DATA
%   for iCut=1:NCuts
%     [EPred]                  = ComputeOutput(squeeze(RCutPred(iCut,:,:)), Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Noise);
%     ECutPred(iCut,iSample,:) = EPred';
%     ECutSum(iCut,:)          = ECutSum(iCut,:)   + EPred';
%     ECutSqSum(iCut,:)        = ECutSqSum(iCut,:) + EPred'.^2;
%     clear EPred
%   end

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
EDataPredTemp = 0.0;
[iFigure] = PlotScatterStoch(iFigure, RData, EData, EDataDiat, EFitted, EDataPred, EDataMean, EDataSD);

%% WRITING 3D VIEWS
WriteOutputStats(RPlot, EDataPlot, EPlotMean, EPlotSD);

%% PLOTTING CUTS
%ECutPred  = 0.0;
[iFigure] = PlotCutsStoch(iFigure, RCut, ECut, EFittedCut, NPoitsVec, RCutPred, ECutPred, ECutMean, ECutSD);