close all
clear all
clc


WORKSPACE_PATH = '/Users/sventuri/WORKSPACE/';
PES_NAMES      = [string('11A1'), string('11A2'), string('13A1'), string('13A2'), string('15A1'), string('15A2'), string('21A1'), string('23A1'), string('25A1')];
NPESs          = size(PES_NAMES,2);
iFigure        = 1;

AngToBohr   = 1.d0 / 0.52917721092;
KcalMolToEV = 0.0433641153087705;
ConvConst   = 120.311d0;%120.1745883646d0;%120.31146333%120.1745883646%120.31146333%94.21146333;%94.0745884; 

% figure
iPES = 0;
for PES_NAME = PES_NAMES
  iPES = iPES + 1
  PES_NAME
  WriteDataFldr        = strcat(WORKSPACE_PATH,'/SPES/spes/Data_PES/O3/UMN_AbInitio/PES_',num2str(iPES));
  [status, msg, msgID] = mkdir(WriteDataFldr)

  
  filename = strcat(WORKSPACE_PATH,'/SPES/spes/Data_PES/O3/UMN_AbInitio/', PES_NAME(:), '.dat')
  delimiter = ' ';
  formatSpec = '%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN, 'ReturnOnError', false);
  fclose(fileID);
  Col1 = dataArray{:, 1};
  Col2 = dataArray{:, 2};
  Col3 = dataArray{:, 3};
  clearvars filename delimiter formatSpec fileID dataArray ans;
  for i=1:5:length(Col1)
    E(Col1(i),1) = (Col2(i) - ConvConst) .* KcalMolToEV;
    E(Col1(i),2) = (Col3(i) - ConvConst) .* KcalMolToEV;
  end
  iPoint=1;
  for i=3:5:length(Col1)
    X2(iPoint,:) = [Col1(i), Col2(i)];
    iPoint=iPoint+1;
  end
  iPoint=1;
  for i=4:5:length(Col1)
    X3(iPoint,:) = [Col1(i), Col2(i)];
    iPoint=iPoint+1;
  end

  r1 = sqrt(X2(:,1).^2 + X2(:,2).^2);
  r3 = sqrt(X3(:,1).^2 + X3(:,2).^2);
  r2 = sqrt((X2(:,1) - X3(:,1)).^2 + (X2(:,2) - X3(:,2)).^2);
  R  = [r1, r2, r3] .* AngToBohr;
  RSorted = sort(R,2);
  Ang3 = acos( (RSorted(:,1).^2 + RSorted(:,2).^2 - RSorted(:,3).^2) ./ (2.d0.*RSorted(:,1).*RSorted(:,2)) ) .* 180 ./ pi;
  Ang1 = acos( (RSorted(:,2).^2 + RSorted(:,3).^2 - RSorted(:,1).^2) ./ (2.d0.*RSorted(:,2).*RSorted(:,3)) ) .* 180 ./ pi;
  Ang2 = acos( (RSorted(:,1).^2 + RSorted(:,3).^2 - RSorted(:,2).^2) ./ (2.d0.*RSorted(:,1).*RSorted(:,3)) ) .* 180 ./ pi;
  ANG  = [Ang1, Ang2, Ang3];
  Grp  = ones(size(E,1),1);
  
  for i=1:size(RSorted,1)
    VDiat    = 0.0;
    VDiatNew = 0.0;
    for iR=1:3
      VDiat    = VDiat    + O2_UMN(RSorted(i,iR));
      VDiatNew = VDiatNew + O2_UMN(RSorted(i,iR));
    end
    ETriat(i) = E(i,1)    - VDiatNew;
    ENew(i)   = ETriat(i) + VDiatNew;
  end

  File   = strcat('./PES_',num2str(iPES),'/REData.csv');
  fileID = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')
  % figure(1)
  % iEq=0;
  for iPoints=1:size(ANG,1)
  %   if (R(iPoints,1) >= 10.0) && (R(iPoints,2) >= 10.0)
  %     plot(R(iPoints,3),E(iPoints),'ko')
  %   elseif (R(iPoints,1) >= 10.0) && (R(iPoints,3) >= 10.0)
  %     plot(R(iPoints,2),E1(iPoints),'ro')
  %   elseif (R(iPoints,3) >= 10.0) && (R(iPoints,2) >= 10.0)
  %     plot(R(iPoints,1),E(iPoints),'bo')
  %   end
  %   hold on

  %   for jPoints=1:size(ANG,1)
  %     if (R(iPoints,1) == R(jPoints,1)) && (R(iPoints,2) == R(jPoints,2)) && (R(iPoints,3) == R(jPoints,3)) && (iPoints ~= jPoints)
  %       R(iPoints,1)
  %       R(iPoints,2)
  %       R(iPoints,3)
  %       plot3(R(iPoints,1),R(iPoints,2),E(iPoints),'ko')
  %       iEq=iEq+1;
  %     end
  %   end
  %   hold on

    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,3), RSorted(iPoints,2), RSorted(iPoints,1), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
  end
  fclose(fileID);
  % iEq
  % pause

  for iAng=[60,110,116.75,170]
    File   = strcat('./PES_',num2str(iPES),'/REData.csv.', num2str(floor(iAng)));
    fileID = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')

    for iPoints=1:size(ANG,1)
      if (ANG(iPoints,1) >= iAng-0.1) && (ANG(iPoints,1) <= iAng+0.1)
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,2), RSorted(iPoints,1), RSorted(iPoints,3), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,3), RSorted(iPoints,1), RSorted(iPoints,2), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
      elseif (ANG(iPoints,2) >= iAng-0.1) && (ANG(iPoints,2) <= iAng+0.1)
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,3), RSorted(iPoints,2), RSorted(iPoints,1), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
      elseif (ANG(iPoints,3) >= iAng-0.1) && (ANG(iPoints,3) <= iAng+0.1)
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,3), RSorted(iPoints,2), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,2), RSorted(iPoints,3), RSorted(iPoints,1), ETriat(iPoints), E(iPoints,1), ENew(iPoints));
      end
    end

    fclose(fileID);
  end
  

  File   = strcat('./PES_',num2str(iPES),'/R.csv');
  fileID = fopen(File,'w');
  fprintf(fileID,'# R1,R2,R3\n')
  for iPoints=1:size(RSorted,1)
    fprintf(fileID,'%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3));
  end
  fclose(fileID);
  
  File   = strcat('./RSampled.csv.',num2str(iPES));
  fileID = fopen(File,'w');
  for iPoints=1:size(RSorted,1)
    fprintf(fileID,'%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3));
  end
  fclose(fileID);

  File   = strcat('./PES_',num2str(iPES),'/EOrig.csv');
  fileID = fopen(File,'w');
  fprintf(fileID,'# E\n')
  for iPoints=1:size(RSorted,1)
    fprintf(fileID,'%f\n', E(iPoints,1));
  end
  fclose(fileID);

  File   = strcat('./PES_',num2str(iPES),'/ETriatOrig.csv');
  fileID = fopen(File,'w');
  fprintf(fileID,'# ETriat\n')
  for iPoints=1:size(RSorted,1)
    fprintf(fileID,'%f\n', ETriat(iPoints));
  end
  fclose(fileID);

  File   = strcat('./PES_',num2str(iPES),'/REOrig.csv');
  fileID = fopen(File,'w');
  fprintf(fileID,'# R1,R2,R3,E\n')
  for iPoints=1:size(RSorted,1)
    fprintf(fileID,'%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), E(iPoints,1));
  end
  fclose(fileID);

  File   = strcat('./PES_',num2str(iPES),'/RETriatOrig.csv');
  fileID = fopen(File,'w');
  fprintf(fileID,'# R1,R2,R3,E\n')
  for iPoints=1:size(RSorted,1)
    fprintf(fileID,'%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), ETriat(iPoints));
  end
  fclose(fileID);

  figure(iPES)
  gplotmatrix(RSorted,[],Grp)
  
  clear Col1 Col2 Col3 E ETriat ENew r1 r2 r3 X2 X3 R RSorted alpha Grp Ang1 Ang2 Ang3 ANG
  
end



% for iPES=1:NPESs
% 
%   filename = strcat(WORSPACE_PATH,'/CG-QCT/run_O3_PlotPES/Test/PlotPES/PES_', num2str(iPES), '/PESFromReadPoints.csv')
%   delimiter = ',';
%   startRow = 2;
%   formatSpec = '%f%f%f%f%[^\n\r]';
%   fileID = fopen(filename,'r');
%   dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
%   fclose(fileID);
%   R1 = dataArray{:, 1};
%   R2 = dataArray{:, 2};
%   R3 = dataArray{:, 3};
%   E  = dataArray{:, 4};
%   clearvars filename delimiter startRow formatSpec fileID dataArray ans;
% 
%   filename = strcat(WORSPACE_PATH,'/CG-QCT/cg-qct/dtb/O3/PESs/AbInitioData/E.csv.', num2str(iPES))
%   delimiter = ',';
%   startRow = 2;
%   formatSpec = '%f%f%[^\n\r]';
%   fileID = fopen(filename,'r');
%   dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'HeaderLines' ,startRow-1,  'ReturnOnError', false);
%   fclose(fileID);
%   E_A = dataArray{:, 1};
%   E_B = dataArray{:, 2};
%   clearvars filename delimiter formatSpec fileID dataArray ans;
% 
%   figure(iFigure)
%   scatter(E,E_A)
%   hold on
%   scatter(E,E_B)
%   plot([0,max(E)],[0,max(E)],'-')
%   iFigure = iFigure+1;
%   
%   clear R1 R2 R3 E E_A E_B
%   
% end 