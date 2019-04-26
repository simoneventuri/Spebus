function [Lambda, re, W1, W2, W3, b1, b2, b3] = ReadParametersDeterm()
  
  global NHL Network_Folder NetworkType
  
  PostFix = ' ';
  
  if strcmp(NetworkType,'NN')
  
    filename = strcat(Network_Folder,'/BondOrderLayer/Lambda.csv',PostFix);
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    LambdaTemp = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;
    Lambda = LambdaTemp;

    filename = strcat(Network_Folder,'/BondOrderLayer/re.csv',PostFix);
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    reTemp = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;
    re = reTemp;


    filename = strcat(Network_Folder,'/HiddenLayer1/b.csv',PostFix);
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    b1 = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;

    filename = strcat(Network_Folder,'/HiddenLayer1/W.csv',PostFix);
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


    filename = strcat(Network_Folder,'/HiddenLayer2/b.csv',PostFix);
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    b2 = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;

    filename = strcat(Network_Folder,'/HiddenLayer2/W.csv',PostFix);
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


    filename = strcat(Network_Folder,'/OutputLayer/b.csv',PostFix);
    delimiter = '';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    b3 = dataArray{:, 1};
    clearvars filename delimiter formatSpec fileID dataArray ans;

    filename = strcat(Network_Folder,'/OutputLayer/W.csv',PostFix);
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
    
    
    
    
    
%     filename = strcat(Network_Folder,'/Lambda.csv',PostFix);
%     delimiter = '';
%     formatSpec = '%f%[^\n\r]';
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     LambdaTemp = dataArray{:, 1};
%     clearvars filename delimiter formatSpec fileID dataArray ans;
%     Lambda = LambdaTemp;
% 
%     filename = strcat(Network_Folder,'/re.csv',PostFix);
%     delimiter = '';
%     formatSpec = '%f%[^\n\r]';
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     reTemp = dataArray{:, 1};
%     clearvars filename delimiter formatSpec fileID dataArray ans;
%     re = reTemp;
% 
% 
%     filename = strcat(Network_Folder,'/b1.csv',PostFix);
%     delimiter = '';
%     formatSpec = '%f%[^\n\r]';
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     b1 = dataArray{:, 1};
%     clearvars filename delimiter formatSpec fileID dataArray ans;
% 
%     filename = strcat(Network_Folder,'/W1.csv',PostFix);
%     delimiter = ',';
%     formatSpec = '';
%     for i = 1:NHL(2)
%       formatSpec = strcat(formatSpec,'%f');
%     end
%     formatSpec = strcat(formatSpec,'%[^\n\r]');
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     W1 = [dataArray{1:end-1}];
%     clearvars filename delimiter formatSpec fileID dataArray ans;
% 
% 
%     filename = strcat(Network_Folder,'/b2.csv',PostFix);
%     delimiter = '';
%     formatSpec = '%f%[^\n\r]';
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     b2 = dataArray{:, 1};
%     clearvars filename delimiter formatSpec fileID dataArray ans;
% 
%     filename = strcat(Network_Folder,'/W2.csv',PostFix);
%     delimiter = ',';
%     formatSpec = '';
%     for i = 1:NHL(3)
%       formatSpec = strcat(formatSpec,'%f');
%     end
%     formatSpec = strcat(formatSpec,'%[^\n\r]');
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     W2 = [dataArray{1:end-1}];
%     clearvars filename delimiter formatSpec fileID dataArray ans;
% 
% 
%     filename = strcat(Network_Folder,'/b3.csv',PostFix);
%     delimiter = '';
%     formatSpec = '%f%[^\n\r]';
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     b3 = dataArray{:, 1};
%     clearvars filename delimiter formatSpec fileID dataArray ans;
% 
%     filename = strcat(Network_Folder,'/W3.csv',PostFix);
%     delimiter = ',';
%     formatSpec = '';
%     for i = 1:NHL(4)
%       formatSpec = strcat(formatSpec,'%f');
%     end
%     formatSpec = strcat(formatSpec,'%[^\n\r]');
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%     fclose(fileID);
%     W3 = [dataArray{1:end-1}];
%     clearvars filename delimiter formatSpec fileID dataArray ans;
    
    
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