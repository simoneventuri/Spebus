function [iFigure] = Plotscatter(iFigure, R, EData, EDiatData, EFitted, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)
  
  global OnlyTriatFlg RMin EGroupsVec Network_Folder System ShiftScatter AbscissaConverter
  
  RMinVec      = [RMin, 50.0, 50.0];
  [PredShift]  = ComputeOutput(RMinVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
  
  [EPred]      = ComputeOutput(R, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma) - PredShift;
  
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

  figure(iFigure);
  scatter(EData,EFitted,'g','filled');
  hold on
  scatter(EData,EPred,'b','filled');
  plot([0, 30.0],[0, 30.0],'-');
  iFigure = iFigure + 1;
  
  [iFigure] = ComputeError(iFigure, EData, EFitted, EPred)
  
end