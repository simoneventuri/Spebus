function [iFigure] = PlotScatterStoch(iFigure, R, EData, EDiatData, EFitted, EDataPred, EDataMean, EDataSD)

  global OnlyTriatFlg System RMin NSigmaInt CheckPostVec EGroupsVec ShiftScatter Network_Folder
    
  if strcmp(System,'N3')
    [FittedShift, dE1] = N2_LeRoy(RMin);
    %[FittedShift, dE1] = N2_MRCI(2.088828)
    [PRedShift, dE1]   = N2_LeRoy(RMin);
  elseif strcmp(System,'O3')
    [FittedShift, dE1] = O2_UMN(RMin);
    [PRedShift, dE1]   = O2_UMN(RMin);
  end
  if (OnlyTriatFlg)
    EData   = EData   + EDiatData;
    EFitted = EFitted + EDiatData - FittedShift;
  else
    EData   = EData + PRedShift;
  end
  
  % EAllFitted = ETriatFitted + EDiat;
  % EAllPred   = ETriatPred   + EDiat + PredShift;
  % EAllData   = ETriatData   + EDiat;
  % EAllFitted = ETriatFitted + EDiat;
  % EAllPred   = ETriatPred   + EDiat;
  % EAllData   = ETriatData   + EDiat + FittedShift;
  
  figure(iFigure)
  scatter(EData,EFitted,'b','filled');
  hold on
%   for i=1:size(EDataPred,1)
%     scatter(EData(:),EDataPred(i,:),'k','filled');
%     hold on
%   end
  errorbar(EData,EDataMean,NSigmaInt.*EDataSD,'o','MarkerSize',6,'MarkerEdgeColor','red','MarkerFaceColor','red') 
  %scatter(EData,EDataMean,20,'r','filled') 
  plot([0.0, 80.0],[0.0, 80.0],'-')
  for i=1:length(CheckPostVec)
    plot([EData(CheckPostVec(i)),EData(CheckPostVec(i))],[0,80],'k-');
  end
  iFigure = iFigure+1
 
  
  for i=1:length(CheckPostVec)
    figure(iFigure);
    h    = histogram(EDataPred(:,CheckPostVec(i)),50);
    [maxh, Idx] = max(h.Values);
    xIdx = (h.BinEdges(Idx)-h.BinEdges(Idx-1))/2;
    histfit(EDataPred(:,CheckPostVec(i)),80,'Norm')
    hold on
    plot([EData(CheckPostVec(i)),EData(CheckPostVec(i))],[0,maxh],'g-');
    plot([EFitted(CheckPostVec(i)),EFitted(CheckPostVec(i))],[0,maxh],'b-');
    iFigure = iFigure+1;
  end
  
  [iFigure] = ComputeError(iFigure, EData, EFitted, EDataMean')
  
end