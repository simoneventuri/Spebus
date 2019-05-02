clear all
clc
close all


SigmaNoise = 0.1;

GParams    = [1.d0];

PathToSPES      = '/Users/sventuri/WORKSPACE/SPES_Temp/'
PathToCGQCT     = '/Users/sventuri/WORKSPACE/CG-QCT/'

WriteDataFldr        = strcat(PathToSPES, '/Temp/');
[status, msg, msgID] = mkdir(WriteDataFldr)

PESs = 1;
for iPES = 1:PESs
  iPES

  %ReadDataFldr         = strcat(PathToCGQCT,'/run_N3_NASA/Test/PlotPES/PES_',num2str(iPES),'/')
  ReadDataFldr         = strcat(PathToCGQCT,'/run_O3_PES9/Test/PlotPES/PES_',num2str(iPES),'/')
  WriteDataFldr        = strcat(PathToSPES, '/Temp/PES_', num2str(iPES), '/')
  [status, msg, msgID] = mkdir(WriteDataFldr)

  filename = strcat(ReadDataFldr, '/PESFromReadPoints.csv')
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  R1    = dataArray{:, 1};
  R2    = dataArray{:, 2};
  R3    = dataArray{:, 3};
  E     = dataArray{:, 4};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  R     = [R1, R2, R3];
  

  File = strcat(WriteDataFldr, '/R.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3\n');
  for i = 1:size(R1,1)
    fprintf(fileID,'%e,%e,%e\n', R(i,:));
  end
  fclose(fileID);

  File = strcat(WriteDataFldr, '/EFitted.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'E\n');
  for i = 1:size(E,1)
    fprintf(fileID,'%e\n', E(i));
  end 
  fclose(fileID);

  

  %Angles = [60, 80, 100, 120, 140, 160, 180];
  Angles = [[35:5:175],[106.75:10:126.75]];
  for iAngle = Angles

    filename = strcat(ReadDataFldr, '/PESFromGrid.csv.', num2str(floor(iAngle)))
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    R1    = dataArray{:, 1};
    R2    = dataArray{:, 2};
    R3    = dataArray{:, 3};
    E     = dataArray{:, 4};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    R     = [R1, R2, R3];

    File   = strcat(WriteDataFldr, '/R.csv.', num2str(floor(iAngle)));
    fileID = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3\n')
    for i = 1:size(E,1)
      fprintf(fileID,'%e,%e,%e\n', R(i,:));
    end 
    fclose(fileID);

    File = strcat(WriteDataFldr, '/RE.csv.', num2str(floor(iAngle)));
    fileID = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,E,ENoise\n');
    E_NOISE = E .* (1.0d0 + normrnd(0.d0,SigmaNoise,length(E),1));
    for i = 1:size(E,1)
      fprintf(fileID,'%e,%e,%e,%e,%e\n', R(i,:), E(i), E_NOISE(i));
    end 
    fclose(fileID);

    File = strcat(WriteDataFldr, '/E.csv.', num2str(floor(iAngle)));
    fileID = fopen(File,'w');
    fprintf(fileID,'E\n');
    for i = 1:size(E,1)
      fprintf(fileID,'%e\n', E(i));
    end 
    fclose(fileID);

  end

end