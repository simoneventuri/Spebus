%% The Function Loads Labeled Data
%
function Read_LabeledData()

    %%==============================================================================================================
    % 
    % Spebus, Machine Learning Toolbox for constructing Deterministic and Stochastic Potential Energy Surfaces 
    % 
    % Copyright (C) 2018 Simone Venturi (University of Illinois at Urbana-Champaign). 
    % 
    % This program is free software; you can redistribute it and/or modify it under the terms of the 
    % Version 2.1 GNU Lesser General Public License as published by the Free Software Foundation. 
    % 
    % This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    % without e=ven the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    % See the GNU Lesser General Public License for more details. 
    % 
    % You should have received a copy of the GNU Lesser General Public License along with this library; 
    % if not, write to the Free Software Foundation, Inc. 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA 
    % 
    %---------------------------------------------------------------------------------------------------------------
    %%==============================================================================================================
    
    global Param Input Syst Data
 
    
    fprintf('  = Read_LabeledData (Ab Initio + Fitted) ============\n')
    fprintf('  ====================================================\n')

    fprintf(['  Input.TrainingFldr = ', Input.TrainingFldr, '\n'])
    fprintf(['  Input.ParamsFldr   = ', Input.ParamsFldr, '\n'])

    filename = strcat(Input.TrainingFldr,'/R.csv');
    %filename = strcat(Input.TrainingFldr,'/R_Plus400.csv')
    %filename = strcat(Input.TrainingFldr,'/R_10000Points.csv')
    %filename = strcat(Input.TrainingFldr,'/R_5000Points.csv')
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
    Data.R = [R1, R2, R3] .* Param.rConverter;


    filename = strcat(Input.TrainingFldr, '/EOrig.csv');
    %filename = strcat(Input.TrainingFldr, '/EFitted_Plus400.csv');
    %filename = strcat(Input.TrainingFldr, '/EFitted_10000Points.csv');
    %filename = strcat(Input.TrainingFldr, '/EFitted_5000Points.csv');
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
    Data.E = cell2mat(raw(:, 1));% - Syst.VMin;
    clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;

    Data.N =size(Data.E,1);

    filename = strcat(Input.TrainingFldr,'/EFitted.csv');
    %filename = strcat(Input.TrainingFldr,'/EFitted_Plus400.csv');
    %filename = strcat(Input.TrainingFldr,'/EFitted_10000Points.csv');
    %filename = strcat(Input.TrainingFldr,'/EFitted_5000Points.csv');
    delimiter = '';
    startRow = 2;
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    Data.EFit = dataArray{:, 1} - Syst.VMin;
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;


    for iAng = Input.ThreeD.AngVec
        File    = strcat(Input.ParamsFldr,'/REDataPoints.csv.',num2str(floor(iAng)));
        fileID  = fopen(File,'w');
        fprintf(fileID,'R1,R2,R3,EDiat,ETriat,E\n');

        for iData=1:Data.N
            R1     = (Data.R(iData,1));
            R2     = (Data.R(iData,2));
            R3     = (Data.R(iData,3));
            ETriat = (Data.E(iData));
            Ang3   = acos( (R1.^2 + R2.^2 - R3.^2) ./ (2.d0.*R1.*R2) ) .* 180 ./ pi;
            Ang1   = acos( (R2.^2 + R3.^2 - R1.^2) ./ (2.d0.*R2.*R3) ) .* 180 ./ pi;
            Ang2   = acos( (R1.^2 + R3.^2 - R2.^2) ./ (2.d0.*R1.*R3) ) .* 180 ./ pi;
            EDiat  = Compute_DiatPots([R1,R2,R3]);
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
  
    fprintf('  ====================================================\n\n')

end