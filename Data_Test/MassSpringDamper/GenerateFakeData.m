clear all
close all
clc

PathToSPES = '/Users/sventuri/Dropbox/SPES/Data_Test/MassSpringDamper/'

%size = 97;
x = [0:1:8];
y = [4.0, 4.025647e-1, -1.913556, 7.536144e-2, 8.219699e-1, -1.26e-1, -3.076154e-1, 8.109402e-2, 1.062484e-1];

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