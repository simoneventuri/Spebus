function [EPred] = ComputeOutput_GP(R, G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise)

  global MultErrorFlg OnlyTriatFlg PreLogShift NetworkType NOrd System AbscissaConverter RMin NSigma
  
  NData = size(R,1);
  
  p1 = ComputeBondOrder(R(:,1), Lambda, re);
  p2 = ComputeBondOrder(R(:,2), Lambda, re);
  p3 = ComputeBondOrder(R(:,3), Lambda, re);
  
   
  G  = ComputePIP(p1, p2, p3, G_MEAN, G_SD);
    
  ...
    
  EPred  = ...
    
  if (MultErrorFlg) 
    EPred = exp(EPred);
    EPred = EPred - PreLogShift;
  end
  if (OnlyTriatFlg)
    if strcmp(System,'N3')
      [E1, dE1] = N2_LeRoy(R(:,1)'./AbscissaConverter);
      [E2, dE2] = N2_LeRoy(R(:,2)'./AbscissaConverter);
      [E3, dE3] = N2_LeRoy(R(:,3)'./AbscissaConverter);
    elseif strcmp(System,'O3')
      [E1, dE1] = O2_UMN(R(:,1)'./AbscissaConverter);
      [E2, dE2] = O2_UMN(R(:,2)'./AbscissaConverter);
      [E3, dE3] = O2_UMN(R(:,3)'./AbscissaConverter);
    end
    EDiat = E1 + E2 + E3;
    EPred = EPred + EDiat;
  end

end