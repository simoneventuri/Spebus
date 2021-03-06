function [RPlot, EPlot] = ReadPlotData()

  global RPlotFile alphaPlot AbscissaConverter
  
  
  filename = strcat(RPlotFile,'/PESFromGrid.csv.',num2str(floor(alphaPlot(1))))
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
  
  RPlot = zeros(length(alphaPlot),size(R,1),size(R,2));
  EPlot = zeros(length(alphaPlot),size(R,1));
  RPlot(1,:,:) = R;
  EPlot(1,:)   = E;
  
  
  jAng = 2;
  for iAng = alphaPlot(2:end)
    
    filename = strcat(RPlotFile,'/PESFromGrid.csv.',num2str(floor(iAng)));
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
    
    RPlot(jAng,:,:) = R;
    EPlot(jAng,:)   = E;
    
    jAng = jAng + 1;
  end
  
end