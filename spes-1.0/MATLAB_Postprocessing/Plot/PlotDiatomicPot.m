function PlotDiatomicPot(iFigure, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3)

  global MultErrorFlg OnlyTriatFlg PreLogShift System AbscissaConverter
  
  R1    = linspace(1.5,10.0,10000)';
  R2    = R1.*0.d0+100.0;
  R3    = R1.*0.d0+100.0;
  RTest = [R1,R2,R3];
  
  [EPred]        = ComputeOutput(RTest, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3);
  RTest          = [1.d2,1.d2,1.d2];
  [EPredInf]     = ComputeOutput(RTest, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3);
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
