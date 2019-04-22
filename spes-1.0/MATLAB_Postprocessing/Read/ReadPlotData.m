function [RPlot, EPlot] = ReadPlotData()

  global RFile alphaVec AbscissaConverter
  
  
  filename = strcat(RFile,'/RE.csv.',num2str(alphaVec(1)));
  delimiter = ',';
  startRow = 2;
  formatSpec = '%f%f%f%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  R1     = dataArray{:, 1};
  R2     = dataArray{:, 2};
  R3     = dataArray{:, 3};
  E      = dataArray{:, 4};
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  R = [R1,R2,R3] .* AbscissaConverter;
  
  RPlot = zeros(size(R,1),size(R,2),size(alphaVec,1));
  EPlot = zeros(size(R,1),size(alphaVec,1));
  RPlot(:,:,1) = R;
  EPlot(:,1)   = E;
  
  jAng = 1;
  for iAng = alphaVec(2:end)

    filename = strcat(RFile,'/RE.csv.',num2str(iAng));
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    R1     = dataArray{:, 1};
    R2     = dataArray{:, 2};
    R3     = dataArray{:, 3};
    E      = dataArray{:, 4};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    R = [R1,R2,R3] .* AbscissaConverter;
    
    RPlot(:,:,iAng) = R;
    EPlot(:,iAng)   = E;
    
    jAng = jAng + 1;
  end
  
end