%% Reading Normalization Parameters
%
function Read_Scales()

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
    
    global Input Data

    fprintf('  = Read_Scales (PIP Parameters) =====================\n')
    fprintf('  ====================================================\n')

    fprintf(['  Input.ParamsFldr   = ', Input.ParamsFldr, '/n'])
    
    %%% LOADING NETWORK PARAMETERS DISTRIBUTIONS
    filename = strcat(Input.ParamsFldr,'/ScalingValues.csv')
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    ScalingValues = [dataArray{1:end-1}];
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;

    %   filename = strcat(Network_Folder,'/ScalingValues.csv')
    %   delimiter = ',';
    %   startRow = 2;
    %   endRow = 3;
    %   formatSpec = '%f%f%f%[^\n\r]';
    %   fileID = fopen(filename,'r');
    %   dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    %   fclose(fileID);
    %   ScalingValues = [dataArray{1:end-1}];
    %   clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;
    %   
    Data.G_MEAN = ScalingValues(1,:);
    Data.G_SD   = ScalingValues(2,:);

end