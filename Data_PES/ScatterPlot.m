close all
clear all
clc

figure
for iAngle = [120]%[20.0, 40.0, 60.0, 80.0, 100.0, 120.0, 140.0, 160.0, 180.0, 135.0, 90.0]
  
  filename = strcat('/Users/sventuri/WORKSPACE/CG-QCT/run_N3_NASA/Test/PlotPES/PES_1/PES.csv.',num2str(iAngle));
  delimiter = ',';
  startRow = 2;
  endRow = 66564;
  formatSpec = '%*q%*q%*q%f%*s%*s%*s%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  E_NASA = dataArray{:, 1};
  clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;


  filename =  strcat('/Users/sventuri/WORKSPACE/CG-QCT/run_N3_NN_5000/Test/PlotPES/PES_1/PES.csv.',num2str(iAngle));
  delimiter = ',';
  startRow = 2;
  endRow = 66564;
  formatSpec = '%*q%*q%*q%f%*s%*s%*s%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  E_NN = dataArray{:, 1};
  clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;

  plot(E_NASA,E_NN,'o')
  hold on
end


% x=linspace(-20,1200,1500)
% plot(x,x,'k-')
% plot(x,2.0*x,'k-')
% plot(x,x./2.0,'k-')
% plot(x,1.5*x,'k-')
% plot(x,x./1.5,'k-')
% 
% 
% clear all
% figure
% filename = strcat('/Users/sventuri/WORKSPACE/CG-QCT/run_N3_NASA/Test/PlotPES/PES_1/PES.csv.0');
% delimiter = ',';
% startRow = 2;
% formatSpec = '%*q%*q%*q%f%*s%*s%*s%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, -startRow+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
% fclose(fileID);
% E_NASA = dataArray{:, 1};
% clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;
% 
% 
% filename =  strcat('/Users/sventuri/WORKSPACE/CG-QCT/run_N3_NN_5000/Test/PlotPES/PES_1/PES.csv.0');
% delimiter = ',';
% startRow = 2;
% formatSpec = '%*q%*q%*q%f%*s%*s%*s%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, -startRow+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
% fclose(fileID);
% E_NN = dataArray{:, 1};
% clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;
% 
% plot(E_NASA,E_NN,'o')
% hold on
% x=linspace(-20,1200,1500)
% plot(x,x,'k-')
% plot(x,2.0*x,'k-')
% plot(x,x./2.0,'k-')
% plot(x,1.5*x,'k-')
% plot(x,x./1.5,'k-')