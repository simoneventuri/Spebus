%% The Function Loads Unlabeled Data for 3D Plotting
%
function Read_ThreeDData()

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

    global Param Input ThreeD
 
    
    fprintf('  = Read_ThreeD (Unlabeled Data for 3D Plots) ========\n')
    fprintf('  ====================================================\n')

    fprintf(['  Input.TestingFldr = ', Input.TestingFldr, '/n'])
    
    
    filename = strcat(Input.TestingFldr,'/PESFromGrid.csv.',num2str(floor(Input.ThreeD.AngVec(1))));
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
    R = [R1,R2,R3] .* Param.rConverter;

    ThreeD.R        = zeros(Input.ThreeD.NPlots,size(R,1),size(R,2));
    ThreeD.E        = zeros(Input.ThreeD.NPlots,size(R,1));
    ThreeD.R(1,:,:) = R;
    ThreeD.E(1,:)   = E;


    jAng = 2;
    for iAng = Input.ThreeD.AngVec

        filename = strcat(Input.TestingFldr,'/PESFromGrid.csv.',num2str(floor(iAng)));
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
        R = [R1,R2,R3] .* Param.rConverter;

        ThreeD.R(jAng,:,:) = R;
        ThreeD.E(jAng,:)   = E;

        jAng = jAng + 1;
    end

    fprintf('  ====================================================\n\n')

end