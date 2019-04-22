function [iFigure] = PlotCutsStoch(iFigure, EPredSum, EPredSumSqr)

  global alphaVec RCutsVec NSamples RStart REnd NPoints NN_Folder GP_Folder PES_Folder
  
  RBNN    = linspace(RStart, REnd, NPoints)';
  for iCut   = 1:length(alphaVec)
    
    EBNNMean(:)  = EPredSum(:,iCut)./NSamples; 
    EBNNSD(:)    = (EPredSumSqr(:,iCut)./NSamples - EBNNMean(:).^2).^0.5;
    EBNNPlus     = EBNNMean + 3.0.*EBNNSD;
    EBNNMinus    = EBNNMean - 3.0.*EBNNSD;
    
     
    filename = strcat(NN_Folder,'/CutData_',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    RAbInitio = dataArray{:, 1};
    EAbInitio = dataArray{:, 2};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    filename = strcat(NN_Folder,'/Cut_',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    RNN = dataArray{:, 1};
    ENN = dataArray{:, 2};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;

    
    filename = strcat(PES_Folder,'/Test/PlotPES/PES_1/Cut',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%q%q%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
      raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    for col=[1,2]
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
    RPES = cell2mat(raw(:, 1));
    EPES = cell2mat(raw(:, 2));
    clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;

   
    filename = strcat(GP_Folder,'/Paper',num2str(iCut),'.csv');
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%*s%*s%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    RGP      = dataArray{:, 1};
    EGPMean  = dataArray{:, 2};
    EGPPlus  = dataArray{:, 3};
    EGPMinus = dataArray{:, 4};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
     

    figure(iFigure)
    errorbar(RBNN,EBNNMean,3.0.*EBNNSD)
    hold on
    plot(RPES, EPES,'k')
    plot(RAbInitio, EAbInitio,'go')
%     
%     
%     plot(RBNN, EBNNMean,'b')
%     hold on
%     plot(RBNN, EBNNPlus,'b')
%     plot(RBNN, EBNNMinus,'b')
%     
%     plot(RGP, EGPMean,'r')
%     plot(RGP, EGPPlus,'r')
%     plot(RGP, EGPMinus,'r')
%     
%     plot(RNN, ENN,'y')
%     
%     plot(RPES, EPES,'k')
%    
%     plot(RAbInitio, EAbInitio,'go')
    
    iFigure = iFigure + 1;
     
  end  
  
end