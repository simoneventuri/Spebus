function [iFigure] = PlotScatterStoch(iFigure, R, EData, EDiatData, EFitted, EDataPred, EDataMean, EDataSD)

  global AxisFontSz AxisFontNm AxisLabelSz AxisLabelNm LegendFontSz LegendFontNm SaveFigs FigDirPath RedClr GreenClr

  global OnlyTriatFlg System RMin NSigmaInt CheckPostVec EGroupsVec ShiftScatter Network_Folder DiatMin DiatMax
    
  
  if (OnlyTriatFlg)
    EData   = EData   + EDiatData;
    EFitted = EFitted + EDiatData;
  else
    EData   = EData + PRedShift;
  end
  NData = size(EData,1);
  
  
  fig = figure(iFigure);
  
  sz  = ones(NData,1).*40;
  clr = repmat(GreenClr, [NData,1]);
  h1=scatter(EData,EFitted,sz,clr,'filled');
  hold on
  
%   for i=1:size(EDataPred,1)
%     scatter(EData(:),EDataPred(i,:),'k','filled');
%     hold on
%   end
  sz  = ones(NData,1).*30;
  clr = repmat(RedClr, [NData,1]);
  h2=errorbar(EData,EDataMean,NSigmaInt.*EDataSD,'o','MarkerSize',6,'MarkerEdgeColor',RedClr,'MarkerFaceColor',RedClr);
  plot([0.0, 80.0],[0.0, 80.0],'k-');
  for i=1:length(CheckPostVec)
    plot([EData(CheckPostVec(i)),EData(CheckPostVec(i))],[0,80],'k-');
  end
  pbaspect([1,1,1])

  clab = legend([h1,h2],{'Original Fit','BNN Predictions, Mean and $\pm 3\sigma$ Interval'});
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
 
  
  for i=1:length(CheckPostVec)
    fig = figure(iFigure);
    
    h    = histogram(EDataPred(:,CheckPostVec(i)),50);
    [maxh, Idx] = max(h.Values);
    xIdx = (h.BinEdges(Idx)-h.BinEdges(Idx-1))/2;
    h1=histfit(EDataPred(:,CheckPostVec(i)),80,'Norm');
    hold on
    h2=plot([EData(CheckPostVec(i)),EData(CheckPostVec(i))],[0,maxh],'g-');
    h3=plot([EFitted(CheckPostVec(i)),EFitted(CheckPostVec(i))],[0,maxh],'k-');
    
    clab = legend([h1,h2,h3],{' ',' '});
    clab.Interpreter = 'latex';
    set(clab,'FontSize',LegendFontSz,'FontName',LegendFontNm,'Interpreter','latex','Location','Best');
    %legend boxoff
    xlab = xlabel('Energy [eV]');
    %xlab.Interpreter = 'latex';
    ylab = ylabel(' ');
    %ylab.Interpreter = 'latex';
    %set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out');
    set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
    if SaveFigs == 1
       FolderPath = strcat(FigDirPath);
       [status,msg,msgID] = mkdir(FolderPath);
       FileName   = strcat(FolderPath, 'ScatterPlot_Cut', num2str(i) );
       export_fig(FileName, '-pdf')
       close
    elseif SaveFigs == 2
       FolderPath = strcat(FigDirPath);
       [status,msg,msgID] = mkdir(FolderPath);
       FileName   = strcat(FolderPath, 'ScatterPlot_Cut', num2str(i), '.fig' );
       saveas(fig,FileName);
    end    

    
    iFigure = iFigure+1;
  end
  
  [iFigure] = ComputeError(iFigure, EData, EFitted, EDataMean')
  
end