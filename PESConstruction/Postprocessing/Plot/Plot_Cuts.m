%% The Function Plots the 2D Cuts
%
function Plot_Cuts()

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
    
    global Input Param Cut 
    

    for iCut = 1:Input.Cuts.NCuts

        fig = figure(Input.iFig);

        sz  = ones(Cut.NData(iCut),1).*70;
        clr = repmat([0.0, 0.0, 0.0],[Cut.NData(iCut),1]);
        h1=scatter(Cut.R(iCut,1:Cut.NData(iCut),1),Cut.E(iCut,1:Cut.NData(iCut)),sz,clr,'o','filled');
        hold on

        sz  = ones(Cut.NData(iCut),1).*60;
        clr = repmat(Param.GCVec, [Cut.NData(iCut),1]);
        h2=scatter(Cut.R(iCut,1:Cut.NData(iCut),1),Cut.EFit(iCut,1:Cut.NData(iCut)),sz,clr,'o','filled');

        Temp1 = squeeze(Cut.RPred(iCut,:,1));
        Temp2 = squeeze(Cut.EPred(iCut,:));
        h3=plot(Temp1, Temp2, 'Color', Param.RCVec, 'linewidth',1);

        clab = legend([h1,h2,h3],{'Data Points','Fitted Points','NN Prediction'});
        clab.Interpreter = 'latex';
        set(clab,'FontSize',Param.LegendFontSz,'FontName',Param.LegendFontNm,'Interpreter','latex','Location','Best');
        %legend boxoff
        xlab = xlabel('r $[a_0]$');
        %xlab.Interpreter = 'latex';
        ylab = ylabel('V [eV]');
        %ylab.Interpreter = 'latex';
        %set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out');
        set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
        if Param.SaveFigs == 1
           FolderPath = strcat(Input.FigDirPath);
           [status,msg,msgID] = mkdir(FolderPath);
           FileName   = strcat(FolderPath, 'Cut', num2str(iCut) );
           export_fig(FileName, '-pdf')
           close
        elseif Param.SaveFigs == 2
           FolderPath = strcat(Input.FigDirPath);
           [status,msg,msgID] = mkdir(FolderPath);
           FileName   = strcat(FolderPath, 'Cut', num2str(iCut), '.fig' );
           saveas(fig,FileName);
        end    
        Input.iFig = Input.iFig + 1; 

    end  
  
end