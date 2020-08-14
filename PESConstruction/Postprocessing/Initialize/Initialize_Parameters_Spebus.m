%% The Function loads the physical constants and the parameters for plotting
%
%  Input Global Var: - Input.FigureFormat ( 'PrePrint' / 'RePrint' / 'Presentation' )
%
function Initialize_Parameters_Spebus

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
  
    global Input Syst Param
    
    
    fprintf('= Initialize_Parameters_Spebus =====================\n')
    fprintf('====================================================\n')

  
    Param.Plnck    = 6.62607004d-34;
    Param.UKb      = 1.380658e-23;
    Param.Ue       = 1.602191e-19;
    Param.KJK      = 1.380649e-23;
    Param.KeV      = 8.617330e-05;
    Param.AvN      = 6.0221409e+23;
    Param.AMUToKg  = 1.0/1.8217e+06;%1.d0/Param.AvN*1.d-3;
    Param.EhToeV   = 27.2113839712790;
    Param.KcmToEh  = 0.159360144e-2;
    Param.KcmToeV  = Param.KcmToEh * Param.EhToeV;
    Param.BToAng   = 0.52917721067d0;
    Param.AngToB   = 1.0/Param.BToAng;
    Param.BToCm    = 5.2918e-11 * 1e2;
    Param.DSWtoKg  = 1.d-3/1.8208e+03;
    Param.ATMToPa  = 101325.d0;
    Param.Ru       = Param.AvN * Param.KJK;
    
    
    Param.iFigure  = 1;
    Param.SaveFigs = 0;
  
    if strcmp(Input.FigureFormat, 'PrePrint')
        Param.LineWidth  = 2;

        Param.AxisFontSz = 26;
        Param.AxisFontNm = 'Times';

        Param.AxisLabelSz = 30;
        Param.AxisLabelNm = 'Times';
        
        Param.LegendFontSz = 24;
        Param.LegendFontNm = 'Times';
        
    elseif strcmp(Input.FigureFormat, 'PrePrint')
        Param.LineWidth  = 3;

        Param.AxisFontSz = 36;
        Param.AxisFontNm = 'Times';

        Param.AxisLabelSz = 40;
        Param.AxisLabelNm = 'Times';
        
        Param.LegendFontSz = 32;
        Param.LegendFontNm = 'Times';
        
    elseif strcmp(Input.FigureFormat, 'Presentation')
        Param.LineWidth  = 4;
        
        Param.AxisFontSz = 30;
        Param.AxisFontNm = 'Times';

        Param.AxisLabelSz = 34;
        Param.AxisLabelNm = 'Times';
        
        Param.LegendFontSz = 30;
        Param.LegendFontNm = 'Times';
        
    end

    Param.KCVec = [  0   0   0] ./ 255;
    Param.RCVec = [235, 70, 50] ./ 255;
    Param.BCVec = [55, 80, 165] ./ 255;
    Param.PCVec = [190 140 140] ./ 255;
    Param.GCVec = [65, 140, 70] ./ 255;
    Param.MCVec = [105  65 155] ./ 255;
    Param.YCVec = [245 165  50] ./ 255;
    Param.OCVec = [255 105  45] ./ 255;
    Param.JCVec = [100 100 100] ./ 255;
    Param.CCVec = [205 205 205] ./ 255;
    
    Param.CMat  = [Param.KCVec; Param.RCVec; Param.BCVec; 
                   Param.PCVec; Param.GCVec; Param.MCVec; 
                   Param.YCVec; Param.OCVec; Param.JCVec; 
                   Param.CCVec]; 

    Param.linS  = {'-',':','-.','--'};

end