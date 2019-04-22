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