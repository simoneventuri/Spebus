function [iFigure] = PlotSampledParameters(iFigure, Lambda_Hist, re_Hist, W1_Hist, W2_Hist, W3_Hist, b1_Hist, b2_Hist, b3_Hist, Sigma_Hist)
  
  NBins=30;
  
  figure(iFigure)
  histogram(Lambda_Hist,NBins);
  hold on
  iFigure = iFigure + 1;
  
  figure(iFigure)
  histogram(re_Hist,NBins);
  hold on
  iFigure = iFigure + 1;
  
  
  figure(iFigure)
  for i=1:size(W1_Hist,1)
    for j=1:size(W1_Hist,2)
      x = squeeze(W1_Hist(i,j,:));
      histogram(x,NBins);
      hold on
    end
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(W2_Hist,1)
    for j=1:size(W2_Hist,2)
      x = squeeze(W2_Hist(i,j,:));
      histogram(x,NBins);
      hold on
    end
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(W3_Hist,1)
    for j=1:size(W3_Hist,2)
      x = squeeze(W3_Hist(i,j,:));
      histogram(x,NBins);
      hold on
    end
  end
  iFigure = iFigure + 1;

  
  figure(iFigure)
  for i=1:size(b1_Hist,1)
    x = squeeze(b1_Hist(i,:));
    histogram(x,NBins);
    hold on
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(b2_Hist,1)
    x = squeeze(b2_Hist(i,:));
    histogram(x,NBins);
    hold on
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  for i=1:size(b3_Hist,1)
    x = squeeze(b3_Hist(i,:));
    histogram(x,NBins);
    hold on
  end
  iFigure = iFigure + 1;

  figure(iFigure)
  x = Sigma_Hist(:);
  histogram(x,NBins);
  hold on
  iFigure = iFigure + 1;
  
end
