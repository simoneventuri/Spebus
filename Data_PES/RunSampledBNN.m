close all
clear all
clc

global NHL MultErrorFlg OnlyTriatFlg PreLogShift UseSamplesFlg StartSample FinalSample NSamples iFigure ResultsFolder RFile SaveSampledOutputFlg ...
       alphaVec RCutsVec MomentaFileName NCuts RStart REnd NPoints NN_Folder GP_Folder PES_Folder TestFileName ComputeCut 

NHL                  = [3,20,10,1]
MultErrorFlg         = true
OnlyTriatFlg         = true
  PreLogShift        = 12.0
UseSamplesFlg        = false
StartSample          = 1
FinalSample          = 300
NSamples             = FinalSample-StartSample+1;
iFigure              = 1;
SaveSampledOutputFlg = false
ComputeCut           = false

ResultsFolder        = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/Stoch_NOBatch_ADA/O3_1/'
RFile                = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Diats+Triat/PES_1/'
TestFileName         = 'RE.csv.110'
MomentaFileName      = 'PostFromSamples.csv.110'

alphaVec             = [110.0,     170.0,    60.0,     116.75]
RCutsVec             = [2.26767, 2.26767, 2.64562, 2.28203327]
NCuts                = length(RCutsVec)
RStart               = 1.5
REnd                 = 10.0
NPoints              = 500

NN_Folder  = '/Users/sventuri/WORKSPACE/SPES/Output_ENTROPY/Determ_20_10_Batch20_NoWD/O3_1/'
GP_Folder  = '/Users/sventuri/Desktop/Oggi/'
PES_Folder = '/Users/sventuri/WORKSPACE/CG-QCT/run_O3_PlotPES/'
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING LABELED DATA
[NData, RData, EData, RTest, ETestData] = ReadData();
[RDiatData, EDiatData]                  = ReadDataDiat();

%% LOADING PIP'S PARAMETERS
[G_MEAN, G_SD] = ReadScales();

%% COMPUTING DETERMINISTIC OUTPUT
% [Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det] = ReadParametersDeterm();
% [EPred] = ComputeOutput(R, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det, 0.d0);
% SaveDetermOutput(R, EData, EPred)

%% LOADING PARAMETER'S POSTERIOR DISTRIBUTIONS
if (UseSamplesFlg == false)
  [Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD] = ReadParametersPostMomenta(ResultsFolder);
end

%% INITIALIZING ERROR
[NPointss, Rangee] = InitializeError(EData);

Lambda_Hist = [];
re_Hist     = [];
W1_Hist     = [];
W2_Hist     = [];
W3_Hist     = [];
b1_Hist     = [];
b2_Hist     = [];
b3_Hist     = [];
Sigma_Hist  = [];
EDataSum    = EData .* 0.0;
EDataSqrSum = EData .* 0.0;
ETestSum    = ETestData .* 0.0;
ETestSqrSum = ETestData .* 0.0;
ECutSum     = zeros(NPoints,NCuts);
ECutSumSqr  = zeros(NPoints,NCuts);
iFigureTemp = iFigure;
iFigureDiat = 100; 
figure(iFigure)
for iSample = StartSample:FinalSample
  
  % OBTAINING PARAMETERS
  if (UseSamplesFlg)
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ReadParametersSamples(ResultsFolder, iSample, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist);
  else
    [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma] = SampleParameters(Lambda_MEAN, Lambda_SD, re_MEAN, re_SD, W1_MEAN, W1_SD, W2_MEAN, W2_SD, W3_MEAN, W3_SD, b1_MEAN, b1_SD, b2_MEAN, b2_SD, b3_MEAN, b3_SD, Sigma_MEAN, Sigma_SD);
  end
  
  % COMPUTING OUTPUT
  %[EPred] = ComputeOutput(RData, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
  [EPred] = ComputeOutput(RTest, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
  %PlotDiatomicPot(iFigureDiat, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)

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
  
%   scatter(EData,EPred,10,'b','filled') 
%   hold on
%   EDataSum    = EDataSum    + EPred;
%   EDataSqrSum = EDataSqrSum + EPred.^2;  
  ETestSum    = ETestSum    + EPred;
  ETestSqrSum = ETestSqrSum + EPred.^2;
end

%% SCATTER PLOT
%[iFigure] = PlotScatter(iFigure, EData, EDataSum, EDataSqrSum)

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% READ PIP PARAMETERS
function [G_MEAN, G_SD] = ReadScales()

  global ResultsFolder

  %%% LOADING NETWORK PARAMETERS DISTRIBUTIONS
  filename = strcat(ResultsFolder,'/ScalingValues.csv')
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  ScalingValues = [dataArray{1:end-1}];
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  
  G_MEAN = ScalingValues(1,:);
  G_SD   = ScalingValues(2,:);

end


%% READ PARAMETERS' POSTERIORS
function [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ReadParametersSamples(ResultsFolder, iSample,  Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist)
  
  global NHL
  
  filename = strcat(ResultsFolder,'/ParamsPosts/Lambda.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  LambdaTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda = ones(3,1).*LambdaTemp;
  
  filename = strcat(ResultsFolder,'/ParamsPosts/re.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  reTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re = ones(3,1).*reTemp;
  
  
  filename = strcat(ResultsFolder,'/ParamsPosts/b1.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W1.csv.',num2str(iSample));
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(2)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W1 = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/b2.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W2.csv.',num2str(iSample));
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(3)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W2 = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/b3.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W3.csv.',num2str(iSample));
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(4)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W3 = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/Sigma.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Sigma = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
  
  Lambda_Hist(:,iSample) = Lambda;
  re_Hist(:,iSample)     = re;
  
  W1_Hist(:,:,iSample) = W1;
  W2_Hist(:,:,iSample) = W2;
  W3_Hist(:,:,iSample) = W3;
  
  b1_Hist(:,iSample)   = b1;
  b2_Hist(:,iSample)   = b2;
  b3_Hist(:,iSample)   = b3;
  
  Sigma_Hist(iSample)  = Sigma;
  
end


function [Lambda, re, W1, W2, W3, b1, b2, b3] = ReadParametersDeterm()
  
  global NHL NN_Folder
  
  filename = strcat(NN_Folder,'/PIPLayer/Lambda.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  LambdaTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda = ones(3,1).*LambdaTemp;
  
  filename = strcat(NN_Folder,'/PIPLayer/re.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  reTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re = ones(3,1).*reTemp;
  
  
  filename = strcat(NN_Folder,'/HiddenLayer1/b.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(NN_Folder,'/HiddenLayer1/W.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(2)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W1 = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(NN_Folder,'/HiddenLayer2/b.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(NN_Folder,'/HiddenLayer2/W.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(3)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W2 = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(NN_Folder,'/OutputLayer/b.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(NN_Folder,'/OutputLayer/W.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(4)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W3 = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
end


function [Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD] = ReadParametersPostMomenta(ResultsFolder)
  
  global NHL
  
  filename = strcat(ResultsFolder,'/ParamsPosts/Lambda_mu.csv')
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Lambda_MEAN_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda_MEAN = ones(3,1).*Lambda_MEAN_TEMP;

  filename = strcat(ResultsFolder,'/ParamsPosts/re_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  re_MEAN_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re_MEAN = ones(3,1).*re_MEAN_TEMP;


  filename = strcat(ResultsFolder,'/ParamsPosts/b1_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W1_mu.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(2)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W1_MEAN = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/b2_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W2_mu.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(3)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W2_MEAN = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/b3_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W3_mu.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(4)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W3_MEAN = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/Sigma_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Sigma_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
  

  filename = strcat(ResultsFolder,'/ParamsPosts/Lambda_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Lambda_SD_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda_SD = ones(3,1).*Lambda_SD_TEMP;
  
  filename = strcat(ResultsFolder,'/ParamsPosts/re_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  re_SD_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re_SD = ones(3,1).*re_SD_TEMP;  
  
  
  filename = strcat(ResultsFolder,'/ParamsPosts/b1_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W1_sd.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(2)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W1_SD = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/b2_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W2_sd.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(3)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W2_SD = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/b3_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(ResultsFolder,'/ParamsPosts/W3_sd.csv');
  delimiter = ',';
  formatSpec = '';
  for i = 1:NHL(4)
    formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  W3_SD = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;


  filename = strcat(ResultsFolder,'/ParamsPosts/Sigma_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Sigma_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
end


%% SAMPLE PARAMETERS' POSTERIORS
function [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma] = SampleParameters(Lambda_MEAN, Lambda_SD, re_MEAN, re_SD, W1_MEAN, W1_SD, W2_MEAN, W2_SD, W3_MEAN, W3_SD, b1_MEAN, b1_SD, b2_MEAN, b2_SD, b3_MEAN, b3_SD, Sigma_MEAN, Sigma_SD)

    Lambda = normrnd(Lambda_MEAN,Lambda_SD);
    re     = normrnd(re_MEAN,re_SD);

    W1    = normrnd(W1_MEAN,W1_SD);
    W2    = normrnd(W2_MEAN,W2_SD);
    W3    = normrnd(W3_MEAN,W3_SD);
  
    b1    = normrnd(b1_MEAN,b1_SD);
    b2    = normrnd(b2_MEAN,b2_SD);
    b3    = normrnd(b3_MEAN,b3_SD);

    Sigma = normrnd(Sigma_MEAN,Sigma_SD);
    
end 


%% PLOTTING PARAMETERS' POSTERIORS
function [iFigure] = PlotSampledParameters(iFigure, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist)
  
  NBins=30;
  
  figure(iFigure)
  histogram(Lambda_Hist,NBins);
  hold on
  iFigure = iFigure + 1;
  
  figure(iFigure)
  histogram(re_Hist,NBins);
  hold on
  iFigure = iFigure + 1;
  
  
  figure(iFigure)
  for i=1:size(W1_Hist,1)
    for j=1:size(W1_Hist,2)
      x = squeeze(W1_Hist(i,j,:));
      histogram(x,NBins);
      hold on
    end
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(W2_Hist,1)
    for j=1:size(W2_Hist,2)
      x = squeeze(W2_Hist(i,j,:));
      histogram(x,NBins);
      hold on
    end
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(W3_Hist,1)
    for j=1:size(W3_Hist,2)
      x = squeeze(W3_Hist(i,j,:));
      histogram(x,NBins);
      hold on
    end
  end
  iFigure = iFigure + 1;

  
  figure(iFigure)
  for i=1:size(b1_Hist,1)
    x = squeeze(b1_Hist(i,:));
    histogram(x,NBins);
    hold on
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(b2_Hist,1)
    x = squeeze(b2_Hist(i,:));
    histogram(x,NBins);
    hold on
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(b3_Hist,1)
    x = squeeze(b3_Hist(i,:));
    histogram(x,NBins);
    hold on
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  x = Sigma_Hist(:);
  histogram(x,NBins);
  hold on
  iFigure = iFigure + 1;
  
end


function [iFigure] = PlotParametersPosterior(iFigure, Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD)

  x=linspace(0.0,2.0,10000);
  figure(iFigure)
  plot(x,normpdf(x,Lambda_MEAN,Lambda_SD));
  hold on
  plot(x,normpdf(x,re_MEAN,re_SD));
  hold on
  iFigure = iFigure + 1;
  
  x=linspace(-5.0,5.0,10000);
  figure(iFigure)
  for i=1:size(W1_MEAN,1)
    for j=1:size(W1_MEAN,2)
      plot(x,normpdf(x,W1_MEAN(i,j),W1_SD(i,j)),'k');
      hold on
    end
  end
  for i=1:size(W2_MEAN,1)
    for j=1:size(W2_MEAN,2)
      plot(x,normpdf(x,W2_MEAN(i,j),W2_SD(i,j)),'r');
      hold on
    end
  end
  for i=1:size(W3_MEAN,1)
    for j=1:size(W3_MEAN,2)
      plot(x,normpdf(x,W3_MEAN(i,j),W3_SD(i,j)),'b');
      hold on
    end
  end
  iFigure = iFigure + 1;

  
  figure(iFigure)
  for i=1:size(b1_MEAN,1)
    plot(x,normpdf(x,b1_MEAN(i,j),b1_SD(i,j)),'k');
    hold on
  end
  for i=1:size(b2_MEAN,1)
    plot(x,normpdf(x,b2_MEAN(i,j),b2_SD(i,j)),'r');
    hold on
  end
  for i=1:size(b3_MEAN,1)
    plot(x,normpdf(x,b3_MEAN(i),b3_SD(i)),'b');
    hold on
  end
  iFigure = iFigure + 1;

  x=linspace(0.0,0.1,10000);
  figure(iFigure)
  plot(x,normpdf(x,Sigma_MEAN(i),Sigma_SD(i)));
  hold on
  iFigure = iFigure + 1;
  
end


%% LOADING LABELED DATA
function [NData, RData, EData, RTest, ETestData] = ReadData()

  global RFile TestFileName
  
  filename = strcat(RFile,'/R.csv');
  delimiter = ',';
  startRow = 2;
  formatSpec = '%s%s%s%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
  for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
  end
  numericData = NaN(size(dataArray{1},1),size(dataArray,2));
  for col=[1,2,3]
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
      regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
      try
        result = regexp(rawData{row}, regexstr, 'names');
        numbers = result.numbers;

        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if any(numbers==',');
          thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
          if isempty(regexp(numbers, thousandsRegExp, 'once'));
            numbers = NaN;
            invalidThousandsSeparator = true;
          end
        end
        % Convert numeric text to numbers.
        if ~invalidThousandsSeparator;
          numbers = textscan(strrep(numbers, ',', ''), '%f');
          numericData(row, col) = numbers{1};
          raw{row, col} = numbers{1};
        end
      catch me
      end
    end
  end
  R1 = cell2mat(raw(:, 1));
  R2 = cell2mat(raw(:, 2));
  R3 = cell2mat(raw(:, 3));
  clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
  RData = [R1, R2, R3];
  NData =size(RData,1);
  
  filename = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Diats+Triat/PES_1/EOrig.csv';
  delimiter = ' ';
  startRow = 2;
  formatSpec = '%s%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
  for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
  end
  numericData = NaN(size(dataArray{1},1),size(dataArray,2));
  rawData = dataArray{1};
  for row=1:size(rawData, 1);
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
      result = regexp(rawData{row}, regexstr, 'names');
      numbers = result.numbers;
      invalidThousandsSeparator = false;
      if any(numbers==',');
        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
        if isempty(regexp(numbers, thousandsRegExp, 'once'));
          numbers = NaN;
          invalidThousandsSeparator = true;
        end
      end
      if ~invalidThousandsSeparator;
        numbers = textscan(strrep(numbers, ',', ''), '%f');
        numericData(row, 1) = numbers{1};
        raw{row, 1} = numbers{1};
      end
    catch me
    end
  end
  EData = cell2mat(raw(:, 1));
  clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
  
  filename = strcat(RFile,'/',TestFileName);
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  R1 = dataArray{:, 1};
  R2 = dataArray{:, 2};
  R3 = dataArray{:, 3};
  ETestData = dataArray{:, 4};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  RTest = [R1, R2, R3];
  
end


function [RDataDiat, EDataDiat] = ReadDataDiat()

  filename = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Diats+Triat/PES_1/DiatPoints.csv';
  delimiter = ',';
  startRow = 2;

  %% Read columns of data as text:
  % For more information, see the TEXTSCAN documentation.
  formatSpec = '%s%s%s%[^\n\r]';

  %% Open the text file.
  fileID = fopen(filename,'r');

  %% Read columns of data according to the format.
  % This call is based on the structure of the file used to generate this
  % code. If an error occurs for a different file, try regenerating the code
  % from the Import Tool.
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

  %% Close the text file.
  fclose(fileID);

  %% Convert the contents of columns containing numeric text to numbers.
  % Replace non-numeric text with NaN.
  raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
  for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
  end
  numericData = NaN(size(dataArray{1},1),size(dataArray,2));

  for col=[1,2,3]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
      % Create a regular expression to detect and remove non-numeric prefixes and
      % suffixes.
      regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
      try
        result = regexp(rawData{row}, regexstr, 'names');
        numbers = result.numbers;

        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if any(numbers==',');
          thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
          if isempty(regexp(numbers, thousandsRegExp, 'once'));
            numbers = NaN;
            invalidThousandsSeparator = true;
          end
        end
        % Convert numeric text to numbers.
        if ~invalidThousandsSeparator;
          numbers = textscan(strrep(numbers, ',', ''), '%f');
          numericData(row, col) = numbers{1};
          raw{row, col} = numbers{1};
        end
      catch me
      end
    end
  end
  R1 = cell2mat(raw(:, 1));
  R2 = cell2mat(raw(:, 2));
  R3 = cell2mat(raw(:, 3));
  clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
  RDataDiat = [R1, R2, R3];
  
  [E1, dE1] = O2_UMN(R1);
  [E2, dE2] = O2_UMN(R2);
  [E3, dE3] = O2_UMN(R3);
  EDataDiat = E1 + E2 + E3;

end


%% PIP FUNCTIONS
function [G] = SymmetryFunctions_JG_1(R, Lambda, re)
  
  p1(:) = exp( - Lambda(1) .* (R(:,1) - re(1)) );
  p2(:) = exp( - Lambda(2) .* (R(:,2) - re(2)) );
  p3(:) = exp( - Lambda(3) .* (R(:,3) - re(3)) );

  G(:,1) = ( p1       + p2       + p3 );
  G(:,2) = ( p1 .* p2 + p2 .* p3 + p3 .* p1);  
  G(:,3) = ( p1 .* p2 .* p3);
  
end

function [G] = SymmetryFunctions_JG_2(R, Lambda, re)
  
  p1(:) = exp( - Lambda(1) .* (R(:,1) - re(1)) );
  p2(:) = exp( - Lambda(2) .* (R(:,2) - re(1)) );
  p3(:) = exp( - Lambda(3) .* (R(:,3) - re(1)) );

  G(:,1) = ( p1  + p2 ) ./ 2.d0;
  G(:,2) = ( p1 .* p2 );  
  G(:,3) = ( p3 );
  
end


%% COMPUTE OUTPUT
function [EPred] = ComputeOutput(R, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)

  global MultErrorFlg OnlyTriatFlg PreLogShift
  
  NData = size(R,1);
  
  G = SymmetryFunctions_JG_1(R, Lambda, re);
  
  G(:,1) = (G(:,1) - G_MEAN(1)) ./ G_SD(1);
  G(:,2) = (G(:,2) - G_MEAN(2)) ./ G_SD(2);
  G(:,3) = (G(:,3) - G_MEAN(3)) ./ G_SD(3);
  
  b1Mat = repmat(b1',[NData,1]);
  b2Mat = repmat(b2',[NData,1]);
  b3Mat = repmat(b3',[NData,1]);
  
  z1     = G * W1 + b1Mat;
  y1     = tanh(z1);
  z2     = y1 * W2 + b2Mat;
  y2     = tanh(z2);
  EPred  = y2 * W3 + b3Mat;
  
  Noise = normrnd(0.0,Sigma);
  EPred = EPred + Noise;
  
  if (MultErrorFlg) 
    EPred = exp(EPred);
    EPred = EPred - PreLogShift;
  end
  if (OnlyTriatFlg)
    %EDiat  = (LeRoy(R(:,1)') + LeRoy(R(:,2)') + LeRoy(R(:,3)'))';
    [E1, dE1] = O2_UMN(R(:,1)');
    [E2, dE2] = O2_UMN(R(:,2)');
    [E3, dE3] = O2_UMN(R(:,3)');
    EDiat     = E1 + E2 + E3;
    EPred     = EPred + EDiat;
  end
  %E  = EDiat * 27.2113839712790 + 0.3554625704*27.2113839712790 + ETriat + ETriat .* normrnd(0,abs(Sigma));

end


%% SAVE SAMPLED OUTPUT
function [] = SaveSampledOutput(R, EData, EPred, iSample)
  
  global ResultsFolder
  
  File = strcat(ResultsFolder, '/MATLABPostTest.csv.',num2str(iSample));
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,EData,EPred,\n');
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f,%f,%f,%f,%f\n', R(i,1),R(i,2),R(i,3),EData(i),EPred(i));
  end 
  
end


%% SAVE DETERMINISTIC OUTPUT
function [] = SaveDetermOutput(R, EData, EPred)
  
  global ResultsFolder
  
  File = strcat(ResultsFolder, '/MATLABDetermTest.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,EData,EPred,\n')
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f,%f,%f,%f,%f\n', R(i,1),R(i,2),R(i,3),EData(i),EPred(i));
  end 
  
end


%% COMPUTING AND SAVING MOMENTA
function [] = SaveMomenta(R, EData, ESum, ESqrSum)

  global NSamples ResultsFolder MomentaFileName

  EMean  = ESum ./ NSamples; 
  ESD    = (ESqrSum./NSamples - EMean.^2).^0.5;
  EPlus  = EMean + 3.0.*ESD;
  EMinus = EMean - 3.0.*ESD;

  File = strcat(ResultsFolder, '/OutputPosts/', MomentaFileName);
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,EData,EMean,EPlus,EMinus,ESD\n')
  for i = 1:size(EMean,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R(i,1),R(i,2),R(i,3),EData(i),EMean(i),EPlus(i),EMinus(i),ESD(i));
  end 
  fclose(fileID);
  
end


%% COMPUTING CUTS
function [iFigure, EPredSum, EPredSumSqr] = ComputeCutsSample(iFigure, G_MEAN, G_SD, Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, EPredSum, EPredSumSqr)

  global alphaVec RCutsVec  RStart REnd NPoints
    
  R3      = linspace(RStart, REnd, NPoints)';
  for iCut   = 1:length(alphaVec)
     R1      = R3.*0.0 + RCutsVec(iCut);
     alpha   = alphaVec(iCut);
     R2      = sqrt( R1.^2 + R3.^2 - 2.d0.*R1.*R3.*cos(alpha/180.d0*pi) );
     R       = [R1, R2, R3];
     [EPred]             = ComputeOutput(R, G_MEAN, G_SD, Lambda, re, W1, W2, W3, b1, b2, b3, Sigma);
     EPredSum(:,iCut)    = EPredSum(:,iCut)    + EPred(:,1);
     EPredSumSqr(:,iCut) = EPredSumSqr(:,iCut) + EPred(:,1).^2;
     
%      figure(iFigure)
%      plot(R3, EPred,'Color',[238,238,238]./256,'LineWidth',0.5)
%      hold on
%      iFigure = iFigure + 1;
  end  
  
end


function [iFigure] = PlotCuts(iFigure, EPredSum, EPredSumSqr)

  global alphaVec RCutsVec NSamples RStart REnd NPoints NN_Folder GP_Folder PES_Folder
  
  RBNN    = linspace(RStart, REnd, NPoints)';
  for iCut   = 1:length(alphaVec)
    
    EBNNMean(:)  = EPredSum(:,iCut)./NSamples; 
    EBNNSD(:)    = (EPredSumSqr(:,iCut)./NSamples - EBNNMean(:).^2).^0.5;
    EBNNPlus     = EBNNMean + 3.0.*EBNNSD;
    EBNNMinus    = EBNNMean - 3.0.*EBNNSD;
    
     
    filename = strcat(NN_Folder,'/CutData_',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    RAbInitio = dataArray{:, 1};
    EAbInitio = dataArray{:, 2};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    filename = strcat(NN_Folder,'/Cut_',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    RNN = dataArray{:, 1};
    ENN = dataArray{:, 2};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;

    
    filename = strcat(PES_Folder,'/Test/PlotPES/PES_1/Cut',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%q%q%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
      raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    for col=[1,2]
      % Converts text in the input cell array to numbers. Replaced non-numeric
      % text with NaN.
      rawData = dataArray{col};
      for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
          result = regexp(rawData{row}, regexstr, 'names');
          numbers = result.numbers;

          % Detected commas in non-thousand locations.
          invalidThousandsSeparator = false;
          if any(numbers==',');
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(numbers, thousandsRegExp, 'once'));
              numbers = NaN;
              invalidThousandsSeparator = true;
            end
          end
          % Convert numeric text to numbers.
          if ~invalidThousandsSeparator;
            numbers = textscan(strrep(numbers, ',', ''), '%f');
            numericData(row, col) = numbers{1};
            raw{row, col} = numbers{1};
          end
        catch me
        end
      end
    end
    RPES = cell2mat(raw(:, 1));
    EPES = cell2mat(raw(:, 2));
    clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;

   
    filename = strcat(GP_Folder,'/Paper',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%*s%*s%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    RGP      = dataArray{:, 1};
    EGPMean  = dataArray{:, 2};
    EGPPlus  = dataArray{:, 3};
    EGPMinus = dataArray{:, 4};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
     

    figure(iFigure)
    errorbar(RBNN,EBNNMean,3.0.*EBNNSD)
    hold on
    plot(RPES, EPES,'k')
    plot(RAbInitio, EAbInitio,'go')
%     
%     
%     plot(RBNN, EBNNMean,'b')
%     hold on
%     plot(RBNN, EBNNPlus,'b')
%     plot(RBNN, EBNNMinus,'b')
%     
%     plot(RGP, EGPMean,'r')
%     plot(RGP, EGPPlus,'r')
%     plot(RGP, EGPMinus,'r')
%     
%     plot(RNN, ENN,'y')
%     
%     plot(RPES, EPES,'k')
%    
%     plot(RAbInitio, EAbInitio,'go')
    
    iFigure = iFigure + 1;
     
  end  
  
end


%% SCATTER PLOT

function [iFigure] = PlotScatter(iFigure, EData, EDataSum, EDataSqrSum)

  global NSamples

  EMean  = EDataSum ./ NSamples; 
  ESD    = (EDataSqrSum./NSamples - EMean.^2).^0.5;
  EPlus  = EMean + 3.0.*ESD;
  EMinus = EMean - 3.0.*ESD;
  
  figure(iFigure)
  errorbar(EData,EMean,3.0.*ESD,'o','MarkerSize',6,'MarkerEdgeColor','red','MarkerFaceColor','red')
  hold on
  %scatter(EData,EMean,20,'r','filled') 
  plot([0.0, 80.0],[0.0, 80.0],'-')
  iFigure = iFigure+1
  
end


function [NPointss, Rangee] = InitializeError(EData)

  NPointss(1) = sum((EData<3.20) == 1);
  NPointss(2) = sum(((EData>3.20) + (EData<7.53)) == 2);
  NPointss(3) = sum(((EData>7.53) + (EData<20.54)) == 2);
  NPointss(4) = sum(((EData>20.54) + (EData<42.22)) == 2);
  NPointss(5) = sum((EData>42.22) == 1);
  NPointss
  
  Rangee=[];
  for iData=1:size(EData,1)
    if (EData(iData) < 3.20)
      Rangee(iData) = 1;
    elseif (EData(iData) > 3.20) && (EData(iData) < 7.53)
      Rangee(iData) = 2;
    elseif (EData(iData) > 7.53) && (EData(iData) < 20.54)
      Rangee(iData) = 3;
    elseif (EData(iData) > 20.54) && (EData(iData) < 42.22)
      Rangee(iData) = 4;
    elseif (EData(iData) > 42.22)
      Rangee(iData) = 5;
    end
  end

end


function [RMSE, MUE] = ComputeError(NPointss, Rangee, EData, EPred)
  
  NData = size(EData,1);

  MUE=zeros(5,1);
  RMSE=zeros(5,1);
  for iData = 1:NData
    MUE(Rangee(iData))  = MUE(Rangee(iData))  + abs(EPred(iData)-EData(iData));
    RMSE(Rangee(iData)) = RMSE(Rangee(iData)) + (EPred(iData)-EData(iData)).^2;
  end
  MUE  = MUE       ./ NData;
  RMSE = sqrt(RMSE ./ NData);
  
end


function WritePointsPerAngle(RData, EData)

  global ResultsFolder alphaVec
  
  for iAlpha=1:length(alphaVec)
    
    File = strcat(ResultsFolder, '/OutputPosts/Points.csv.', num2str(floor(alphaVec(iAlpha))));
    fileID   = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,EData\n')
    for iPoints=1:size(RData,1)
      R1 = RData(iPoints,1);
      R2 = RData(iPoints,2);
      R3 = RData(iPoints,3);
      alpha1 = acos( (R2^2 + R3^2 - R1^2) / (2.0*R2*R3) )/pi*180.0;
      alpha2 = acos( (R1^2 + R3^2 - R2^2) / (2.0*R1*R3) )/pi*180.0;
      alpha3 = acos( (R1^2 + R2^2 - R3^2) / (2.0*R1*R2) )/pi*180.0;
      if     (alpha1 > (alphaVec(iAlpha) - 0.01)) && (alpha1 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R2,R3,R1,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R3,R2,R1,EData(iPoints));
      elseif (alpha2 > (alphaVec(iAlpha) - 0.01)) && (alpha2 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R1,R3,R2,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R3,R1,R2,EData(iPoints));
      elseif (alpha3 > (alphaVec(iAlpha) - 0.01)) && (alpha3 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R2,R1,R3,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R1,R2,R3,EData(iPoints));
      end      
    end
    fclose(fileID);
    
  end

end


function WritePointsDiatPerAngle(RData, EData)

  global ResultsFolder alphaVec
  
  for iAlpha=1:length(alphaVec)
    
    File = strcat(ResultsFolder, '/OutputPosts/DiatPoints.csv.', num2str(floor(alphaVec(iAlpha))));
    fileID   = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,EData\n')
    for iPoints=1:size(RData,1)
      R1 = RData(iPoints,1);
      R2 = RData(iPoints,2);
      R3 = RData(iPoints,3);
      alpha1 = acos( (R2^2 + R3^2 - R1^2) / (2.0*R2*R3) )/pi*180.0;
      alpha2 = acos( (R1^2 + R3^2 - R2^2) / (2.0*R1*R3) )/pi*180.0;
      alpha3 = acos( (R1^2 + R2^2 - R3^2) / (2.0*R1*R2) )/pi*180.0;
      if     (alpha1 > (alphaVec(iAlpha) - 0.01)) && (alpha1 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R2,R3,R1,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R3,R2,R1,EData(iPoints));
      elseif (alpha2 > (alphaVec(iAlpha) - 0.01)) && (alpha2 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R1,R3,R2,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R3,R1,R2,EData(iPoints));
      elseif (alpha3 > (alphaVec(iAlpha) - 0.01)) && (alpha3 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R2,R1,R3,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R1,R2,R3,EData(iPoints));
      end      
    end
    fclose(fileID);
    
  end

end


function PlotDiatomicPot(iFigure, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)

  global MultErrorFlg OnlyTriatFlg PreLogShift
  
  R1    = linspace(1.5,10.0,10000)';
  R2    = R1.*0.d0+100.0;
  R3    = R1.*0.d0+100.0;
  RTest = [R1,R2,R3];

  [EPred] = ComputeOutput(RTest, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
  EPred   = EPred - min(EPred);
  
  figure(iFigure)
  plot(R1,EPred)
  hold on

end