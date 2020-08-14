%% Computing Averaged Error at Energy Ranges
%
function Compute_Error()

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

    fprintf('    = Compute_Error ===========================\n')
    fprintf('    ===========================================\n')

    NData = size(Data.E,1);

    UME_Data_Vec  = abs(Data.EFitTot-Data.ETot);
    UME_Pred_Vec  = abs(Data.EPredTot-Data.ETot);
    UME_Data      = mean(UME_Data_Vec);
    UME_Pred      = mean(UME_Pred_Vec);
    %   figure(iFigure);
    %   scatter(EData,UME_Data_Vec,'g','filled');
    %   hold on
    %   scatter(EData,UME_Pred_Vec,'b','filled');
    %   iFigure = iFigure + 1;

    RMSE_Data_Vec = (Data.EFitTot-Data.ETot).^2;
    RMSE_Pred_Vec = (Data.EPredTot-Data.ETot).^2;
    RMSE_Data     = sqrt(mean(RMSE_Data_Vec));
    RMSE_Pred     = sqrt(mean(RMSE_Pred_Vec));
    %   figure(iFigure);
    %   scatter(EData,RMSE_Data_Vec,'g','filled');
    %   hold on
    %   scatter(EData,RMSE_Pred_Vec,'b','filled');
    %   iFigure = iFigure + 1;

    RMSE_Data_Group = zeros(size(Input.Scatter.VGroupsVec,2),1);
    RMSE_Pred_Group = zeros(size(Input.Scatter.VGroupsVec,2),1);
    UME_Data_Group  = zeros(size(Input.Scatter.VGroupsVec,2),1);
    UME_Pred_Group  = zeros(size(Input.Scatter.VGroupsVec,2),1);
    Point_in_Group  = zeros(size(Input.Scatter.VGroupsVec,2),1);

    for i=1:size(Data.ETot,1)
        Idx=1;
        while Data.ETot(i) >= Input.Scatter.VGroupsVec(Idx) - Input.Scatter.Shift
            Idx=Idx+1;
        end
        GroupIdx(i) = Idx;

        Point_in_Group(GroupIdx(i))  = Point_in_Group(GroupIdx(i))  + 1;
        RMSE_Data_Group(GroupIdx(i)) = RMSE_Data_Group(GroupIdx(i)) + RMSE_Data_Vec(i);
        RMSE_Pred_Group(GroupIdx(i)) = RMSE_Pred_Group(GroupIdx(i)) + RMSE_Pred_Vec(i);
        UME_Data_Group(GroupIdx(i))  = UME_Data_Group(GroupIdx(i))  + UME_Data_Vec(i);
        UME_Pred_Group(GroupIdx(i))  = UME_Pred_Group(GroupIdx(i))  + UME_Pred_Vec(i);
    end

    RMSE_Data_Group = sqrt(RMSE_Data_Group ./ Point_in_Group);
    RMSE_Pred_Group = sqrt(RMSE_Pred_Group ./ Point_in_Group);
    UME_Data_Group  =      UME_Data_Group  ./ Point_in_Group;
    UME_Pred_Group  =      UME_Pred_Group  ./ Point_in_Group;

    %   TriatErrorFitted = EFitted-EData;
    %   TriatErrorPred   = EPred-EData;
    %   
    %   TriatFitted_SD   = std( log(EFitted) - log(EData) );
    %   TriatPred_SD     = std( log(EPred)   - log(EData) );


    FolderPath = strcat(Input.ParamsFldr,'/Errors/');
    [status,msg,msgID] = mkdir(FolderPath);

    filename = strcat(FolderPath,'/Errors.csv');
    fileID = fopen(filename,'w');
    fprintf(fileID,'# Group, En Interval, NPoints,     Orig UME,       NN UME,    Orig RMSE,      NN RMSE\n');
    for iGroup=1:size(Input.Scatter.VGroupsVec,2)
    fprintf(fileID,'%7i,%12f,%8i,%13f,%13f,%13f,%13f\n', iGroup, Input.Scatter.VGroupsVec(iGroup), Point_in_Group(iGroup), UME_Data_Group(iGroup), UME_Pred_Group(iGroup), RMSE_Data_Group(iGroup), RMSE_Pred_Group(iGroup) );
    end
    fclose(fileID);
    %   
    %   filename = strcat(FolderPath,'/Triat_SD.csv');
    %   fileID = fopen(filename,'w');
    %   fprintf(fileID,'# Fitted SD, Predicted SD\n');
    %   fprintf(fileID,'%12f,%12f\n', TriatFitted_SD, TriatPred_SD );
    %   fclose(fileID);


    fig = figure(Input.iFig);

    ErrMat=[UME_Data_Group,UME_Pred_Group];
    b = bar(ErrMat);
    b(1).FaceColor = Param.GCVec;
    b(2).FaceColor = Param.RCVec;

    %clab = legend([h1,h2,h3],{'Data Points','Fitted Points','BNN Prediction'});
    %clab.Interpreter = 'latex';
    %set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
    %legend boxoff
    xlab = xlabel('Energy Group');
    %xlab.Interpreter = 'latex';
    ylab = ylabel('UME [eV]');
    %ylab.Interpreter = 'latex';
    %set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out');
    set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
    if Param.SaveFigs == 1
        FolderPath = strcat(Input.FigDirPath);
        [status,msg,msgID] = mkdir(FolderPath);
        FileName   = strcat(FolderPath, 'UME' );
        export_fig(FileName, '-pdf')
        close
    elseif Param.SaveFigs == 2
        FolderPath = strcat(Input.FigDirPath);
        [status,msg,msgID] = mkdir(FolderPath);
        FileName   = strcat(FolderPath, 'UME.fig' );
        saveas(fig,FileName);
    end    
    Input.iFig = Input.iFig + 1; 


    fig = figure(Input.iFig);

    ErrMat=[RMSE_Data_Group,RMSE_Pred_Group];
    b = bar(ErrMat);
    b(1).FaceColor = Param.GCVec;
    b(2).FaceColor = Param.RCVec;

    %clab = legend([h1,h2,h3],{'Data Points','Fitted Points','BNN Prediction'});
    %clab.Interpreter = 'latex';
    %set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
    %legend boxoff
    xlab = xlabel('Energy Group');
    %xlab.Interpreter = 'latex';
    ylab = ylabel('RMSE [eV]');
    %ylab.Interpreter = 'latex';
    %set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out');
    set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
    if Param.SaveFigs == 1
        FolderPath = strcat(Input.FigDirPath);
        [status,msg,msgID] = mkdir(FolderPath);
        FileName   = strcat(FolderPath, 'RMSE' );
        export_fig(FileName, '-pdf')
        close
    elseif Param.SaveFigs == 2
        FolderPath = strcat(Input.FigDirPath);
        [status,msg,msgID] = mkdir(FolderPath);
        FileName   = strcat(FolderPath, 'RMSE.fig' );
        saveas(fig,FileName);
    end    
    Input.iFig = Input.iFig + 1; 
  
  
  
  
%   fig = figure(iFigure);
%   
%   sz  = ones(NData,1).*70;
%   clr = repmat(Param.GCVec,[NData,1]);
%   h1=scatter(EData,TriatErrorFitted,sz,clr,'o','filled');
%   hold on
%   
%   sz  = ones(NData,1).*60;
%   clr = repmat(Param.RCVec,[NData,1]);
%   h2=scatter(EData,TriatErrorPred,sz,clr,'o','filled');
%   
%   %clab = legend([h1,h2,h3],{'Data Points','Fitted Points','BNN Prediction'});
%   %clab.Interpreter = 'latex';
%   %set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
%   %legend boxoff
%   xlab = xlabel('Data Energy');
%   %xlab.Interpreter = 'latex';
%   ylab = ylabel('UME [eV]');
%   %ylab.Interpreter = 'latex';
%   %set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out');
%   set(gca,'FontSize',Param.AxisFontSz, 'FontName',Param.AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
%   if Param.SaveFigs == 1
%      FolderPath = strcat(Input.FigDirPath);
%      [status,msg,msgID] = mkdir(FolderPath);
%      FileName   = strcat(FolderPath, 'UME_Triat' );
%      export_fig(FileName, '-pdf')
%      close
%   elseif Param.SaveFigs == 2
%      FolderPath = strcat(Input.FigDirPath);
%      [status,msg,msgID] = mkdir(FolderPath);
%      FileName   = strcat(FolderPath, 'UME_Triat.fig' );
%      saveas(fig,FileName);
%   end    
%   iFigure = iFigure + 1; 

    fprintf('    ===========================================\n\n')

end