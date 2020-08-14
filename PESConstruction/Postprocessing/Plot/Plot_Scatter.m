function Plot_Scatter()

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
    
    global Input Param Data
   

    if (Input.OnlyTriatFlg)
        Data.ETot    = Data.E    + Data.EDiat;
        Data.EFitTot = Data.EFit + Data.EDiat;
    else
        Data.ETot    = Data.E;
    end
    NData = size(Data.E,1);


    fig = figure(Input.iFig);

    sz  = ones(NData,1).*40;
    clr = repmat(Param.GCVec, [NData,1]);
    h1=scatter(Data.ETot,Data.EFitTot,sz,clr,'filled');
    hold on
    sz  = ones(NData,1).*30;
    clr = repmat(Param.RCVec, [NData,1]);
    h2=scatter(Data.ETot, Data.EPredTot,sz,clr,'filled');
    pbaspect([1,1,1])

    clab = legend([h1,h2],{'Original Fit','NN Predictions'});
    clab.Interpreter = 'latex';
    set(clab,'FontSize',Param.LegendFontSz,'FontName',Param.LegendFontNm,'Interpreter','latex','Location','Best');
    %legend boxoff
    xlab = xlabel('Energy Data [eV]');
    %xlab.Interpreter = 'latex';
    ylab = ylabel('Predicted Data [eV]');
    %ylab.Interpreter = 'latex';
    %set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out');
    set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
    if Param.SaveFigs == 1
        FolderPath = strcat(Input.FigDirPath);
        [status,msg,msgID] = mkdir(FolderPath);
        FileName   = strcat(FolderPath, 'ScatterPlot' );
        export_fig(FileName, '-pdf')
        close
    elseif Param.SaveFigs == 2
        FolderPath = strcat(Input.FigDirPath);
        [status,msg,msgID] = mkdir(FolderPath);
        FileName   = strcat(FolderPath, 'ScatterPlot.fig' );
        saveas(fig,FileName);
    end    

    Input.iFig = Input.iFig + 1; 


    Compute_Error()
  
end