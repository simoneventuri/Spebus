close all
clc

NHL      = [3,20,20,1]
NSamples = 1000;

ResultsFolder = '/Users/sventuri/Desktop/TempSPES/N3/'
RFile         = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/NASA_LH_5000/RE.csv.180'


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
R = [R1, R2, R3];i
NData =size(R,1)


mean = [5.28613091e-02 8.96451841e-04 1.55105501e-05];
sd   = [0.06819021 0.0043431  0.00018922];
%mean = [0.0,0.0,0.0];
%sd   = [1.0,1.0,1.0];

%%%%%%%%%%%%  MEANS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% filename = strcat(ResultsFolder,'/Lambda_mu.csv')
% delimiter = ',';
% formatSpec = '%f%f%f%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
% fclose(fileID);
% LambdaTemp = [dataArray{1:end-1}];
% clearvars filename delimiter formatSpec fileID dataArray ans;
% Lambda_MEAN = [LambdaTemp(1), LambdaTemp(1), LambdaTemp(1)];
% 
% 
% filename = strcat(ResultsFolder,'/re_mu.csv');
% delimiter = ',';
% formatSpec = '%f%f%f%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
% fclose(fileID);
% reTemp = [dataArray{1:end-1}];
% clearvars filename delimiter formatSpec fileID dataArray ans;
% re_MEAN = [reTemp(1), reTemp(1), reTemp(1)];



filename = strcat(ResultsFolder,'/ParamsPosts/b1_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b1_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/W1_mu.csv');
delimiter = ',';
formatSpec = '';
for i = 1:NHL(2)
  formatSpec = strcat(formatSpec,'%f');
end
formatSpec = strcat(formatSpec,'%[^\n\r]');
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
W1_MEAN = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/b2_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b2_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/W2_mu.csv');
delimiter = ',';
formatSpec = '';
for i = 1:NHL(3)
  formatSpec = strcat(formatSpec,'%f');
end
formatSpec = strcat(formatSpec,'%[^\n\r]');
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
W2_MEAN = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/b3_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b3_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/W3_mu.csv');
delimiter = ',';
formatSpec = '';
for i = 1:NHL(4)
  formatSpec = strcat(formatSpec,'%f');
end
formatSpec = strcat(formatSpec,'%[^\n\r]');
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
W3_MEAN = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/Sigma_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
Sigma_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;




%%%%%%%%%%%%  MEANS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% filename = strcat(ResultsFolder,'/Lambda_sd.csv')
% delimiter = ',';
% formatSpec = '%f%f%f%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
% fclose(fileID);
% LambdaTemp = [dataArray{1:end-1}];
% clearvars filename delimiter formatSpec fileID dataArray ans;
% Lambda_SD = [LambdaTemp(1), LambdaTemp(1), LambdaTemp(1)];
% 
% 
% filename = strcat(ResultsFolder,'/re_sd.csv');
% delimiter = ',';
% formatSpec = '%f%f%f%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
% fclose(fileID);
% reTemp = [dataArray{1:end-1}];
% clearvars filename delimiter formatSpec fileID dataArray ans;
% re_SD = [reTemp(1), reTemp(1), reTemp(1)];



filename = strcat(ResultsFolder,'/ParamsPosts/b1_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b1_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/W1_sd.csv');
delimiter = ',';
formatSpec = '';
for i = 1:NHL(2)
  formatSpec = strcat(formatSpec,'%f');
end
formatSpec = strcat(formatSpec,'%[^\n\r]');
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
W1_SD = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/b2_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b2_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/W2_sd.csv');
delimiter = ',';
formatSpec = '';
for i = 1:NHL(3)
  formatSpec = strcat(formatSpec,'%f');
end
formatSpec = strcat(formatSpec,'%[^\n\r]');
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
W2_SD = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/b3_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b3_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/W3_sd.csv');
delimiter = ',';
formatSpec = '';
for i = 1:NHL(4)
  formatSpec = strcat(formatSpec,'%f');
end
formatSpec = strcat(formatSpec,'%[^\n\r]');
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
W3_SD = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/Sigma_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
Sigma_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;




x=linspace(-10.0,10.0,10000);
figure(1)
for i=1:size(W1_MEAN,1)
  for j=1:size(W1_MEAN,2)
    plot(x,normpdf(x,W1_MEAN(i,j),W1_SD(i,j)));
    hold on
  end
end

figure(2)
for i=1:size(W2_MEAN,1)
  for j=1:size(W2_MEAN,2)
    plot(x,normpdf(x,W2_MEAN(i,j),W2_SD(i,j)));
    hold on
  end
end

figure(3)
for i=1:size(W3_MEAN,1)
  for j=1:size(W3_MEAN,2)
    plot(x,normpdf(x,W3_MEAN(i,j),W3_SD(i,j)));
    hold on
  end
end


figure(4)
for i=1:size(b1_MEAN,1)
  plot(x,normpdf(x,b1_MEAN(i,j),b1_SD(i,j)));
  hold on
end

figure(5)
for i=1:size(b2_MEAN,1)
  plot(x,normpdf(x,b2_MEAN(i,j),b2_SD(i,j)));
  hold on
end

figure(6)
for i=1:size(b3_MEAN,1)
  plot(x,normpdf(x,b3_MEAN(i),b3_SD(i)));
  hold on
end


figure(7)
plot(x,normpdf(x,Sigma_MEAN(i),Sigma_SD(i)));

  
  
ESum    = EData .* 0.0;
ESqrSum = EData .* 0.0;
for iSample = 1:NSamples;

%   Lambda = normrnd(Lambda_MEAN,Lambda_SD);
%   re     = normrnd(re_MEAN,re_SD);
  Lambda = [1.0,1.0,1.0];
  re     = [0.0, 0.0, 0.0];

  W1    = normrnd(W1_MEAN,W1_SD);
  W2    = normrnd(W2_MEAN,W2_SD);
  W3    = normrnd(W3_MEAN,W3_SD);

  b1    = normrnd(b1_MEAN,b1_SD);
  b2    = normrnd(b2_MEAN,b2_SD);
  b3    = normrnd(b3_MEAN,b3_SD);
  b1Mat = repmat(b1',[NData,1]);
  b2Mat = repmat(b2',[NData,1]);
  b3Mat = repmat(b3',[NData,1]);


  Sigma = normrnd(Sigma_MEAN,abs(Sigma_SD));

  G = SymmetryFunctions_JG_1(R, Lambda, re);
  
  G(:,1) = (G(:,1) - mean(1)) ./ sd(1);
  G(:,2) = (G(:,2) - mean(2)) ./ sd(2);
  G(:,3) = (G(:,3) - mean(3)) ./ sd(3);
  
  EDiat  = (LeRoy(R(:,1)') + LeRoy(R(:,2)') + LeRoy(R(:,3)'))';
  
  z1      = G * W1 + b1Mat;
  y1      = tanh(z1);
  z2      = y1 * W2 + b2Mat;
  y2      = tanh(z2);
  ETriat  = y2 * W3 + b3Mat;

  E  = ETriat + ETriat .* normrnd(0,abs(Sigma)) + EDiat * 27.2113839712790 + 0.3554625704*27.2113839712790;

  ESum    = ESum    + E;
  ESqrSum = ESqrSum + E.^2;
  
%   File = strcat(ResultsFolder, '/MATLABPostTest.csv.',num2str(iSample));
%   fileID   = fopen(File,'w');
%   fprintf(fileID,'R1,R2,R3,EData,EProp,\n')
%   for i = 1:size(E,1)
%     fprintf(fileID,'%f,%f,%f,%f,%f\n', R1(i,1),R2(i,1),R3(i,1),EData(i),E(i));
%   end 
%   
end

EMean  = ESum ./ NSamples; 
ESD    = (ESqrSum./NSamples - EMean.^2).^0.5;
EPlus  = EMean + 3.0.*ESD;
EMinus = EMean - 3.0.*ESD;

File = strcat(ResultsFolder, '/OutputPosts/PostFromDists.csv.180');
fileID   = fopen(File,'w');
fprintf(fileID,'R1,R2,R3,EData,EMean,EPlus,EMinus,ESD\n')
for i = 1:size(E,1)
  fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R1(i,1),R2(i,1),R3(i,1),EData(i),EMean(i),EPlus(i),EMinus(i),ESD(i));
end 



function [G] = SymmetryFunctions_JG_1(R, Lambda, re)
  
  p1(:) = exp( - Lambda(1) .* (R(:,1) - re(1)) );
  p2(:) = exp( - Lambda(2) .* (R(:,2) - re(2)) );
  p3(:) = exp( - Lambda(3) .* (R(:,3) - re(3)) );

  G(:,1) = ( p1       + p2       + p3 );
  G(:,2) = ( p1 .* p2 + p2 .* p3 + p3 .* p1);
  G(:,3) = ( p1 .* p2 .* p3);
  
end


function [G] = SymmetryFunctions_JG_2(R, Lambda, re)
  
  p1(:) = exp( - Lambda(1) .* (R(:,1) - re(1)) );
  p2(:) = exp( - Lambda(2) .* (R(:,2) - re(1)) );
  p3(:) = exp( - Lambda(3) .* (R(:,3) - re(1)) );

  G(:,1) = ( p1  + p2 ) ./ 2.d0;
  G(:,2) = ( p1 .* p2 );  
  G(:,3) = ( p3 );
  
end