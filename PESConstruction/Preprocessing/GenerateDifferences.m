close all
clc

DataFldr   = '/Users/sventuri/Dropbox/SPES/spes/Data_PES/N3/PES_1/';
OutputFldr = '/Users/sventuri/Dropbox/SPES/Output_MAC/Determ/N3';

Angles = [90, 120, 135]

for iAngle = Angles
  
  filename = strcat(DataFldr, '/RE.csv.',num2str(iAngle));
  filename
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  R1     = dataArray{:, 1};
  R2     = dataArray{:, 2};
  R3     = dataArray{:, 3};
  E_Data = dataArray{:, 4};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;


  filename = strcat(OutputFldr, '/REBestDet.csv.',num2str(iAngle));
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  E_Best = dataArray{:, 4};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;


  filename = strcat(OutputFldr, '/REDifferences.csv.',num2str(iAngle));
  fileID   = fopen(filename,'w');
  fprintf(fileID,'R1,R2,R3,EBest,EData,AbsDiff,Abs(AbsDiff),RelDiff,Abs(RelDiff)\n');
  for i = 1:size(E_Data,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f,%f\n', R1(i,1),R2(i,1),R3(i,1),E_Best(i),E_Data(i),E_Best(i)-E_Data(i),abs(E_Best(i)-E_Data(i)),(E_Best(i)-E_Data(i))/E_Data(i),abs((E_Best(i)-E_Data(i))/E_Data(i)));
  end 
  
  rmse = sqrt(mean((E_Best-E_Data).^2))
  
end
