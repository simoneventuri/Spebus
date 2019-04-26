function [iFigure] = PlotCutsStoch(iFigure, RCut, ECut, EFittedCut, NPoitsVec, RCutPred, ECutPred, ECutMean, ECutSD)

  global alphaVec RCutsVec NSamples RStart REnd NPoints NN_Folder GP_Folder PES_Folder NSigmaInt
  
  for iCut = 1:length(alphaVec)

    figure(iFigure)
    %errorbar(RCutPred(iCut,:,1),ECutMean(iCut,:),NSigmaInt.*ECutSD(iCut,:))
    hold on
    for iSample=1:size(ECutPred,2)
      Temp1 = squeeze(RCutPred(iCut,:,1));
      Temp2 = squeeze(ECutPred(iCut,iSample,:));
      plot(Temp1, Temp2);
    end
    scatter(RCut(iCut,1:NPoitsVec(iCut),1),ECut(iCut,1:NPoitsVec(iCut)),'go')
    scatter(RCut(iCut,1:NPoitsVec(iCut),1),EFittedCut(iCut,1:NPoitsVec(iCut)),'ro')
    iFigure = iFigure + 1;
     
  end  
  
end