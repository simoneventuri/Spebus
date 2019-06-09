function [iFigure] = ComputeError(iFigure, EDataTot, EFittedTot, EPredTot, EData, EFitted, EPred)

  global AxisFontSz AxisFontNm AxisLabelSz AxisLabelNm LegendFontSz LegendFontNm SaveFigs FigDirPath RedClr GreenClr

  global EGroupsVec ShiftForError Network_Folder  
  
  NData = size(EData,1);
  
  UME_Data_Vec  = abs(EFittedTot-EDataTot);
  UME_Pred_Vec  = abs(EPredTot-EDataTot);
  UME_Data      = mean(UME_Data_Vec);
  UME_Pred      = mean(UME_Pred_Vec);
%   figure(iFigure);
%   scatter(EData,UME_Data_Vec,'g','filled');
%   hold on
%   scatter(EData,UME_Pred_Vec,'b','filled');
%   iFigure = iFigure + 1;
    
  RMSE_Data_Vec = (EFittedTot-EDataTot).^2;
  RMSE_Pred_Vec = (EPredTot-EDataTot).^2;
  RMSE_Data     = sqrt(mean(RMSE_Data_Vec));
  RMSE_Pred     = sqrt(mean(RMSE_Pred_Vec));
%   figure(iFigure);
%   scatter(EData,RMSE_Data_Vec,'g','filled');
%   hold on
%   scatter(EData,RMSE_Pred_Vec,'b','filled');
%   iFigure = iFigure + 1;
  
  RMSE_Data_Group = zeros(size(EGroupsVec,2),1);
  RMSE_Pred_Group = zeros(size(EGroupsVec,2),1);
  UME_Data_Group  = zeros(size(EGroupsVec,2),1);
  UME_Pred_Group  = zeros(size(EGroupsVec,2),1);
  Point_in_Group  = zeros(size(EGroupsVec,2),1);
  
  for i=1:size(EDataTot,1)
    Idx=1;
    while EDataTot(i) >= EGroupsVec(Idx) - ShiftForError
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
  
  
  FolderPath = strcat(Network_Folder,'/Errors/');
  [status,msg,msgID] = mkdir(FolderPath);
  
  filename = strcat(FolderPath,'/Errors.csv');
  fileID = fopen(filename,'w');
  fprintf(fileID,'# Group, En Interval, NPoints,     Orig UME,       NN UME,    Orig RMSE,      NN RMSE\n');
  for iGroup=1:size(EGroupsVec,2)
    fprintf(fileID,'%7i,%12f,%8i,%13f,%13f,%13f,%13f\n', iGroup, EGroupsVec(iGroup), Point_in_Group(iGroup), UME_Data_Group(iGroup), UME_Pred_Group(iGroup), RMSE_Data_Group(iGroup), RMSE_Pred_Group(iGroup) );
  end
  fclose(fileID);
%   
%   filename = strcat(FolderPath,'/Triat_SD.csv');
%   fileID = fopen(filename,'w');
%   fprintf(fileID,'# Fitted SD, Predicted SD\n');
%   fprintf(fileID,'%12f,%12f\n', TriatFitted_SD, TriatPred_SD );
%   fclose(fileID);
    
  
  fig = figure(iFigure);
  
  ErrMat=[UME_Data_Group,UME_Pred_Group];
  b = bar(ErrMat);
  b(1).FaceColor = GreenClr;
  b(2).FaceColor = RedClr;
  
  %clab = legend([h1,h2,h3],{'Data Points','Fitted Points','BNN Prediction'});
  %clab.Interpreter = 'latex';
  %set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
  %legend boxoff
  xlab = xlabel('Energy Group');
  %xlab.Interpreter = 'latex';
  ylab = ylabel('UME [eV]');
  %ylab.Interpreter = 'latex';
  %set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out');
  set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
  if SaveFigs == 1
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'UME' );
     export_fig(FileName, '-pdf')
     close
  elseif SaveFigs == 2
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'UME.fig' );
     saveas(fig,FileName);
  end    
  iFigure = iFigure + 1; 
  
  
  fig = figure(iFigure);
  
  ErrMat=[RMSE_Data_Group,RMSE_Pred_Group];
  b = bar(ErrMat);
  b(1).FaceColor = GreenClr;
  b(2).FaceColor = RedClr;
  
  %clab = legend([h1,h2,h3],{'Data Points','Fitted Points','BNN Prediction'});
  %clab.Interpreter = 'latex';
  %set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
  %legend boxoff
  xlab = xlabel('Energy Group');
  %xlab.Interpreter = 'latex';
  ylab = ylabel('RMSE [eV]');
  %ylab.Interpreter = 'latex';
  %set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out');
  set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
  if SaveFigs == 1
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'RMSE' );
     export_fig(FileName, '-pdf')
     close
  elseif SaveFigs == 2
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'RMSE.fig' );
     saveas(fig,FileName);
  end    
  iFigure = iFigure + 1; 
  
  
  
  
%   fig = figure(iFigure);
%   
%   sz  = ones(NData,1).*70;
%   clr = repmat(GreenClr,[NData,1]);
%   h1=scatter(EData,TriatErrorFitted,sz,clr,'o','filled');
%   hold on
%   
%   sz  = ones(NData,1).*60;
%   clr = repmat(RedClr,[NData,1]);
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
%   %set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out');
%   set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
%   if SaveFigs == 1
%      FolderPath = strcat(FigDirPath);
%      [status,msg,msgID] = mkdir(FolderPath);
%      FileName   = strcat(FolderPath, 'UME_Triat' );
%      export_fig(FileName, '-pdf')
%      close
%   elseif SaveFigs == 2
%      FolderPath = strcat(FigDirPath);
%      [status,msg,msgID] = mkdir(FolderPath);
%      FileName   = strcat(FolderPath, 'UME_Triat.fig' );
%      saveas(fig,FileName);
%   end    
%   iFigure = iFigure + 1; 

end