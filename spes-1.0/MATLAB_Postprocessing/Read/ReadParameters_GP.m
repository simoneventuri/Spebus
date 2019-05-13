function [ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern] = ReadParameters_GP()
  
  global Network_Folder
  
  PostFix = ' ';
  
  filename = strcat(Network_Folder,'/Parameters/ModPip.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  LambdaTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  ModPip = LambdaTemp;
  
  filename = strcat(Network_Folder,'/Parameters/Alpha.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  AlphaTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Alpha = AlphaTemp;

  filename = strcat(Network_Folder,'/Parameters/ObsIdxPnts.csv',PostFix);
  delimiter = ',';
  formatSpec = '';
  for i = 1:3
      formatSpec = strcat(formatSpec,'%f');
  end
  formatSpec = strcat(formatSpec,'%[^\n\r]');
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Obs_Idx_Pts = [dataArray{1:end-1}];
  clearvars filename delimiter formatSpec fileID dataArray ans;  
  
  filename = strcat(Network_Folder,'/Parameters/AmpKernel.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  AmpTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Amp = AmpTemp;
  
  filename = strcat(Network_Folder,'/Parameters/LengthKernel.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  l1Temp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  LKern = l1Temp;
  
%   filename = strcat(Network_Folder,'/CalibratedParameters/SigmaNoise.csv',PostFix);
%   delimiter = '';
%   formatSpec = '%f%[^\n\r]';
%   fileID = fopen(filename,'r');
%   dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%   fclose(fileID);
%   SigmaNoiseTemp = dataArray{:, 1};
%   clearvars filename delimiter formatSpec fileID dataArray ans;
%   SigmaNoise = SigmaNoiseTemp;
  
  re = zeros(3,1);
  
end 