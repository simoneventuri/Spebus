%% The Function Initializes the Remaining Global Variables 
%
function Initialize_Input_Spebus()

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

    
    global Input Syst Param PIP

    
    fprintf('= Initialize_Input_Spebus ==========================\n')
    fprintf('====================================================\n')
    fprintf('Initializing Syst Object based on Input Object\n' )
    fprintf('====================================================\n\n')  
    
    
    Syst.NameLong   = Input.SystNameLong;
    
    Syst.iPES = ''
    if (Input.iPES > 0)
        Syst.iPES = strcat('_PES', num2str(Input.iPES));
    end
    Syst.Suffix              = Input.Suffix;

    Input.Paths.SaveFigsFldr = strcat(Input.Paths.SaveFigsFldr, '/', Syst.NameLong, Input.RunSuffix, Syst.iPES, '/');
    Input.Paths.SaveDataFldr = strcat(Input.Paths.SaveDataFldr, '/', Syst.NameLong, Input.RunSuffix, Syst.iPES, '/');
    
    
    if strcmp(Input.rUnits, 'a0')
        Param.rConverter = 1.0;
    elseif strcmp(Input.rUnits, 'A')
        Param.rConverter = 1.0 / Param.BToAng;
    else
        fprintf('ERROR! Units for Distances not Recognized! Please, change Input.rUnits\n\n')  
        pause
    end
    
    
    if strcmp(Input.VUnits, 'eV')
        Param.VConverter = 1.0;
    elseif strcmp(Input.VUnits, 'Eh')
        Param.VConverter = 1.0 / Param.Param.EhToeV;
    elseif strcmp(Input.VUnits, 'KcalMol')
        Param.VConverter = 1.0 / Param.Param.EhToeV / Param.KcmToEh;
    else
        fprintf('ERROR! Units for Energy not Recognized! Please, change Input.VUnits\n\n')  
        pause
    end
        
    
    Input.Cuts.rVec     = Input.Cuts.rVec     .* Param.rConverter;
    
    Input.ThreeD.rStart = Input.ThreeD.rStart .* Param.rConverter;
    Input.ThreeD.rEnd   = Input.ThreeD.rEnd   .* Param.rConverter;
    
    Input.ThreeD.NPlots = length(Input.ThreeD.AngVec);
    
    Input.Cuts.NCuts    = length(Input.Cuts.rVec);
    
    PIP.BondOrder_Fun   = Input.BondOrder_Fun;
    PIP.Fun             = Input.PIPFun;
    
end