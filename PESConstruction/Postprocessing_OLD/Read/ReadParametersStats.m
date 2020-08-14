function [Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD] = ReadParametersStats()
  
  global NHL Network_Folder
  
  filename = strcat(Network_Folder,'/ParamsPosts/Lambda_mu.csv')
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Lambda_MEAN_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda_MEAN = ones(3,1).*Lambda_MEAN_TEMP;

  filename = strcat(Network_Folder,'/ParamsPosts/re_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  re_MEAN_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re_MEAN = ones(3,1).*re_MEAN_TEMP;


  filename = strcat(Network_Folder,'/ParamsPosts/b1_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/ParamsPosts/W1_mu.csv');
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


  filename = strcat(Network_Folder,'/ParamsPosts/b2_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/ParamsPosts/W2_mu.csv');
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


  filename = strcat(Network_Folder,'/ParamsPosts/b3_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/ParamsPosts/W3_mu.csv');
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


  filename = strcat(Network_Folder,'/ParamsPosts/Sigma_mu.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Sigma_MEAN = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
  

  filename = strcat(Network_Folder,'/ParamsPosts/Lambda_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Lambda_SD_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda_SD = ones(3,1).*Lambda_SD_TEMP;
  
  filename = strcat(Network_Folder,'/ParamsPosts/re_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  re_SD_TEMP = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re_SD = ones(3,1).*re_SD_TEMP;  
  
  
  filename = strcat(Network_Folder,'/ParamsPosts/b1_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/ParamsPosts/W1_sd.csv');
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


  filename = strcat(Network_Folder,'/ParamsPosts/b2_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/ParamsPosts/W2_sd.csv');
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


  filename = strcat(Network_Folder,'/ParamsPosts/b3_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/ParamsPosts/W3_sd.csv');
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


  filename = strcat(Network_Folder,'/ParamsPosts/Sigma_sd.csv');
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Sigma_SD = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
end