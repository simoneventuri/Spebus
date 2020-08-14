function [iFigure] = PlotCuts(iFigure, RCut, ECut, EFittedCut, NPoitsVec, RCutPred, ECutPred)

  global AxisFontSz AxisFontNm AxisLabelSz AxisLabelNm LegendFontSz LegendFontNm SaveFigs FigDirPath RedClr GreenClr

  global alphaCutsVec RCutsVec NSamples RStart REnd NPoints NN_Folder GP_Folder PES_Folder NSigmaInt
  
  for iCut = 1:length(alphaCutsVec)

    fig = figure(iFigure);
    
    sz  = ones(NPoitsVec(iCut),1).*70;
    clr = repmat([0.0, 0.0, 0.0],[NPoitsVec(iCut),1]);
    h1=scatter(RCut(iCut,1:NPoitsVec(iCut),1),ECut(iCut,1:NPoitsVec(iCut)),sz,clr,'o','filled');
    hold on

    sz  = ones(NPoitsVec(iCut),1).*60;
    clr = repmat(GreenClr, [NPoitsVec(iCut),1]);
    h2=scatter(RCut(iCut,1:NPoitsVec(iCut),1),EFittedCut(iCut,1:NPoitsVec(iCut)),sz,clr,'o','filled');
    
    Temp1 = squeeze(RCutPred(iCut,:,1));
    Temp2 = squeeze(ECutPred(iCut,:));
    h3=plot(Temp1, Temp2, 'Color', RedClr, 'linewidth',1);
    
    clab = legend([h1,h2,h3],{'Data Points','Fitted Points','NN Prediction'});
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
  
end