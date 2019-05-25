function [iFigure] = Plotscatter(iFigure, R, EData, EDiatData, EFitted, EDataPred, EDataPredTot)
  
  global AxisFontSz AxisFontNm AxisLabelSz AxisLabelNm LegendFontSz LegendFontNm SaveFigs FigDirPath RedClr GreenClr

  global OnlyTriatFlg RMin EGroupsVec Network_Folder System ShiftScatter AbscissaConverter
  
  
  if (OnlyTriatFlg)
    EDataTot   = EData   + EDiatData;
    EFittedTot = EFitted + EDiatData;
  else
    EDataTot   = EData + PRedShift;
  end
  NData = size(EData,1);

  
  fig = figure(iFigure);
  
  sz  = ones(NData,1).*40;
  clr = repmat(GreenClr, [NData,1]);
  h1=scatter(EDataTot,EFittedTot,sz,clr,'filled');
  hold on
  sz  = ones(NData,1).*30;
  clr = repmat(RedClr, [NData,1]);
  h2=scatter(EDataTot,EDataPredTot,sz,clr,'filled');
  pbaspect([1,1,1])
  
  clab = legend([h1,h2],{'Original Fit','NN Predictions'});
  clab.Interpreter = 'latex';
  set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
  %legend boxoff
  xlab = xlabel('Energy Data [eV]');
  %xlab.Interpreter = 'latex';
  ylab = ylabel('Predicted Data [eV]');
  %ylab.Interpreter = 'latex';
  %set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out');
  set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
  if SaveFigs == 1
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'ScatterPlot' );
     export_fig(FileName, '-pdf')
     close
  elseif SaveFigs == 2
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'ScatterPlot.fig' );
     saveas(fig,FileName);
  end    
  
  iFigure = iFigure + 1; 
 
  
  [iFigure] = ComputeError(iFigure, EDataTot, EFittedTot, EDataPredTot, EData, EFitted, EDataPred)
  
end