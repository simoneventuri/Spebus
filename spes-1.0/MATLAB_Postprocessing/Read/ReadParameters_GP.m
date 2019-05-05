function [Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise] = ReadParameters_GP()
  
  global NHL Network_Folder NetworkType
  
  PostFix = ' ';
  
  filename = strcat(Network_Folder,'/BondOrderLayer/Lambda.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  LambdaTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda = LambdaTemp;
  
  
  filename = strcat(Network_Folder,'/PIPLayer/Exp1.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Exp1Temp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Exp1 = Exp1Temp;
  

  filename = strcat(Network_Folder,'/PIPLayer/Exp2.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Exp2Temp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Exp2 = Exp2Temp;
  
  
  filename = strcat(Network_Folder,'/PIPLayer/Exp3.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Exp3Temp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Exp3 = Exp3Temp;
  
  
  filename = strcat(Network_Folder,'/PIPLayer/Exp4.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Exp4Temp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Exp4 = Exp4Temp;
  
  
  filename = strcat(Network_Folder,'/CalibratedParameters/l1.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  l1Temp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  l1 = l1Temp;
  
  
  filename = strcat(Network_Folder,'/CalibratedParameters/l2.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  l2Temp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  l2 = l2Temp;
  
  
  filename = strcat(Network_Folder,'/CalibratedParameters/Amp.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  AmpTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Amp = AmpTemp;
  
  
  filename = strcat(Network_Folder,'/CalibratedParameters/SigmaNoise.csv',PostFix);
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  SigmaNoiseTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  SigmaNoise = SigmaNoiseTemp;
  
  
  re = zeros(3,1);
  
end 