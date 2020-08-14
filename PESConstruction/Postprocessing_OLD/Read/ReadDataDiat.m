function [RDataDiat, EDataDiat] = ReadDataDiat()

  filename = '/Users/sventuri/WORKSPACE/SPES/spes/Data_PES/O3/Diats+Triat/PES_1/DiatPoints.csv';
  delimiter = ',';
  startRow = 2;

  %% Read columns of data as text:
  % For more information, see the TEXTSCAN documentation.
  formatSpec = '%s%s%s%[^\n\r]';

  %% Open the text file.
  fileID = fopen(filename,'r');

  %% Read columns of data according to the format.
  % This call is based on the structure of the file used to generate this
  % code. If an error occurs for a different file, try regenerating the code
  % from the Import Tool.
  dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

  %% Close the text file.
  fclose(fileID);

  %% Convert the contents of columns containing numeric text to numbers.
  % Replace non-numeric text with NaN.
  raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
  for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
  end
  numericData = NaN(size(dataArray{1},1),size(dataArray,2));

  for col=[1,2,3]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
      % Create a regular expression to detect and remove non-numeric prefixes and
      % suffixes.
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
  RDataDiat = [R1, R2, R3];
  
  [E1, dE1] = O2_UMN_Spebus(R1);
  [E2, dE2] = O2_UMN_Spebus(R2);
  [E3, dE3] = O2_UMN_Spebus(R3);
  EDataDiat = E1 + E2 + E3;

end
