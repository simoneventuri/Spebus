close all
clear all
clc

R1 = [];
R2 = [];
R3 = [];
E = [];
for i = 1:100

  filename = strcat('/Users/sventuri/Dropbox/SPES/Theano_Program/BNN_Pymc3_PIP/PIP_Output/xyEvaluated',num2str(i),'.csv');
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  R1(:,i) = dataArray{:, 1};
  R2(:,i) = dataArray{:, 2};
  R3(:,i) = dataArray{:, 3};
  E(:,i)  = dataArray{:, 4};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  
end

EMean   = mean(E,2);
EMeann  = repmat(EMean, [1,size(E,2)]);

ESD     = std(E,1,2);
ESDNorm = std(E./EMeann,1,2);

E3SigmaP = EMean + 3.0 .* ESD;
E3SigmaM = EMean - 3.0 .* ESD;

EMax     = max(E,[],2);
EMin     = min(E,[],2);

WriteDataFldr = '/Users/sventuri/Dropbox/SPES/Theano_Program/BNN_Pymc3_PIP/'
File = strcat(WriteDataFldr, '/PES_Statistics.csv');
fileID   = fopen(File,'w');
fprintf(fileID,'R1,R2,R3,E_Mean,E_SD,E_SDNormalized,E_3M,E_3P,EMin,EMax\n')
for i = 1:size(E,1)
  fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', R1(i,1),R2(i,1),R3(i,1),EMean(i),ESD(i),ESDNorm(i),E3SigmaM(i),E3SigmaP(i),EMin(i),EMax(i));
end 