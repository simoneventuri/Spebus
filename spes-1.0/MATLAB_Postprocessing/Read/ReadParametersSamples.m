function [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Noise, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist, Noise_Hist] = ReadParametersSamples(iSample,  Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist, Noise_Hist)
  
  global NHL Network_Folder
  
  FolderName = 'ParamsPosts';%'StochPESParams';
  
  %FolderName2 = strcat(Network_Folder,'/',FolderName);
  FolderName2 = '/Users/sventuri/WORKSPACE/CG-QCT/cg-qct/dtb/O3/PESs/BNN/PES9_AbInitio_10_10_LHS300/CalibratedParams/'
  
  filename = strcat(FolderName2,'/Lambda.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  LambdaTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  Lambda = ones(3,1).*LambdaTemp;
  
  filename = strcat(FolderName2,'/re.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  reTemp = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  re = ones(3,1).*reTemp;
  
  
  filename = strcat(FolderName2,'/b1.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b1 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(FolderName2,'/W1.csv.',num2str(iSample));
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


  filename = strcat(FolderName2,'/b2.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b2 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(FolderName2,'/W2.csv.',num2str(iSample));
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


  filename = strcat(FolderName2,'/b3.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  b3 = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;

  filename = strcat(FolderName2,'/W3.csv.',num2str(iSample));
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


  filename = strcat(FolderName2,'/Sigma.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Sigma = dataArray{:, 1};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  
  
  filename = strcat(FolderName2,'/Noise.csv.',num2str(iSample));
  delimiter = '';
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
  fclose(fileID);
  Noise = dataArray{:, 1};
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
  
  Noise_Hist(iSample)  = Noise;
  
end