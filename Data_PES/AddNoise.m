close all
clear all
clc

DataFldr = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat/PES_9/';

filename = strcat(DataFldr,'/EFitted.csv');
delimiter = '';
startRow = 2;
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
E = dataArray{:, 1};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
NData = size(E,1);

Noise1 = normrnd(0.0,0.01,[NData,1]);
Noise2 = normrnd(0.0,0.05,[NData,1]);
Noise3 = normrnd(0.0,0.1,[NData,1]);

ENoisy1 = E .* exp(Noise1);
ENoisy2 = E .* exp(Noise2);
ENoisy3 = E .* exp(Noise3);

% figure
% plot(E,'go');
% hold on
% plot(ENoisy1,'ko');
% plot(ENoisy2,'bo');
% plot(ENoisy3,'ro');

File = strcat(DataFldr, '/EFitted_001.csv');
fileID   = fopen(File,'w');
fprintf(fileID,'E with Multiplicative Noise St.Dev=0.01\n');
for i = 1:size(E,1)
  fprintf(fileID,'%f\n', ENoisy1(i));
end 
fclose(fileID);

File = strcat(DataFldr, '/EFitted_005.csv');
fileID   = fopen(File,'w');
fprintf(fileID,'E with Multiplicative Noise St.Dev=0.05\n');
for i = 1:size(E,1)
  fprintf(fileID,'%f\n', ENoisy2(i));
end 
fclose(fileID);

File = strcat(DataFldr, '/EFitted_01.csv');
fileID   = fopen(File,'w');
fprintf(fileID,'E with Multiplicative Noise St.Dev=0.1\n');
for i = 1:size(E,1)
  fprintf(fileID,'%f\n', ENoisy3(i));
end 
fclose(fileID);

