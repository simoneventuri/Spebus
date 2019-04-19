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
% [iFigure] = ComputeCutsSample(iFigure, G_MEAN, G_SD, Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det)

%% PLOT scatter PLOTS
[iFigure] = Plotscatter(iFigure, RData, EData, EDataDiat, EFitted, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det);

figure(100)
PlotDiatomicPot(100, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det);

%% ADDING DIATOMIC 
for iAng=alphaVec
  iAng
  AddDiatomPot(iAng, Lambda_Det, re_Det, G_MEAN, G_SD, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det);
end



%% LOADING LABELED DATA
function [NData, RData, EData, EFitted] = ReadData()

  global RFile TestFileName AbscissaConverter
  
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
  RData = [R1, R2, R3] .* AbscissaConverter;
  
  filename = strcat(RFile, '/EOrig.csv');
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
 
  NData =size(EData,1);
  
  
  filename = strcat(RFile,'/EFitted.csv');
  delimiter = '';
  startRow = 2;
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  EFitted = dataArray{:, 1};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  
end


function [EDiat] = ComputeDiat(R)

  global System AbscissaConverter

  if strcmp(System,'N3')
    [E1, dE1] = N2_LeRoy(R(:,1)./AbscissaConverter);
    [E2, dE2] = N2_LeRoy(R(:,2)./AbscissaConverter);
    [E3, dE3] = N2_LeRoy(R(:,3)./AbscissaConverter);
    E1 = E1';
    E2 = E2';
    E3 = E3';
  elseif strcmp(System,'O3')
    [E1, dE1] = O2_UMN(R(:,1)./AbscissaConverter);
    [E2, dE2] = O2_UMN(R(:,2)./AbscissaConverter);
    [E3, dE3] = O2_UMN(R(:,3)./AbscissaConverter);
  end
  EDiat = E1 + E2 + E3;
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% READ PIP PARAMETERS
function [G_MEAN, G_SD] = ReadScales()

  global Network_Folder

  %%% LOADING NETWORK PARAMETERS DISTRIBUTIONS
  filename = strcat(Network_Folder,'/ScalingValues.csv')
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

function [Lambda, re, W1, W2, W3, b1, b2, b3] = ReadParametersDeterm()
  
  global NHL Network_Folder NetworkType
  
  if strcmp(NetworkType,'NN')
  
    filename = strcat(Network_Folder,'/BondOrderLayer/Lambda.csv');
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    LambdaTemp = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;
    Lambda = LambdaTemp;

    filename = strcat(Network_Folder,'/BondOrderLayer/re.csv');
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    reTemp = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;
    re = reTemp;


    filename = strcat(Network_Folder,'/HiddenLayer1/b.csv');
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    b1 = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;

    filename = strcat(Network_Folder,'/HiddenLayer1/W.csv');
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


    filename = strcat(Network_Folder,'/HiddenLayer2/b.csv');
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    b2 = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;

    filename = strcat(Network_Folder,'/HiddenLayer2/W.csv');
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


    filename = strcat(Network_Folder,'/OutputLayer/b.csv');
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    b3 = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;

    filename = strcat(Network_Folder,'/OutputLayer/W.csv');
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
    
  elseif strcmp(NetworkType,'Pol')
    
    filename = strcat(Network_Folder,'/BondOrderLayer/Lambda.csv');
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    LambdaTemp = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;
    Lambda = LambdaTemp;

    filename = strcat(Network_Folder,'/BondOrderLayer/re.csv');
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    reTemp = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;
    re = reTemp;
    
    filename = strcat(Network_Folder,'/PolLayer/W.csv');
    delimiter = ',';
    formatSpec = '';
    for i = 1:1
      formatSpec = strcat(formatSpec,'%f');
    end
    formatSpec = strcat(formatSpec,'%[^\n\r]');
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    W1 = [dataArray{1:end-1}];
    clearvars filename delimiter formatSpec fileID dataArray ans;
    
    W2 = 0.0;
    W3 = 0.0;
    b1 = 0.0;
    b2 = 0.0;
    b3 = 0.0;
    
  end
  
end


%% PIP FUNCTIONS
function [p] = BondOrder(R, Lambda, re)

  global BondOrderFun
  
  if strcmp(BondOrderFun,'MorseFun')
    p = exp( - Lambda(1) .* (R - re(1)) )';
  elseif strcmp(BondOrderFun(:),'GaussFun')
    p = exp( - Lambda(1) .* (R - re(1)).^2 )';
  elseif strcmp(BondOrderFun,'MEGFun')
    p = exp( - Lambda(1) .* (R - re(1)) - Lambda(2) .* (R - re(2)).^2 )';
  end
  
end

function [G] = PIP(p1, p2, p3, G_MEAN, G_SD)
  
  GVec1 = [p1.*p2; p2.*p3; p1.*p3];
  GVec2 = [GVec1(1,:).*p1; GVec1(1,:).*p2; GVec1(2,:).*p2; GVec1(2,:).*p3; GVec1(3,:).*p1; GVec1(3,:).*p3];
  
  G(:,1)   = sum(GVec1,1);
  G(:,2)   = (p1.*p2.*p3);
  G(:,3)   = sum(GVec2,1);
  
  G(:,4)   = GVec2(1,:).*p1 + GVec2(2,:).*p2 + GVec2(3,:).*p2 + GVec2(4,:).*p3 + GVec2(5,:).*p1 + GVec2(6,:).*p3;
  G(:,5)   = GVec2(1,:).*p3 + GVec2(3,:).*p1 + GVec2(6,:).*p2;
  G(:,6)   = GVec2(1,:).*p2 + GVec2(3,:).*p3 + GVec2(5,:).*p3;

end


%% COMPUTE OUTPUT
function [EPred] = ComputeOutput(R, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3)

  global MultErrorFlg OnlyTriatFlg PreLogShift NetworkType NOrd System AbscissaConverter RMin
  
  NData = size(R,1);
  
  p1 = BondOrder(R(:,1), Lambda, re);
  p2 = BondOrder(R(:,2), Lambda, re);
  p3 = BondOrder(R(:,3), Lambda, re);
  
  if strcmp(NetworkType,'NN')
   
    G  = PIP(p1, p2, p3, G_MEAN, G_SD);
    
    b1Mat = repmat(b1',[NData,1]);
    b2Mat = repmat(b2',[NData,1]);
    b3Mat = repmat(b3',[NData,1]);

    z1     = G * W1 + b1Mat;
    y1     = tanh(z1);
    z2     = y1 * W2 + b2Mat;
    y2     = tanh(z2);
    EPred  = y2 * W3 + b3Mat;
    
  elseif strcmp(NetworkType,'Pol')
    
    IdxVecs  = [[1,1,0]; ...
                [1,1,1]; [2,1,0]; ...
                [2,1,1]; [2,2,0]; [3,1,0]; ...       
                [2,2,1]; [3,1,1]; [3,2,0]; [4,1,0]; ...
                [2,2,2]; [3,2,1]; [4,1,1]; [3,3,0]; [4,2,0]; [5,1,0]; ...
                [3,2,2]; [3,3,1]; [4,2,1]; [5,1,1]; [4,3,0]; [5,2,0]; [6,1,0]; ...
                [3,3,2]; [4,2,2]; [4,3,1]; [5,2,1]; [6,1,1]; [4,4,0]; [5,3,0]; [6,2,0]; [7,1,0]; ...   
                [3,3,3]; [4,3,2]; [4,4,1]; [5,2,2]; [5,3,1]; [6,2,1]; [7,1,1]; [5,4,0]; [6,3,0]; [7,2,0]; [8,1,0]; ...
                [4,3,3]; [4,4,2]; [5,3,2]; [5,4,1]; [6,2,2]; [6,3,1]; [7,2,1]; [8,1,1]; [5,5,0]; [6,4,0]; [7,3,0]; [8,2,0]; [9,1,0]; ...           
                [4,4,3]; [5,3,3]; [5,4,2]; [5,5,1]; [6,3,2]; [6,4,1]; [6,5,0]; [7,2,2]; [7,3,1]; [7,4,0]; [8,2,1]; [8,3,0]; [9,1,1]; [9,2,0]; [10,1,0]; ...
                [4,4,4]; [5,4,3]; [5,5,2]; [6,4,2]; [6,5,1]; [6,6,0]; [7,3,2]; [7,4,1]; [7,5,0]; [8,2,2]; [8,3,1]; [8,4,0]; [9,2,1]; [9,3,0]; [10,1,1]; [10,2,0]; [11,1,0]; ...
                [5,4,4]; [6,4,4]; [6,5,2]; [6,4,2]; [6,6,1]; [7,3,3]; [7,4,2]; [7,5,1]; [8,3,2]; [8,4,1]; [8,5,0]; [9,2,2]; [9,3,1]; [9,4,0]; [10,2,1]; [10,3,0]; [11,2,0]; [11,1,1]; [12,1,0]; ...
                [5,5,4]; [6,3,5]; [6,4,4]; [7,3,4]; [7,5,2]; [7,6,1]; [7,7,0]; [8,3,3]; [8,4,2]; [8,5,1]; [8,6,0]; [9,3,2]; [9,4,1]; [9,5,0]; [10,2,2]; [10,3,1]; [10,4,0]; [11,2,1]; [11,3,0]; [12,2,0]; [13,1,0]];
    PermVecs  = [2; ...
                 6; 1; ...
                 2; 2; 1; ... 
                 2; 2; 1; 1; ...
                 6; 1; 2; 2; 1; 1; ...
                 2; 2; 1; 2; 1; 1; 1; ...
                 2; 2; 1; 1; 2; 2; 1; 1; 1; ...  
                 6; 1; 2; 2; 1; 1; 2; 1; 1; 1; 1; ...
                 2; 2; 1; 1; 2; 1; 1; 2; 2; 1; 1; 1; 1; ...    
                 2; 2; 1; 2; 1; 1; 1; 2; 1; 1; 1; 1; 2; 1; 1; ... 
                 6; 1; 2; 1; 1; 2; 1; 1; 1; 2; 1; 1; 1; 1; 2; 1; 1; ... 
                 2; 2; 1; 1; 2; 2; 1; 1; 1; 1; 1; 2; 1; 1; 1; 1; 1; 2; 1; ...
                 2; 1; 2; 1; 1; 1; 2; 2; 1; 1; 1; 1; 1; 1; 2; 1; 1; 1; 1; 1; 1];
    NbVecs   = [1,0,1,2,3,4,6,7,9,11,13,15,17,19,21];
    
    Sum  = p1.*0.0;
    iCum = 1;
    for iOrd=2:NOrd
      for iIdx=1:NbVecs(iOrd+1)
        IdxVec = IdxVecs(iCum,:);
        Sum    = Sum + W1(iCum) .* (p1.^IdxVec(1) .* p2.^IdxVec(2) .* p3.^IdxVec(3) + p1.^IdxVec(1) .* p2.^IdxVec(3) .* p3.^IdxVec(2) + ...
                                    p1.^IdxVec(2) .* p2.^IdxVec(1) .* p3.^IdxVec(3) + p1.^IdxVec(2) .* p2.^IdxVec(3) .* p3.^IdxVec(1) + ...
                                    p1.^IdxVec(3) .* p2.^IdxVec(1) .* p3.^IdxVec(2) + p1.^IdxVec(3) .* p2.^IdxVec(2) .* p3.^IdxVec(1)) ./ PermVecs(iCum);
        iCum   = iCum + 1;
      end
    end
    
    EPred = Sum' .* 0.159360144e-2.*27.2113839712790;
    [VShift, dV] = O2_UMN(RMin);
    EPred = EPred - VShift;
    
  end 
    
  if (MultErrorFlg) 
    EPred = exp(EPred);
    EPred = EPred - PreLogShift;
  end
  if (OnlyTriatFlg)
    if strcmp(System,'N3')
      [E1, dE1] = N2_LeRoy(R(:,1)'./AbscissaConverter);
      [E2, dE2] = N2_LeRoy(R(:,2)'./AbscissaConverter);
      [E3, dE3] = N2_LeRoy(R(:,3)'./AbscissaConverter);
    elseif strcmp(System,'O3')
      [E1, dE1] = O2_UMN(R(:,1)'./AbscissaConverter);
      [E2, dE2] = O2_UMN(R(:,2)'./AbscissaConverter);
      [E3, dE3] = O2_UMN(R(:,3)'./AbscissaConverter);
    end
    EDiat = E1 + E2 + E3;
    EPred = EPred + EDiat;
  end

end


%% SAVE DETERMINISTIC OUTPUT
function [] = SaveDetermOutput(R, EData, EPred)
  
  global Network_Folder
  
  File = strcat(Network_Folder, '/MATLABDetermTest.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,EData,EPred,\n');
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f,%f,%f,%f,%f\n', R(i,1),R(i,2),R(i,3),EData(i),EPred(i));
  end 
  
end


%% SAVE DETERMINISTIC ORIGINAL OUTPUT
function [] = SaveDetermOriginalOutput(R, EPred)
  
  global Network_Folder
  
  File = strcat(Network_Folder, '/RFake.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3\n');
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f,%f,%f\n', R(i,1),R(i,2),R(i,3));
  end 
  
  File = strcat(Network_Folder, '/EFake.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'EData\n');
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f\n',EPred(i));
  end 
  
end


%% COMPUTING CUTS
function [iFigure] = ComputeCutsSample(iFigure, G_MEAN, G_SD, Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det)

  global alphaVec RCutsVec  RStart REnd NPoints 
    
  R3      = linspace(RStart, REnd, NPoints)';
  for iCut   = 1:length(alphaVec)
     R1      = R3.*0.0 + RCutsVec(iCut);
     alpha   = alphaVec(iCut);
     R2      = sqrt( R1.^2 + R3.^2 - 2.d0.*R1.*R3.*cos(alpha/180.d0*pi) );
     R       = [R1, R2, R3];
     [EPred] = ComputeOutput(R, G_MEAN, G_SD, Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det);
     
     figure(iFigure);
     plot(R1, EPred,'Color',[238,238,238]./256,'LineWidth',0.5);
     hold on
     iFigure = iFigure + 1;
  end  
  
end


function [iFigure] = Plotscatter(iFigure, R, EData, EDiatData, EFitted, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3)
  
  global OnlyTriatFlg RMin EGroupsVec Network_Folder System ShiftScatter AbscissaConverter
  
  RMinVec      = [RMin, 50.0, 50.0];
  [PredShift]  = ComputeOutput(RMinVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3);
  
  [EPred]      = ComputeOutput(R,       Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3) - PredShift;
  
  if strcmp(System,'N3')
    [FittedShift, dE1] = N2_LeRoy(RMin);
    %[FittedShift, dE1] = N2_MRCI(2.088828)
    [PRedShift, dE1]   = N2_LeRoy(RMin);
  elseif strcmp(System,'O3')
    [FittedShift, dE1] = O2_UMN(RMin);
    [PRedShift, dE1]   = O2_UMN(RMin);
  end
  
  
  size(EData)
  size(EFitted)
  size(EDiatData)
  if (OnlyTriatFlg)
    EData   = EData   + EDiatData;
    EFitted = EFitted + EDiatData - FittedShift;
  else
    EData   = EData + PRedShift;
  end
  
  % EAllFitted = ETriatFitted + EDiat;
  % EAllPred   = ETriatPred   + EDiat + PredShift;
  % EAllData   = ETriatData   + EDiat;
  % EAllFitted = ETriatFitted + EDiat;
  % EAllPred   = ETriatPred   + EDiat;
  % EAllData   = ETriatData   + EDiat + FittedShift;

  figure(iFigure);
  scatter(EData,EFitted,'g','filled');
  hold on
  scatter(EData,EPred,'b','filled');
  plot([0, 30.0],[0, 30.0],'-');
  iFigure = iFigure + 1;
 
  
  UME_Data_Vec  = abs(EFitted-EData);
  UME_Pred_Vec  = abs(EPred-EData);
  UME_Data      = mean(UME_Data_Vec);
  UME_Pred      = mean(UME_Pred_Vec);
  figure(iFigure);
  scatter(EData,UME_Data_Vec,'g','filled');
  hold on
  scatter(EData,UME_Pred_Vec,'b','filled');
  iFigure = iFigure + 1;
    
  RMSE_Data_Vec = (EFitted-EData).^2;
  RMSE_Pred_Vec = (EPred-EData).^2;
  RMSE_Data     = sqrt(mean(RMSE_Data_Vec));
  RMSE_Pred     = sqrt(mean(RMSE_Pred_Vec));
  figure(iFigure);
  scatter(EData,RMSE_Data_Vec,'g','filled');
  hold on
  scatter(EData,RMSE_Pred_Vec,'b','filled');
  iFigure = iFigure + 1;
  
  RMSE_Data_Group = zeros(size(EGroupsVec,2),1);
  RMSE_Pred_Group = zeros(size(EGroupsVec,2),1);
  UME_Data_Group  = zeros(size(EGroupsVec,2),1);
  UME_Pred_Group  = zeros(size(EGroupsVec,2),1);
  Point_in_Group  = zeros(size(EGroupsVec,2),1);
  
  for i=1:size(EData,1)
    Idx=1;
    while EData(i) >= EGroupsVec(Idx) - ShiftScatter
      Idx=Idx+1;
    end
    GroupIdx(i) = Idx;
    
    Point_in_Group(GroupIdx(i))  = Point_in_Group(GroupIdx(i))  + 1;
    RMSE_Data_Group(GroupIdx(i)) = RMSE_Data_Group(GroupIdx(i)) + RMSE_Data_Vec(i);
    RMSE_Pred_Group(GroupIdx(i)) = RMSE_Pred_Group(GroupIdx(i)) + RMSE_Pred_Vec(i);
    UME_Data_Group(GroupIdx(i))  = UME_Data_Group(GroupIdx(i))  + UME_Data_Vec(i);
    UME_Pred_Group(GroupIdx(i))  = UME_Pred_Group(GroupIdx(i))  + UME_Pred_Vec(i);
  end
  
  RMSE_Data_Group = sqrt(RMSE_Data_Group ./ Point_in_Group);
  RMSE_Pred_Group = sqrt(RMSE_Pred_Group ./ Point_in_Group);
  UME_Data_Group  =      UME_Data_Group  ./ Point_in_Group;
  UME_Pred_Group  =      UME_Pred_Group  ./ Point_in_Group;
  
  filename = strcat(Network_Folder,'/Errors.csv');
  fileID = fopen(filename,'w');
  fprintf(fileID,'# Group, En Interval, NPoints,     Orig UME,       NN UME,    Orig RMSE,      NN RMSE\n');
  for iGroup=1:size(EGroupsVec,2)
    fprintf(fileID,'%7i,%12f,%8i,%13f,%13f,%13f,%13f\n', iGroup, EGroupsVec(iGroup), Point_in_Group(iGroup), UME_Data_Group(iGroup), UME_Pred_Group(iGroup), RMSE_Data_Group(iGroup), RMSE_Pred_Group(iGroup) );
  end
  fclose(fileID);
    
  
  figure(iFigure);
  ErrMat=[UME_Data_Group,UME_Pred_Group];
  bar(ErrMat)
  iFigure = iFigure + 1;
  
  figure(iFigure);
  ErrMat=[RMSE_Data_Group,RMSE_Pred_Group];
  bar(ErrMat)
  iFigure = iFigure + 1;
  
end


function PlotDiatomicPot(iFigure, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3)

  global MultErrorFlg OnlyTriatFlg PreLogShift System AbscissaConverter
  
  R1    = linspace(1.5,10.0,10000)';
  R2    = R1.*0.d0+100.0;
  R3    = R1.*0.d0+100.0;
  RTest = [R1,R2,R3];
  
  [EPred]        = ComputeOutput(RTest, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3);
  RTest          = [1.d2,1.d2,1.d2];
  [EPredInf]     = ComputeOutput(RTest, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3);
  if strcmp(System,'N3')
    [EData, dE]    = N2_LeRoy(R1'./AbscissaConverter);
    [EDataInf, te] = N2_LeRoy(1.d2');
  elseif strcmp(System,'O3')
    [EData, dE]    = O2_UMN(R1'./AbscissaConverter);
    [EDataInf, te] = O2_UMN(1.d2');
  end
  size(EData);
  
  figure(iFigure)
  plot(R1,EPred - EPredInf);
  hold on
  plot(R1,EData - EDataInf);

end


%% ADDING DIATOMIC 
function AddDiatomPot(iAng, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3)
  
  global RFile Network_Folder RMin System AbscissaConverter OnlyTriatFlg
  
  filename = strcat(RFile,'/RE.csv.',num2str(iAng));
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  R1     = dataArray{:, 1};
  R2     = dataArray{:, 2};
  R3     = dataArray{:, 3};
  ETriatFitted = dataArray{:, 4};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  R = [R1,R2,R3] .* AbscissaConverter;
    
  RMinVec     = [RMin, 50.0, 50.0];
  [PredShift] = ComputeOutput(RMinVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3);
  [EAllPred]  = ComputeOutput(R,       Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3);% - PredShift;
  
  
  if strcmp(System,'N3')
    [E1, dE1] = N2_LeRoy(R1'./AbscissaConverter);
    [E2, dE2] = N2_LeRoy(R2'./AbscissaConverter);
    [E3, dE3] = N2_LeRoy(R3'./AbscissaConverter);
  elseif strcmp(System,'O3')
    [E1, dE1] = O2_UMN(R1'./AbscissaConverter);
    [E2, dE2] = O2_UMN(R2'./AbscissaConverter);
    [E3, dE3] = O2_UMN(R3'./AbscissaConverter);
  end
  EDiat = E1 + E2 + E3;
  
  if strcmp(System,'N3')
    [FittedShift, dE1] = N2_LeRoy(RMin);
  elseif strcmp(System,'O3')
    [FittedShift, dE1] = O2_UMN(RMin);
  end
  
  EAllFitted = ETriatFitted + EDiat - FittedShift;
  if (OnlyTriatFlg)
    ETriatPred = EAllPred     - EDiat;
  else
    ETriatPred = EAllPred;
  end
  
  filename = strcat(Network_Folder,'/RE_All.csv.',num2str(iAng));
  fileID = fopen(filename,'w');
  fprintf(fileID,'# R1,R2,R3,EDiat,ETriatFitted,ETriatPred,ETotFitted,ETotPred\n');
  for iPoints=1:size(R1,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R1(iPoints), R2(iPoints), R3(iPoints), EDiat(iPoints), ETriatFitted(iPoints), ETriatPred(iPoints), EAllFitted(iPoints), EAllPred(iPoints));
  end
  fclose(fileID);

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