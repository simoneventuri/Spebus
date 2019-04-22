function [iFigure] = PlotScatterStoch(iFigure, R, EData, EDiatData, EFitted, EDataPred, EDataMean, EDataSD)

  global OnlyTriatFlg System RMin
    
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
  scatter(EData,EFitted,'g','filled');
  hold on
  EDataRep = repmat(EData,1,size(EDataPred,2));
%   for i=1:size(EDataPred,2)
%     scatter(EDataRep(:,i),EDataPred(:,i),'k','filled');
%     hold on
%   end
  errorbar(EData,EDataMean,3.0.*EDataSD,'o','MarkerSize',6,'MarkerEdgeColor','red','MarkerFaceColor','red') 
  %scatter(EData,EDataMean,20,'r','filled') 
  plot([0.0, 80.0],[0.0, 80.0],'-')
  iFigure = iFigure+1
  
end