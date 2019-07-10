function [iFigure] = PlotCutsAngle(iFigure, RCut, ECut, EFittedCut, NPoitsVec, RCutPred, ECutPred)

  global AxisFontSz AxisFontNm AxisLabelSz AxisLabelNm LegendFontSz LegendFontNm SaveFigs FigDirPath RedClr GreenClr

  global alphaCutsVec RCutsVec NSamples RStart REnd NPoints NN_Folder GP_Folder PES_Folder NSigmaInt
  
  fig = figure(iFigure);
  
  [A,B]=max(AngleVec);
  for iSample=1:size(ECutAnglePred,1)
    Temp = -ECutAnglePred(iSample,end) + ECutAngleFake(end); 
    h3=plot(AngFake, ECutAnglePred(iSample,:)+Temp,'k','LineWidth',0.5);
    hold on
  end
  h2=plot(AngFake, ECutAngleFake,'g');
  h1=scatter(AngleVec, ECutAngle-ECutAngleFake(end)+ECutAngle(B))
  
  clab = legend([h1,h2,h3],{'Data Points','Fitted Points','BNN Prediction'});
  clab.Interpreter = 'latex';
  set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
  %legend boxoff
  xlab = xlabel('R [a_0]');
  %xlab.Interpreter = 'latex';
  ylab = ylabel('E [eV]');
  %ylab.Interpreter = 'latex';
  %set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out');
  set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
  if SaveFigs == 1
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'Cut', num2str(iCut) );
     export_fig(FileName, '-pdf')
     close
  elseif SaveFigs == 2
     FolderPath = strcat(FigDirPath);
     [status,msg,msgID] = mkdir(FolderPath);
     FileName   = strcat(FolderPath, 'Cut', num2str(iCut), '.fig' );
     saveas(fig,FileName);
  end    
  iFigure = iFigure + 1; 
  
end