%% LOADING LABELED DATA
function [NData, RData, EData, EFitted] = ReadData()

  global RFile AbscissaConverter Network_Folder alphaPlot DiatMin
  
  filename = strcat(RFile,'/R.csv')
  %filename = strcat(RFile,'/R_10000Points.csv')
  %filename = strcat(RFile,'/R_5000Points.csv')
  delimiter = ',';
  startRow = 2;
  formatSpec = '%s%s%s%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
  for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
  end
  numericData = NaN(size(dataArray{1},1),size(dataArray,2));
  for col=[1,2,3]
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
  R1 = cell2mat(raw(:, 1));
  R2 = cell2mat(raw(:, 2));
  R3 = cell2mat(raw(:, 3));
  clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
  RData = [R1, R2, R3] .* AbscissaConverter;
  
  filename = strcat(RFile, '/EOrig.csv');
  %filename = strcat(RFile, '/EFitted.csv');
  %filename = strcat(RFile, '/EFitted_10000Points.csv');
  %filename = strcat(RFile, '/EFitted_5000Points.csv');
  delimiter = ' ';
  startRow = 2;
  formatSpec = '%s%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
  for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
  end
  numericData = NaN(size(dataArray{1},1),size(dataArray,2));
  rawData = dataArray{1};
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
        numericData(row, 1) = numbers{1};
        raw{row, 1} = numbers{1};
      end
    catch me
    end
  end
  EData = cell2mat(raw(:, 1)) - DiatMin;
  clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
 
  NData =size(EData,1);
  
  filename = strcat(RFile,'/EFitted.csv');
  %filename = strcat(RFile,'/EFitted_10000Points.csv');
  %filename = strcat(RFile,'/EFitted_5000Points.csv');
  delimiter = '';
  startRow = 2;
  formatSpec = '%f%[^\n\r]';
  fileID = fopen(filename,'r');
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
  fclose(fileID);
  EFitted = dataArray{:, 1} - DiatMin;
  clearvars filename delimiter startRow formatSpec fileID dataArray ans;
  
  
  for iAng = alphaPlot
    File    = strcat(Network_Folder,'/REDataPoints.csv.',num2str(floor(iAng)))
    fileID  = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,EDiat,ETriat,E\n');
    
    for iData=1:NData
      R1     = (RData(iData,1));
      R2     = (RData(iData,2));
      R3     = (RData(iData,3));
      ETriat = (EData(iData));
      Ang3   = acos( (R1.^2 + R2.^2 - R3.^2) ./ (2.d0.*R1.*R2) ) .* 180 ./ pi;
      Ang1   = acos( (R2.^2 + R3.^2 - R1.^2) ./ (2.d0.*R2.*R3) ) .* 180 ./ pi;
      Ang2   = acos( (R1.^2 + R3.^2 - R2.^2) ./ (2.d0.*R1.*R3) ) .* 180 ./ pi;
      EDiat  = ComputeDiat([R1,R2,R3]);
      E      = EDiat + ETriat;
      
      DeltaMaxAng = 0.05;
      if     ((Ang1 <= iAng + DeltaMaxAng) && (Ang1 >= iAng - DeltaMaxAng))
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2,R1,R3,EDiat,ETriat,E);
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3,R1,R2,EDiat,ETriat,E);
      elseif ((Ang2 <= iAng + DeltaMaxAng) && (Ang2 >= iAng - DeltaMaxAng))
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1,R2,R3,EDiat,ETriat,E);
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R3,R2,R1,EDiat,ETriat,E);
      elseif ((Ang3 <= iAng + DeltaMaxAng) && (Ang3 >= iAng - DeltaMaxAng))
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R1,R3,R2,EDiat,ETriat,E);
        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', R2,R3,R1,EDiat,ETriat,E);
      end
    end
    
    fclose(fileID);
  end
  
end