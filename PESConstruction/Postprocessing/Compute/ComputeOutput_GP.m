function [EPred] = ComputeOutput_GP(R, G_MEAN, G_SD, ModPip, re, Obs_Idx_Pts, Amp, Alpha, LKern)

  global MultErrorFlg OnlyTriatFlg PreLogShift System AbscissaConverter
  
  NData  = size(R,1);
  N      = length(Alpha);
  
  Lambda = ModPip(1);
  Exp1   = ModPip(2);
  Exp2   = ModPip(3);
  Exp3   = ModPip(4);
  Exp4   = ModPip(5);
  
  p1 = exp( - Lambda * (R(:,1).^Exp1 - re(1)) )';
  p2 = exp( - Lambda * (R(:,2).^Exp1 - re(1)) )';
  p3 = exp( - Lambda * (R(:,3).^Exp1 - re(1)) )';
   
  G  = ComputePIP(p1, p2, p3, G_MEAN, G_SD);
  
  G(:,1) = G(:,1).^Exp2;
  G(:,2) = G(:,2).^Exp3;
  G(:,3) = G(:,3).^Exp4;
    
  G = (G - G_MEAN) ./ G_SD;
  
  Gamma = (1./LKern.^2).';
  Alpha = Alpha.';
  
  for j=1:NData
    GTemp = G(j,:);
    for i=1:N
      oo   = GTemp - Obs_Idx_Pts(i,:);
      norm = Gamma.*oo;
      C    = dot(oo,norm);
      k(i) = 1./(1. + 0.5 * C);
    end
    EPred(j) =  dot(k,Alpha);
%     temp     = sla.solve_triangular(L, k, lower=True)
%     Varr[j]  = amp**2 - (amp**4)*np.dot(temp, temp)
  end
  EPred = Amp^2 * EPred.';
  
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