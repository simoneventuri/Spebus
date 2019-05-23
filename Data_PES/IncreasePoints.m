close all
clear all
clc

DataFldr = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Triat/PES_9/';

filename = strcat(DataFldr,'/R.csv');
delimiter = ',';
startRow = 2;
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
R1 = dataArray{:, 1};
R2 = dataArray{:, 2};
R3 = dataArray{:, 3};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
RData = [R1, R2, R3];
NData = size(RData,1);


NSamples   = 5000-NData;
RIn        = 1.5d0;
REnd       = 10.d0;
Samples    = lhsdesign(NSamples,3);
RFinal     = Samples      .* (REnd-RIn)   + RIn;
AngleFinal = Samples(:,2) .* (175.0-35.0) + 35.0;
RDaje  = [];
for i=1:NSamples
  RFinal(i,2) = sqrt(RFinal(i,1)^2 + RFinal(i,3)^2 - 2.0*RFinal(i,1)*RFinal(i,3)*cos(AngleFinal(i)/180.0*pi));
  %if (RFinal(i,1).^2 < RFinal(i,2).^2 + RFinal(i,3).^2) && (RFinal(i,2).^2 < RFinal(i,1).^2 + RFinal(i,3).^2) && (RFinal(i,3).^2 < RFinal(i,1).^2 + RFinal(i,2).^2)
    RDaje = [RDaje; RFinal(i,:)];
  %end
end
R = [RData; RDaje];
% figure
% scatter3(R(:,1),R(:,2),R(:,3))
% hold on
% scatter3(R(:,1),R(:,3),R(:,2))
% scatter3(R(:,2),R(:,1),R(:,3))
% scatter3(R(:,2),R(:,3),R(:,1))
% scatter3(R(:,3),R(:,1),R(:,2))
% scatter3(R(:,3),R(:,2),R(:,1))
% figure
% Grp  = ones(size(R,1),1);
% gplotmatrix(R,[],Grp)
NameStr = strcat('./RSampled_5000.csv');
csvwrite(NameStr,[R(:,1),R(:,2),R(:,3)]);



NSamples   = 10000-NData;
RIn        = 1.5d0;
REnd       = 10.d0;
Samples    = lhsdesign(NSamples,3);
RFinal     = Samples      .* (REnd-RIn)   + RIn;
AngleFinal = Samples(:,2) .* (175.0-35.0) + 35.0;
RDaje  = [];
for i=1:NSamples
  RFinal(i,2) = sqrt(RFinal(i,1)^2 + RFinal(i,3)^2 - 2.0*RFinal(i,1)*RFinal(i,3)*cos(AngleFinal(i)/180.0*pi));
  %if (RFinal(i,1).^2 < RFinal(i,2).^2 + RFinal(i,3).^2) && (RFinal(i,2).^2 < RFinal(i,1).^2 + RFinal(i,3).^2) && (RFinal(i,3).^2 < RFinal(i,1).^2 + RFinal(i,2).^2)
    RDaje = [RDaje; RFinal(i,:)];
  %end
end
R = [RData; RDaje];
% figure
% scatter3(R(:,1),R(:,2),R(:,3))
% hold on
% scatter3(R(:,1),R(:,3),R(:,2))
% scatter3(R(:,2),R(:,1),R(:,3))
% scatter3(R(:,2),R(:,3),R(:,1))
% scatter3(R(:,3),R(:,1),R(:,2))
% scatter3(R(:,3),R(:,2),R(:,1))
% figure
% Grp  = ones(size(R,1),1);
% gplotmatrix(R,[],Grp)
NameStr = strcat('./RSampled_10000.csv');
csvwrite(NameStr,[R(:,1),R(:,2),R(:,3)])



