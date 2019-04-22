function [iFigure] = PlotCutsStoch(iFigure, RCut, ECut, NPoitsVec, RCutPred, ECutPred, ECutMean, ECutSD)

  global alphaVec RCutsVec NSamples RStart REnd NPoints NN_Folder GP_Folder PES_Folder NSigmaInt
  
  for iCut = 1:length(alphaVec)

    figure(iFigure)
    errorbar(RCutPred(:,1,iCut),ECutMean(:,iCut),NSigmaInt.*ECutSD(:,iCut))
    hold on
    scatter(RCut(1:NPoitsVec(iCut),iCut),ECut(1:NPoitsVec(iCut),iCut),'go')
    iFigure = iFigure + 1;
     
  end  
  
end