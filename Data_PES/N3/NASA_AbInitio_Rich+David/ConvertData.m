clear all 
clc
close all

filename = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/NASA_AbInitio_Rich+David/ACPF_Rich.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
  raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[1,2,3,4,5]
  rawData = dataArray{col};
  for row=1:size(rawData, 1);
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
      result = regexp(rawData{row}, regexstr, 'names');
      numbers = result.numbers;
      
      % Detected commas in non-thousand locations.
      invalidThousandsSeparator = false;
      if any(numbers==',');
        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
        if isempty(regexp(numbers, thousandsRegExp, 'once'));
          numbers = NaN;
          invalidThousandsSeparator = true;
        end
      end
      % Convert numeric text to numbers.
      if ~invalidThousandsSeparator;
        numbers = textscan(strrep(numbers, ',', ''), '%f');
        numericData(row, col) = numbers{1};
        raw{row, col} = numbers{1};
      end
    catch me
    end
  end
end
Ang2  = cell2mat(raw(:, 1));
r1   = cell2mat(raw(:, 2));
r3   = cell2mat(raw(:, 3));
ERel = cell2mat(raw(:, 4));
E    = cell2mat(raw(:, 5));
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
r2   = sqrt(r1.^2 + r3.^2 - 2.0.*r1.*r3.*cos(Ang2./180.0.*pi));
Ang1 = acos( (r3.^2 + r2.^2 - r1.^2) ./ (2.0.*r2.*r3) ) ./ pi .* 180.0;
Ang3 = acos( (r2.^2 + r1.^2 - r3.^2) ./ (2.0.*r2.*r1) ) ./ pi .* 180.0;
R1   = [r1,r2,r3];
E1   = [ERel, E];
ANG1 = [Ang1, Ang2, Ang3];
Grp1 = ones(size(E1,1),1);

for i=1:size(R1,1)
  VDiat    = 0.0;
  VDiatNew = 0.0;
  for iR=1:3
    VDiat    = VDiat + N2_MRCI(R1(i,iR));
    VDiatNew = VDiatNew + N2_LeRoy(R1(i,iR));
  end
  ETriat1(i) = E1(i,1)*27.2113839712790 - VDiat;
  ENew1(i)   = ETriat1(i)               + VDiatNew;
end

File   = strcat('./REData_ACPF.csv');
fileID = fopen(File,'w');
fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')
for iPoints=1:size(ANG1,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,1), R1(iPoints,2), R1(iPoints,3), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,3), R1(iPoints,2), R1(iPoints,1), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
end
fclose(fileID);

for iAng=[60,80,100,120,140,160,180]
  File   = strcat('./REData_ACPF.csv.',num2str(iAng));
  fileID = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')

  for iPoints=1:size(ANG1,1)
    if ANG1(iPoints,1) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,1), R1(iPoints,2), R1(iPoints,3), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,2), R1(iPoints,1), R1(iPoints,3), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
    elseif ANG1(iPoints,2) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,1), R1(iPoints,3), R1(iPoints,2), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,3), R1(iPoints,1), R1(iPoints,2), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
    elseif ANG1(iPoints,3) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,2), R1(iPoints,3), R1(iPoints,1), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1(iPoints,3), R1(iPoints,2), R1(iPoints,1), ETriat1(iPoints), E1(iPoints)*27.2113839712790, ENew1(iPoints));
    end
  end
  
  fclose(fileID);
end



filename = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/NASA_AbInitio_Rich+David/MRCI_Q_David.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
  raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[1,2,3,4,5,6]
  rawData = dataArray{col};
  for row=1:size(rawData, 1);
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
      result = regexp(rawData{row}, regexstr, 'names');
      numbers = result.numbers;
      invalidThousandsSeparator = false;
      if any(numbers==',');
        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
        if isempty(regexp(numbers, thousandsRegExp, 'once'));
          numbers = NaN;
          invalidThousandsSeparator = true;
        end
      end
      if ~invalidThousandsSeparator;
        numbers = textscan(strrep(numbers, ',', ''), '%f');
        numericData(row, col) = numbers{1};
        raw{row, col} = numbers{1};
      end
    catch me
    end
  end
end
Ang2 = cell2mat(raw(:, 1));
r1   = cell2mat(raw(:, 2));
r3   = cell2mat(raw(:, 3));
E    = cell2mat(raw(:, 4));
ERel = cell2mat(raw(:, 5));
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
r2   = sqrt(r1.^2 + r3.^2 - 2.0.*r1.*r3.*cos(Ang2./180.0.*pi));
Ang1 = acos( (r3.^2 + r2.^2 - r1.^2) ./ (2.0.*r2.*r3) ) ./ pi .* 180.0;
Ang3 = acos( (r2.^2 + r1.^2 - r3.^2) ./ (2.0.*r2.*r1) ) ./ pi .* 180.0;
R2   = [r1,r2,r3];
E2   = [ERel, E];
ANG2 = [Ang1, Ang2, Ang3];
Grp2 = ones(size(E2,1),1) + 1;

for i=1:size(R2,1)
  VDiat    = 0.0;
  VDiatNew = 0.0;
  for iR=1:3
    VDiat    = VDiat + N2_MRCI(R2(i,iR));
    VDiatNew = VDiatNew + N2_LeRoy(R2(i,iR));
  end
  ETriat2(i) = E2(i,1)*27.2113839712790 - VDiat;
  ENew2(i)   = ETriat2(i)               + VDiatNew;
end

File   = strcat('./REData_MRCIQ_David.csv');
fileID = fopen(File,'w');
fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')
for iPoints=1:size(ANG2,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,1), R2(iPoints,2), R2(iPoints,3), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,3), R2(iPoints,2), R2(iPoints,1), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
end
fclose(fileID);

for iAng=[60,80,100,120,140,160,180]
  File   = strcat('./REData_MRCIQ_David.csv.',num2str(iAng));
  fileID = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')

  for iPoints=1:size(ANG2,1)
    if ANG2(iPoints,1) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,1), R2(iPoints,2), R2(iPoints,3), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,2), R2(iPoints,1), R2(iPoints,3), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
    elseif ANG2(iPoints,2) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,1), R2(iPoints,3), R2(iPoints,2), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,3), R2(iPoints,1), R2(iPoints,2), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
    elseif ANG2(iPoints,3) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,2), R2(iPoints,3), R2(iPoints,1), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2(iPoints,3), R2(iPoints,2), R2(iPoints,1), ETriat2(iPoints), E2(iPoints)*27.2113839712790, ENew2(iPoints));
    end
  end
  
  fclose(fileID);
end



filename = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/N3/NASA_AbInitio_Rich+David/MRCI_Q_Rich.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
  raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[1,2,3,4,5,6]
  rawData = dataArray{col};
  for row=1:size(rawData, 1);
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
      result = regexp(rawData{row}, regexstr, 'names');
      numbers = result.numbers;
      invalidThousandsSeparator = false;
      if any(numbers==',');
        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
        if isempty(regexp(numbers, thousandsRegExp, 'once'));
          numbers = NaN;
          invalidThousandsSeparator = true;
        end
      end
      if ~invalidThousandsSeparator;
        numbers = textscan(strrep(numbers, ',', ''), '%f');
        numericData(row, col) = numbers{1};
        raw{row, col} = numbers{1};
      end
    catch me
    end
  end
end
Ang2 = cell2mat(raw(:, 1));
r1   = cell2mat(raw(:, 2));
r3   = cell2mat(raw(:, 3));
E    = cell2mat(raw(:, 4));
ERel = cell2mat(raw(:, 5));
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
r2   = sqrt(r1.^2 + r3.^2 - 2.0.*r1.*r3.*cos(Ang2./180.0.*pi));
Ang1 = acos( (r3.^2 + r2.^2 - r1.^2) ./ (2.0.*r2.*r3) ) ./ pi .* 180.0;
Ang3 = acos( (r2.^2 + r1.^2 - r3.^2) ./ (2.0.*r2.*r1) ) ./ pi .* 180.0;
R3   = [r1,r2,r3];
E3   = [ERel, E];
ANG3 = [Ang1, Ang2, Ang3];
Grp3 = ones(size(E3,1),1) + 2;

for i=1:size(R3,1)
  VDiat    = 0.0;
  VDiatNew = 0.0;
  for iR=1:3
    VDiat    = VDiat + N2_MRCI(R3(i,iR));
    VDiatNew = VDiatNew + N2_LeRoy(R3(i,iR));
  end
  ETriat3(i) = E3(i,1)*27.2113839712790 - VDiat;
  ENew3(i)   = ETriat3(i)               + VDiatNew;
end

File   = strcat('./REData_MRCIQ_Rich.csv');
fileID = fopen(File,'w');
fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')
for iPoints=1:size(ANG3,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,1), R3(iPoints,2), R3(iPoints,3), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,3), R3(iPoints,2), R3(iPoints,1), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
end
fclose(fileID);

for iAng=[60,80,100,120,140,160,180]
  File   = strcat('./REData_MRCIQ_Rich.csv.',num2str(iAng));
  fileID = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,ETriat,E,ENew\n')

  for iPoints=1:size(ANG3,1)
    if ANG3(iPoints,1) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,1), R3(iPoints,2), R3(iPoints,3), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,2), R3(iPoints,1), R3(iPoints,3), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
    elseif ANG3(iPoints,2) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,1), R3(iPoints,3), R3(iPoints,2), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,3), R3(iPoints,1), R3(iPoints,2), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
    elseif ANG3(iPoints,3) == iAng
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,2), R3(iPoints,3), R3(iPoints,1), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
      fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3(iPoints,3), R3(iPoints,2), R3(iPoints,1), ETriat3(iPoints), E3(iPoints)*27.2113839712790, ENew3(iPoints));
    end
  end
  
  fclose(fileID);
end



R      = [R1;R2;R3];
E      = [E1;E2;E3];
ETriat = [ETriat1';ETriat2';ETriat3'];
ANG    = [ANG1;ANG2;ANG3];
Grp    = [Grp1;Grp2;Grp3];

File   = strcat('./R.csv');
fileID = fopen(File,'w');
fprintf(fileID,'# R1,R2,R3\n')
for iPoints=1:size(R,1)
  fprintf(fileID,'%f,%f,%f\n', R(iPoints,1), R(iPoints,2), R(iPoints,3));
end
fclose(fileID);

File   = strcat('./EOrig.csv');
fileID = fopen(File,'w');
fprintf(fileID,'# E\n')
for iPoints=1:size(R,1)
  fprintf(fileID,'%f\n', E(iPoints,1)*27.2113839712790);
end
fclose(fileID);

File   = strcat('./ETriatOrig.csv');
fileID = fopen(File,'w');
fprintf(fileID,'# ETriat\n')
for iPoints=1:size(R,1)
  fprintf(fileID,'%f\n', ETriat(iPoints));
end
fclose(fileID);

File   = strcat('./REOrig.csv');
fileID = fopen(File,'w');
fprintf(fileID,'# R1,R2,R3,E\n')
for iPoints=1:size(R,1)
  fprintf(fileID,'%f,%f,%f,%f\n', R(iPoints,1), R(iPoints,2), R(iPoints,3), E(iPoints,1)*27.2113839712790);
end
fclose(fileID);

File   = strcat('./RETriatOrig.csv');
fileID = fopen(File,'w');
fprintf(fileID,'# R1,R2,R3,E\n')
for iPoints=1:size(R,1)
  fprintf(fileID,'%f,%f,%f,%f\n', R(iPoints,1), R(iPoints,2), R(iPoints,3), ETriat(iPoints));
end
fclose(fileID);

figure
gplotmatrix(R,[],Grp)