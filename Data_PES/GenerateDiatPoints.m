clear all
clc
close all

NPoints = 10;

X = lhsdesign(NPoints,3)
R1 = linspace(1.6,6.0,NPoints)';
R2 = X(:,2)*(30.0-15.0)+15.0;
R3 = X(:,3)*(30.0-15.0)+15.0;
R = [R1,R2,R3];
figure
scatter3(R1,R2,R3)
hold on 

X = lhsdesign(NPoints,3)
R1 = X(:,1)*(40.0-20.0)+20.0;
R2 = X(:,2)*(40.0-20.0)+20.0;
R3 = X(:,3)*(40.0-20.0)+20.0;
R = [R;R1,R2,R3]
scatter3(R1,R2,R3)

File   = strcat('./DiatPoints.csv');
fileID = fopen(File,'w');
fprintf(fileID,'R1,R2,R3\n')
for iPoints=1:size(R,1)
  fprintf(fileID,'%f,%f,%f\n', R(iPoints,1), R(iPoints,2), R(iPoints,3));
end
fclose(fileID);