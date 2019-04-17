close all
clear all
clc

filename = '/Users/sventuri/Dropbox/SPES/Theano_Program/NN_Test/Data/xToPlot.csv';
startRow = 2;
delimiter = ',';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'HeaderLines' ,startRow-1,'ReturnOnError', false);
fclose(fileID);
R1 = dataArray{:, 1};
R2 = dataArray{:, 2};
R3 = dataArray{:, 3};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = '/Users/sventuri/Dropbox/SPES/Theano_Program/NN_Test/Data/yToCompare.csv';
startRow = 2;
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'HeaderLines' ,startRow-1,'ReturnOnError', false);
fclose(fileID);
E = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;
size(E)

X = [R1,R2,R3,E];
File = '/Users/sventuri/Dropbox/SPES/Theano_Program/NN_Test/Data/ToPlot.csv';
csvwrite(File,X)

clear X E



filename = '/Users/sventuri/Dropbox/SPES/Theano_Program/NN_Test/Output/yToCompare.csv';
startRow = 2;
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'HeaderLines' ,startRow-1,'ReturnOnError', false);
fclose(fileID);
E = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;
size(E)

X = [R1,R2,R3,E];
File = '/Users/sventuri/Dropbox/SPES/Theano_Program/NN_Test/Output/ToPlot.csv';
csvwrite(File,X)