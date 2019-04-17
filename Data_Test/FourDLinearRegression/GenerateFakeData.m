clear all
close all
clc

NIn  = 3;
NTot = 10000;
NTry = 1000;
NOut = 1;

PathToSPES = '/Users/sventuri/Dropbox/SPES/Data_Test/FourDLinearRegression/'


W1 = [3, -2, 1/3];%rand(NIn, NOut);
b1 = [-7];%rand(1);


x1 = linspace(-8,8,NTot);
x2 = linspace(2,12,NTot);
x3 = linspace(1,2,NTot);
x_out  = [x1', x2', x3'];

y = W1 * x_out' + b1 + normrnd(0,0.5,[1,NTot]);
y_out = y';

figure
plot(x_out,y_out,'o')


FileX  = strcat(PathToSPES,'/x.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x1,x2,x3\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f,%f,%f\n', x_out(i,:));
end 

FileY = strcat(PathToSPES,'/y.csv');
fileID = fopen(FileY,'w');
fprintf(fileID,'y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f\n', y_out(i));
end 

FileX = strcat(PathToSPES,'/xToCompare.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x1,x2,x3\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f,%f,%f\n', x_out(i,:));
end 

FileX = strcat(PathToSPES,'/xToPlot.csv');
fileID = fopen(FileX,'w');
fprintf(fileID,'x1,x2,x3\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f,%f,%f\n', x_out(i,:));
end 

FileY = strcat(PathToSPES,'/yToCompare.csv');
fileID = fopen(FileY,'w');
fprintf(fileID,'y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f,\n', y_out(i));
end 

FileXY = strcat(PathToSPES,'/xyToPlot.csv');
fileID = fopen(FileXY,'w');
fprintf(fileID,'x1,x2,x3,y\n')
for i = 1:length(x_out)
  fprintf(fileID,'%f,%f,%f,%f\n',[x_out(i,:),y_out(i)]);
end 