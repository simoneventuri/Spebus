function [LHSSamples, Lambda_LHS, re_LHS, W1_LHS, W2_LHS, W3_LHS, b1_LHS, b2_LHS, b3_LHS, Sigma_LHS] = ComputeLHS(NSamplesLHS, Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD)

  global NHL

  ParMean = [Lambda_MEAN(1); re_MEAN(1); W1_MEAN(:); W2_MEAN(:); W3_MEAN(:); b1_MEAN(:); b2_MEAN(:); b3_MEAN(:); Sigma_MEAN(:)];
  ParSD   = [Lambda_SD(1);   re_SD(1);   W1_SD(:);   W2_SD(:);   W3_SD(:);   b1_SD(:);   b2_SD(:);   b3_SD(:);   Sigma_SD(:)];

  NPar    = size(ParSD,1);
  ParCov  = diag(ParSD);
  
  for i=1:NPar
    LHSSamples(1:NSamplesLHS,i) = lhsnorm(ParMean(i),ParSD(i).^2,NSamplesLHS);
  end
  
  iIni=1;
  iFin=iIni;
  Lambda_LHS = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni;
  re_LHS     = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni+NHL(1)*NHL(2)-1;
  W1_LHSTemp = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni+NHL(2)*NHL(3)-1;
  W2_LHSTemp = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni+NHL(3)*NHL(4)-1;
  W3_LHS     = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni+NHL(2)-1;
  b1_LHS     = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni+NHL(3)-1;
  b2_LHS     = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni;
  b3_LHS     = LHSSamples(:,iIni:iFin);
  iIni=iFin+1;
  iFin=iIni;
  Sigma_LHS  = LHSSamples(:,iIni:iFin);
    
  ii=0;
  for j=1:NHL(2)
    for i=1:NHL(1)
      ii=ii+1;
      W1_LHS(:,i,j) = W1_LHSTemp(:,ii);
    end
  end
  
  ii=0;
  for j=1:NHL(3)
    for i=1:NHL(2)
      ii=ii+1;
      W2_LHS(:,i,j) = W2_LHSTemp(:,ii);
    end
  end  
  
  %histogram(LHSSamples(:,NPar),30)
  
end