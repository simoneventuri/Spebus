close all
clc

NTot = 1
NHL  = [3,20,20,1]

ResultsFolder = '/Users/sventuri/Dropbox/SPES/Output_MAC/Determ/N3/'
RFile         = '/Users/sventuri/Dropbox/SPES/spes/Data_PES/N3/NASA_Kolb/RE.csv.120'


filename = RFile;
delimiter = ',';
startRow = 2;
formatSpec = '%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
R1 = dataArray{:, 1};
R2 = dataArray{:, 2};
R3 = dataArray{:, 3};
EData = dataArray{:, 4};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
R = [R1, R2, R3];
NData =size(R,1)


filename = strcat(ResultsFolder, '/ScalingValues.csv')
delimiter = ',';
startRow = 2;
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
V1 = dataArray{:, 1};
V2 = dataArray{:, 2};
V3 = dataArray{:, 3};
G_MEAN = [V1(1), V2(1), V3(1)];
G_SD   = [V1(2), V2(2), V3(2)];
clearvars filename delimiter startRow formatSpec fileID dataArray ans;


% filename = strcat(ResultsFolder,'/PIPLayer/Lambda.csv');
% delimiter = ',';
% formatSpec = '%f%f%f%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
% fclose(fileID);
% LambdaTemp = [dataArray{1:end-1}];
% clearvars filename delimiter formatSpec fileID dataArray ans;
% Lambda = [LambdaTemp(1), LambdaTemp(1), LambdaTemp(1)];
Lambda = [1.9, 1.9, 1.9];
re     = [0.d0, 0.d0, 0.d0];

filename = strcat(ResultsFolder,'/InputLayer/b.csv')
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b1 = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/InputLayer/W.csv');
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



filename = strcat(ResultsFolder,'/HiddenLayer1/b.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b2 = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/HiddenLayer1/W.csv');
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



filename = strcat(ResultsFolder,'/HiddenLayer2/b.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b3 = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/HiddenLayer2/W.csv');
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


% RR=[1.6, 4.9080699138960613, 6.5]
% G = SymmetryFunctions_JG_1(RR, Lambda)
% z1 = G * W1 + b1';
% y1 = tanh(z1);
% z2 = y1 * W2 + b2';
% y2 = tanh(z2);
% E  = y2 * W3 + b3'
% pause
% 

G = SymmetryFunctions_JG_1(R, Lambda, re, G_MEAN, G_SD);



ESum    = 0.0;
ESumSqr = 0.0;

b1Mat = repmat(b1',[NData,1]);
b2Mat = repmat(b2',[NData,1]);
b3Mat = repmat(b3',[NData,1]);

z1 = G * W1 + b1Mat;
y1 = tanh(z1);
z2 = y1 * W2 + b2Mat;
y2 = tanh(z2);
E  = y2 * W3 + b3Mat;
  
ESum    = ESum    + E;
ESumSqr = ESumSqr + E.^2;
  
EMean =      ESum ./ NTot;
ESD   = sqrt(ESumSqr ./ NTot - EMean.^2);



% ESum    = 0.0;
% ESumSqr = 0.0;
% for i=1:NTot
% 
%   W1 = normrnd(W1_MEAN,W1_SD);
%   W2 = normrnd(W2_MEAN,W2_SD);
%   W3 = normrnd(W3_MEAN,W3_SD);
%   b1 = normrnd(b1_MEAN,b1_SD);
%   b2 = normrnd(b2_MEAN,b2_SD);
%   b3 = normrnd(b3_MEAN,b3_SD);
%   Sigma = normrnd(Sigma_MEAN,Sigma_SD);
% 
%   b1Mat = repmat(b1',[NData,1]);
%   b2Mat = repmat(b2',[NData,1]);
%   b3Mat = repmat(b3',[NData,1]);
% 
%   z1 = G * W1 + b1Mat;
%   y1 = tanh(z1);
%   z2 = y1 * W2 + b2Mat;
%   y2 = tanh(z2);
%   E  = y2 * W3 + b3Mat + normrnd(0,Sigma);
%   
%   ESum    = ESum    + E;
%   ESumSqr = ESumSqr + E.^2;
%   
% end
% 
% EMean =      ESum ./ NTot;
% ESD   = sqrt(ESumSqr ./ NTot - EMean.^2);


File = strcat(ResultsFolder, '/MATLABPostTest.csv');
fileID   = fopen(File,'w');
fprintf(fileID,'R1,R2,R3,EData,EMean,ESD,EPlus,Eminus\n');
for i = 1:size(E,1)
  fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R1(i,1),R2(i,1),R3(i,1),EData(i),EMean(i),ESD(i),EMean(i)+3.d0.*ESD(i),EMean(i)-3.d0.*ESD(i));
end 


function [G] = SymmetryFunctions_JG_1(R, Lambda, re, G_MEAN, G_SD)
  
  p1(:) = exp( - Lambda(1) .* (R(:,1) - re(1)) );
  p2(:) = exp( - Lambda(2) .* (R(:,2) - re(2)) );
  p3(:) = exp( - Lambda(3) .* (R(:,3) - re(3)) );

  G(:,1) = ( ( p1       + p2       + p3 ) ./ 3.d0      - G_MEAN(1)) ./ G_SD(1);  
  G(:,2) = ( ( p1 .* p2 + p2 .* p3 + p3 .* p1) ./ 3.d0 - G_MEAN(2)) ./ G_SD(2);  
  G(:,3) = ( p1 .* p2 .* p3                            - G_MEAN(3)) ./ G_SD(3);  

  
end


function [G] = SymmetryFunctions_JG_2(R, Lambda, re, G_MEAN, G_SD)
  
  p1(:) = exp( - Lambda(1) .* (R(:,1) - re(1)) );
  p2(:) = exp( - Lambda(2) .* (R(:,2) - re(1)) );
  p3(:) = exp( - Lambda(3) .* (R(:,3) - re(1)) );

  G(:,1) = ( ( p1  + p2 ) ./ 2.d0 - G_MEAN(1)) ./ G_SD(1);  
  G(:,2) = ( ( p1 .* p2 )         - G_MEAN(2)) ./ G_SD(2);  
  G(:,3) = ( p3                   - G_MEAN(3)) ./ G_SD(3);  
  
end