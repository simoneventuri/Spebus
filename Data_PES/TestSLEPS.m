close all
clc

NTot = 1000

ResultsFolder = '/Users/sventuri/WORKSPACE/SPES/Output_MAC/LEPS_NoDiat/N3/'
RFile         = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/NASA_LH_5000/R.csv.120'


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


%%%%%%%%%%%%  MEANS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

filename = strcat(ResultsFolder,'/ParamsPosts/b_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/b_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
b_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/De_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
De_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/De_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
De_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/beta_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
beta_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/beta_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
beta_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/k_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
k_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/k_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
k_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/re_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
re_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/re_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
re_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;



filename = strcat(ResultsFolder,'/ParamsPosts/Sigma_mu.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
Sigma_MEAN = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;

filename = strcat(ResultsFolder,'/ParamsPosts/Sigma_sd.csv');
delimiter = '';
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
Sigma_SD = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;



% x=linspace(5,15,10000);
% figure(1)
% plot(x,normpdf(x,De_MEAN,De_SD));
% 
% x=linspace(1,3,10000);
% figure(2)
% plot(x,normpdf(x,re_MEAN,re_SD));
% 
% x=linspace(0,0.2,10000);
% figure(3)
% plot(x,normpdf(x,k_MEAN,k_SD));
% 
% x=linspace(0,3,10000);
% figure(4)
% plot(x,normpdf(x,beta_MEAN,beta_SD));
% 
% x=linspace(0,1,10000);
% figure(5)
% plot(x,normpdf(x,Sigma_MEAN,Sigma_SD));
  
  
ESum    = 0.0d0;
ESumSqr = 0.0d0;
for iSample = 1:NTot
  
  De    = normrnd(De_MEAN,De_SD);
  beta  = normrnd(beta_MEAN,beta_SD);
  re    = normrnd(re_MEAN,re_SD);
  k     = normrnd(k_MEAN,k_SD);
  b     = normrnd(b_MEAN,b_SD);
  Sigma = normrnd(Sigma_MEAN,Sigma_SD);
  
  EBond  = De     .* ( exp(-2.0 * beta .* (R - re)) - 2.0 * exp(-beta .* (R - re)) );
  EAnti  = De/2.0 .* ( exp(-2.0 * beta .* (R - re)) + 2.0 * exp(-beta .* (R - re)) );

  Q      = (EBond .* (1.0 + k) + EAnti .* (1.0 - k)) / 2.0;
  Alpha  = (EBond .* (1.0 + k) - EAnti .* (1.0 - k)) / 2.0;

  y1     = sqrt(eps + 0.5 .* ((Alpha(:,1) - Alpha(:,2)).^2 + (Alpha(:,2) - Alpha(:,3)).^2 + (Alpha(:,3) - Alpha(:,1)).^2));

  EDiat  = Q(:,1) +  Q(:,2) +  Q(:,3);
  %EDiat  = (LeRoy(R(:,1)') + LeRoy(R(:,2)') + LeRoy(R(:,3)'))';
  
  ETriat = (EDiat - y1) / (1.0 + k)  + b;
  
  E      = ETriat + ETriat .* normrnd(0,abs(Sigma));
  %E  = ETriat + ETriat .* normrnd(0,abs(Sigma)) + EDiat * 27.2113839712790 + 0.3554625704*27.2113839712790;
  
  ESum    = ESum    + E;
  ESumSqr = ESumSqr + E.^2;
  
end

EMean = ESum ./ NTot;
ESD   = sqrt(ESumSqr ./ NTot - EMean.^2);


De    = De_MEAN;
beta  = beta_MEAN;
re    = re_MEAN;
k     = k_MEAN;
b     = b_MEAN;
Sigma = Sigma_MEAN;

EBond  = De     .* ( exp(-2.0 * beta .* (R - re)) - 2.0 * exp(-beta .* (R - re)) );
EAnti  = De/2.0 .* ( exp(-2.0 * beta .* (R - re)) + 2.0 * exp(-beta .* (R - re)) );

Q      = (EBond .* (1.0 + k) + EAnti .* (1.0 - k)) / 2.0;
Alpha  = (EBond .* (1.0 + k) - EAnti .* (1.0 - k)) / 2.0;

y1     = sqrt(eps + 0.5 .* ((Alpha(:,1) - Alpha(:,2)).^2 + (Alpha(:,2) - Alpha(:,3)).^2 + (Alpha(:,3) - Alpha(:,1)).^2));

%EDiat  = Q(:,1) +  Q(:,2) +  Q(:,3);
EDiat  = (LeRoy(R(:,1)') + LeRoy(R(:,2)') + LeRoy(R(:,3)'))';

ETriat = (- y1) / (1.0 + k)  + b;

EMaxPost  = ETriat + ETriat .* normrnd(0,abs(Sigma)) + EDiat * 27.2113839712790 + 0.3554625704*27.2113839712790;



File = strcat(ResultsFolder,'/OutputPosts/PostFromDists.csv.120')
fileID   = fopen(File,'w');
fprintf(fileID,'R1,R2,R3,EData,EMean,ESD,EPlus,Eminus,EMaxPost\n');
for i = 1:size(E,1)
  fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f,%f\n', R1(i,1),R2(i,1),R3(i,1),EData(i),EMean(i),ESD(i),EMean(i)+3.d0.*ESD(i),EMean(i)-3.d0.*ESD(i),EMaxPost(i));
end 