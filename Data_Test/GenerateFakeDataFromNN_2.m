clear all
close all
clc

NIn  = 3;
NTot = 100000;
NTry = 1000;
NOut = 1;

PathToSPES = '/Users/sventuri/Dropbox/SPES/Data_Test/FourDLinearInterpolation/'


% W1 = [3, -2, 1/3];%rand(NIn, NOut);
% b1 = [-7];%rand(1);
% 
% 
% 
% x1 = linspace(-8,8,NTot);
% x2 = linspace(2,12,NTot);
% x3 = linspace(1,2,NTot);
% x  = [x1', x2', x3'];
% 
% FileX = strcat(PathToSPES,'/Data_Test_2/x.csv');
% csvwrite(FileX,x)
% 
% y = W1(1) * x1.^2 + W1(2) .* x2.^2 + W1(3) .* x3.^2 + b1;
% yt = y';
% FileY = strcat(PathToSPES,'/Data_Test_2/y.csv');
% csvwrite(FileY,yt)
% 
% 
% 
% x1 = linspace(8,10,NTry);
% x2 = linspace(0,2,NTry);
% x3 = linspace(-2,-1,NTry);
% x  = [x1', x2', x3'];
% 
% FileX = strcat(PathToSPES,'/Data_Test_2/xToCompare.csv');
% csvwrite(FileX,x)
% 
% y = W1(1) * x1.^2 + W1(2) .* x2.^2 + W1(3) .* x3.^2 + b1;
% FileY = strcat(PathToSPES,'/Data_Test_2/yToCompare.csv');
% yt = y';
% csvwrite(FileY,yt)
% 
% FileY = strcat(PathToSPES,'/Data_Test_2/xyToPlot.csv');
% csvwrite(FileY,[x,yt])


size = 97;
true_intercept = 1;
true_slope = 2;

x = linspace(0, 1, size);
true_regression_line = true_intercept + true_slope * x;
y = true_regression_line + normrnd(0,0.5,[1,size]);

x_out = [x, [.1, .15, .2]]';
y_out = [y, [8, 6, 9]]';

figure
plot(x_out,y_out,'o')


FileX  = strcat(PathToSPES,'/Data_Test/LinearRegression/x.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', x_out(i));
end 

FileY = strcat(PathToSPES,'/Data_Test/LinearRegression/y.csv');
fileID = fopen(FileY,'w');
fprintf(fileID,'y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', y_out(i));
end 

FileX = strcat(PathToSPES,'/Data_Test/LinearRegression/xToCompare.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', x_out(i));
end 

FileY = strcat(PathToSPES,'/Data_Test/LinearRegression/yToCompare.csv');
fileID = fopen(FileY,'w');
fprintf(fileID,'y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', y_out(i));
end 

FileXY = strcat(PathToSPES,'/Data_Test/LinearRegression/xyToPlot.csv');
fileID = fopen(FileXY,'w');
fprintf(fileID,'x,y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f,%f\n',[x_out(i),y_out(i)]);
end 