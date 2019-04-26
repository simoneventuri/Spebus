function [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ReadParametersSamples(iSample,  Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist)
  
  global NHL Network_Folder
  
  FolderName = 'ParamsPosts';%'StochPESParams';
  
  filename = strcat(Network_Folder,'/',FolderName,'/Lambda.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  LambdaTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda = ones(3,1).*LambdaTemp;
  
  filename = strcat(Network_Folder,'/',FolderName,'/re.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  reTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re = ones(3,1).*reTemp;
  
  
  filename = strcat(Network_Folder,'/',FolderName,'/b1.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/',FolderName,'/W1.csv.',num2str(iSample));
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


  filename = strcat(Network_Folder,'/',FolderName,'/b2.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/',FolderName,'/W2.csv.',num2str(iSample));
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


  filename = strcat(Network_Folder,'/',FolderName,'/b3.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(Network_Folder,'/',FolderName,'/W3.csv.',num2str(iSample));
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


  filename = strcat(Network_Folder,'/',FolderName,'/Sigma.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Sigma = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
  
  Lambda_Hist(iSample,:) = Lambda;
  re_Hist(iSample,:)     = re;
  
  W1_Hist(iSample,:,:) = W1;
  W2_Hist(iSample,:,:) = W2;
  W3_Hist(iSample,:,:) = W3;
  
  b1_Hist(iSample,:)   = b1;
  b2_Hist(iSample,:)   = b2;
  b3_Hist(iSample,:)   = b3;
  
  Sigma_Hist(iSample)  = Sigma;
  
end