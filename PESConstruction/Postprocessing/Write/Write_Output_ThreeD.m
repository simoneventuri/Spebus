%% Writing Data for 3d Plots
%
function Write_Output_ThreeD(R, EData, EDataPred)

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
    
    global Input ThreeD

    fprintf('  = Write_Output_ThreeD =====================\n')
    fprintf('  ===========================================\n')
    
    FolderPath         = strcat(Input.ParamsFldr, '/3DPlots_MATLAB/');
    [status,msg,msgID] = mkdir(FolderPath);
    fprintf('  Writing in Folder: ', FolderPath, '\n')

    for iPlots=1:Input.ThreeD.NPlots

        File   = strcat(FolderPath, '/Output.csv.',num2str(floor(Input.ThreeD.AngVec (iPlots))));
        fileID = fopen(File,'w');
        fprintf(fileID,'R1,R2,R3,EData,EDataPred,ErrorAbs,ErrorNorm\n');
        for i = 1:size(ThreeD.E,2)
            ErrorAbs  = abs( ThreeD.EPred(iPlots,i) - ThreeD.E(iPlots,i));
            ErrorNorm = abs((ThreeD.EPred(iPlots,i) - ThreeD.E(iPlots,i)) ./ ThreeD.E(iPlots,i)) .* 100.0;
            fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f\n', ThreeD.R(iPlots,i,1),ThreeD.R(iPlots,i,2),ThreeD.R(iPlots,i,3),ThreeD.E(iPlots,i),ThreeD.EPred(iPlots,i),ErrorAbs,ErrorNorm);
        end 
        fclose(fileID);

    end
    
    fprintf('  ===========================================\n')

end