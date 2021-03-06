function [Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist] = ComputeParametersSamples(iSample, Lambda_MEAN, Lambda_SD, re_MEAN, re_SD, W1_MEAN, W1_SD, W2_MEAN, W2_SD, W3_MEAN, W3_SD, b1_MEAN, b1_SD, b2_MEAN, b2_SD, b3_MEAN, b3_SD, Sigma_MEAN, Sigma_SD, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist)

  %Lambda = normrnd(Lambda_MEAN,Lambda_SD);
  %re     = normrnd(re_MEAN,re_SD);
  Lambda = ones(3,1).*normrnd(Lambda_MEAN(1),Lambda_SD(1));
  re     = ones(3,1).*normrnd(re_MEAN(1),re_SD(1));


  W1    = normrnd(W1_MEAN,W1_SD);
  W2    = normrnd(W2_MEAN,W2_SD);
  W3    = normrnd(W3_MEAN,W3_SD);

  b1    = normrnd(b1_MEAN,b1_SD);
  b2    = normrnd(b2_MEAN,b2_SD);
  b3    = normrnd(b3_MEAN,b3_SD);

  Sigma = normrnd(Sigma_MEAN,Sigma_SD);

  Lambda_Hist(iSample,:) = Lambda;
  re_Hist(iSample,:)     = re;
  
  W1_Hist(iSample,:,:) = W1;
  W2_Hist(iSample,:,:) = W2;
  W3_Hist(iSample,:,:) = W3;
  
  b1_Hist(iSample,:)   = b1;
  b2_Hist(iSample,:)   = b2;
  b3_Hist(iSample,:)   = b3;
  
  Sigma_Hist(iSample)  = Sigma;
    
end 