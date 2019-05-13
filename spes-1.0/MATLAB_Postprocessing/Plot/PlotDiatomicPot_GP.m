function PlotDiatomicPot_GP(iFigure, G_MEAN, G_SD, ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern)

  global MultErrorFlg OnlyTriatFlg PreLogShift System AbscissaConverter
  
  R1    = linspace(1.5,10.0,500)';
  R2    = R1.*0.d0+100.0;
  R3    = R1.*0.d0+100.0;
  RTest = [R1,R2,R3];
  
  [EPred]    = ComputeOutput_GP(RTest, G_MEAN, G_SD, ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern);
  RTest      = [1.d2,1.d2,1.d2];
  [EPredInf] = ComputeOutput_GP(RTest, G_MEAN, G_SD, ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern);
  if strcmp(System,'N3')
    [EData, dE]    = N2_LeRoy(R1'./AbscissaConverter);
    [EDataInf, te] = N2_LeRoy(1.d2');
  elseif strcmp(System,'O3')
    [EData, dE]    = O2_UMN(R1'./AbscissaConverter);
    [EDataInf, te] = O2_UMN(1.d2');
  end
  size(EData);
  
  figure(iFigure)
  plot(R1,EPred - EPredInf);
  hold on
  plot(R1,EData - EDataInf);

end
