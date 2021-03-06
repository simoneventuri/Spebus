function [iFigure] = Plotscatter_GP(iFigure, R, EData, EDiatData, EFitted, G_MEAN, G_SD, ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern)
  
  global OnlyTriatFlg RMin EGroupsVec Network_Folder System ShiftScatter AbscissaConverter
  
  RMinVec      = [RMin, 50.0, 50.0];
  [PredShift]  = ComputeOutput_GP(RMinVec, G_MEAN, G_SD, ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern);
  
  [EPred]      = ComputeOutput_GP(R, G_MEAN, G_SD, ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern) - PredShift;
  
  if strcmp(System,'N3')
    [FittedShift, dE1] = N2_LeRoy(RMin);
    %[FittedShift, dE1] = N2_MRCI(2.088828)
    [PRedShift, dE1]   = N2_LeRoy(RMin);
  elseif strcmp(System,'O3')
    [FittedShift, dE1] = O2_UMN_Spebus(RMin);
    [PRedShift, dE1]   = O2_UMN_Spebus(RMin);
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
  plot([0, 90.0],[0, 90.0],'-');
  iFigure = iFigure + 1;
  
  [iFigure] = ComputeError(iFigure, EData, EFitted, EPred)
  
end