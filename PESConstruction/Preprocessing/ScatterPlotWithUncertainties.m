close all
clear all
clc

NHL      = [3,20,20,1]
NSamples = 1000;

mean = [5.286130905766470850e-02,8.964518411003923916e-04,1.551055014926642288e-05];
sd   = [6.819021287352217131e-02,4.343095751838512396e-03,1.892240944904192220e-04];
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


ResultsFolder = '/Users/sventuri/WORKSPACE/CG-QCT/cg-qct/dtb/N3/PESs/BNN/5000Points/CalibratedParams/'

filename = strcat(ResultsFolder,'/b1_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b1_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/W1_mu.csv');
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



filename = strcat(ResultsFolder,'/b2_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b2_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/W2_mu.csv');
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



filename = strcat(ResultsFolder,'/b3_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b3_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/W3_mu.csv');
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



filename = strcat(ResultsFolder,'/Sigma_mu.csv');
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



filename = strcat(ResultsFolder,'/b1_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b1_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/W1_sd.csv');
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



filename = strcat(ResultsFolder,'/b2_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b2_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/W2_sd.csv');
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



filename = strcat(ResultsFolder,'/b3_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b3_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/W3_sd.csv');
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



filename = strcat(ResultsFolder,'/Sigma_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
Sigma_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;



for iAngle = [100.0, 120.0, 140.0]%[20.0, 40.0, 60.0, 80.0, 100.0, 120.0, 140.0, 160.0, 180.0, 135.0, 90.0]

  
  %%% READING DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  filename = strcat('/Users/sventuri/WORKSPACE/CG-QCT/run_N3_NASA/Test/PlotPES/PES_1/PES.csv.',num2str(iAngle))
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
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
  %%% SAMPLING PES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ESum    = EData .* 0.0;
  ESqrSum = EData .* 0.0;
  for iSample = 1:NSamples

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
%     
%     figure
%     histogram(G(:,1),100)
%     figure
%     histogram(G(:,2),100)
%     figure
%     histogram(G(:,3),100)
%     min(G(:,1))
%     min(G(:,2))
%     min(G(:,3))
%     max(G(:,1))
%     max(G(:,2))
%     max(G(:,3))
%     pause

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
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  %%% COMPUTING MEAN PARAMS POSTERIORS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%   W1    = W1_MEAN;
%   W2    = W2_MEAN;
%   W3    = W3_MEAN;
%   b1    = b1_MEAN;
%   b2    = b2_MEAN;
%   b3    = b3_MEAN;
%   b1Mat = repmat(b1',[NData,1]);
%   b2Mat = repmat(b2',[NData,1]);
%   b3Mat = repmat(b3',[NData,1]);
%   Sigma = 0.0;
% 
%   G = SymmetryFunctions_JG_1(R, Lambda, re);
% 
%   G(:,1) = (G(:,1) - mean(1)) ./ sd(1);
%   G(:,2) = (G(:,2) - mean(2)) ./ sd(2);
%   G(:,3) = (G(:,3) - mean(3)) ./ sd(3);
% 
%   EDiat  = (LeRoy(R(:,1)') + LeRoy(R(:,2)') + LeRoy(R(:,3)'))';
% 
%   z1      = G * W1 + b1Mat;
%   y1      = tanh(z1);
%   z2      = y1 * W2 + b2Mat;
%   y2      = tanh(z2);
%   ETriat  = y2 * W3 + b3Mat;
% 
%   EMaxPost  = ETriat + ETriat .* normrnd(0,abs(Sigma)) + EDiat * 27.2113839712790 + 0.3554625704*27.2113839712790;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  %%% COMPUTING +3 SIGMA PARAMS POSTERIORS %%%%%%%%%%%%%%%%%%%%%%%%%%%
  W1    = W1_MEAN + 3.0*W1_SD;
  W2    = W2_MEAN + 3.0*W2_SD;
  W3    = W3_MEAN + 3.0*W3_SD;
  b1    = b1_MEAN + 3.0*b1_SD;
  b2    = b2_MEAN + 3.0*b2_SD;
  b3    = b3_MEAN + 3.0*b3_SD;
  b1Mat = repmat(b1',[NData,1]);
  b2Mat = repmat(b2',[NData,1]);
  b3Mat = repmat(b3',[NData,1]);
  Sigma =  Sigma_MEAN + 3.0*Sigma_SD;

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

  EPlus  = ETriat + ETriat .* normrnd(0,abs(Sigma)) + EDiat * 27.2113839712790 + 0.3554625704*27.2113839712790;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  %%% COMPUTING -3 SIGMA PARAMS POSTERIORS %%%%%%%%%%%%%%%%%%%%%%%%%%%
  W1    = W1_MEAN - 3.0*W1_SD;
  W2    = W2_MEAN - 3.0*W2_SD;
  W3    = W3_MEAN - 3.0*W3_SD;
  b1    = b1_MEAN - 3.0*b1_SD;
  b2    = b2_MEAN - 3.0*b2_SD;
  b3    = b3_MEAN - 3.0*b3_SD;
  b1Mat = repmat(b1',[NData,1]);
  b2Mat = repmat(b2',[NData,1]);
  b3Mat = repmat(b3',[NData,1]);
  Sigma = Sigma_MEAN - 3.0*Sigma_SD;

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

  EMinus  = ETriat + ETriat .* normrnd(0,abs(Sigma)) + EDiat * 27.2113839712790 + 0.3554625704*27.2113839712790;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  %%% PLOT VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure
  %plot([EData';EData'],[EMinus';EPlus'],'k-')
  errorbar(EData,EMean,3.0.*ESD,'LineStyle','none','Color','black','CapSize',4)
  hold on
  plot(EData,EMean,'ko','MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor','k')
  %plot(EData,EMaxPost,'ro')
  plot(EData,EPlus,'r+')
  plot(EData,EMinus,'b*')
  x=linspace(-1000,1000,2000);
  plot(x,x,'g')
  plot(x,1.5*x,'b')
  plot(x,x./1.5,'b')
  plot(x,2.0*x,'r')
  plot(x,x./2.0,'r')
  xlim([0.0 20.0]);
  ylim([0.0 20.0]);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
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