function [RCut, ECut, NPoitsVec, RCutPred] = ReadCutData(NPtCut)

  global RFile alphaVec RCutsVec AbscissaConverter Network_Folder DataShift
  
  filename = strcat(RFile,'/R.csv');
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
  EData = cell2mat(raw(:, 1)) - DataShift;
  clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;
  
  REData = [RData, EData];
  NData  = size(EData,1);
  
  RCut      = zeros(NPtCut,1);
  ECut      = zeros(NPtCut,1);
  NPoitsVec = zeros(size(alphaVec,1),1);
  
  iCut = 1;
  for iAng = alphaVec
    iAng
    RCutsVec(iCut)
    File    = strcat(Network_Folder,'/RECut.csv.',num2str(iCut));
    fileID  = fopen(File,'w');
    fprintf(fileID,'R,E\n');
    iPoints = 0;
    
    for iData=1:NData
      R1   = (REData(iData,1));
      R2   = (REData(iData,2));
      R3   = (REData(iData,3));
      E    = (REData(iData,4));
      Ang3 = acos( (R1.^2 + R2.^2 - R3.^2) ./ (2.d0.*R1.*R2) ) .* 180 ./ pi;
      Ang1 = acos( (R2.^2 + R3.^2 - R1.^2) ./ (2.d0.*R2.*R3) ) .* 180 ./ pi;
      Ang2 = acos( (R1.^2 + R3.^2 - R2.^2) ./ (2.d0.*R1.*R3) ) .* 180 ./ pi;
      
      DeltaMaxAng = 0.1;
      DeltaMaxR   = 0.001;
      
      if     ((Ang1 <= iAng + DeltaMaxAng) && (Ang1 >= iAng - DeltaMaxAng))
        if (R2 <= RCutsVec(iCut) + DeltaMaxR) && (R2 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f\n', R3, E);
          iPoints            = iPoints+1;
          RCut(iPoints,iCut) = R3;
          ECut(iPoints,iCut) = E;
        elseif (R3 <= RCutsVec(iCut) + DeltaMaxR) && (R3 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f\n', R2, E);
          iPoints            = iPoints+1;
          RCut(iPoints,iCut) = R2;
          ECut(iPoints,iCut) = E;
        end
      elseif ((Ang2 <= iAng + DeltaMaxAng) && (Ang2 >= iAng - DeltaMaxAng))
        if (R1 <= RCutsVec(iCut) + DeltaMaxR) && (R1 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f\n', R3, E);
          iPoints            = iPoints+1;
          RCut(iPoints,iCut) = R3;
          ECut(iPoints,iCut) = E;
        elseif (R3 <= RCutsVec(iCut) + DeltaMaxR) && (R3 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f\n', R1, E);
          iPoints            = iPoints+1;
          RCut(iPoints,iCut) = R1;
          ECut(iPoints,iCut) = E;
        end
      elseif ((Ang3 <= iAng + DeltaMaxAng) && (Ang3 >= iAng - DeltaMaxAng))
        if (R2 <= RCutsVec(iCut) + DeltaMaxR) && (R2 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f\n', R1, E);
          iPoints            = iPoints+1;
          RCut(iPoints,iCut) = R1;
          ECut(iPoints,iCut) = E;
        elseif (R1 <= RCutsVec(iCut) + DeltaMaxR) && (R2 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f\n', R2, E);
          iPoints            = iPoints+1;
          RCut(iPoints,iCut) = R2;
          ECut(iPoints,iCut) = E;
        end
      end
    end
    
    fclose(fileID);
    NPoitsVec(iCut)             = iPoints;
    RCutPred(1:NPtCut,1,iCut)   = linspace(1.5,10.0,NPtCut);
    RCutPred(1:NPtCut,3,iCut)   = RCutsVec(iCut);
    RCutPred(1:NPtCut,2,iCut)   = sqrt( RCutPred(1:NPtCut,1,iCut).^2 + RCutPred(1:NPtCut,3,iCut).^2 - 2.d0.*RCutPred(1:NPtCut,1,iCut).*RCutPred(1:NPtCut,3,iCut).*cos(iAng./180.0.*pi) );
    iCut                        = iCut+1;
  end  
  
end