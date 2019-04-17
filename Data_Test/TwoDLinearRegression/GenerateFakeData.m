clear all
close all
clc

PathToSPES = '/Users/sventuri/Dropbox/SPES/Data_Test/TwoDLinearRegression/'

%size = 97;
size = 100;
true_intercept = 1;
true_slope = 2;

x = linspace(0, 1, size);
true_regression_line = true_intercept + true_slope * x;
y = true_regression_line + normrnd(0,0.5,[1,size]);

%x_out = [x, [.1, .15, .2]]';
%y_out = [y, [8, 6, 9]]';
x_out = [x]';
y_out = [y]';

figure
plot(x_out,y_out,'o')


FileX  = strcat(PathToSPES,'/x.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', x_out(i));
end 

FileY = strcat(PathToSPES,'/y.csv');
fileID = fopen(FileY,'w');
fprintf(fileID,'y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', y_out(i));
end 

FileX = strcat(PathToSPES,'/xToCompare.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', x_out(i));
end 

FileX = strcat(PathToSPES,'/xToPlot.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', x_out(i));
end 

FileY = strcat(PathToSPES,'/yToCompare.csv');
fileID = fopen(FileY,'w');
fprintf(fileID,'y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', y_out(i));
end 

FileXY = strcat(PathToSPES,'/xyToPlot.csv');
fileID = fopen(FileXY,'w');
fprintf(fileID,'x,y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f,%f\n',[x_out(i),y_out(i)]);
end 