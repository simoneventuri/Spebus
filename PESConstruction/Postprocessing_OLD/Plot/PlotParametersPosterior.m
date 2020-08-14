function [iFigure] = PlotParametersPosterior(iFigure, Lambda_MEAN, re_MEAN, W1_MEAN, W2_MEAN, W3_MEAN, b1_MEAN, b2_MEAN, b3_MEAN, Sigma_MEAN, Lambda_SD, re_SD, W1_SD, W2_SD, W3_SD, b1_SD, b2_SD, b3_SD, Sigma_SD)

  x=linspace(0.0,2.0,10000);
  figure(iFigure)
  plot(x,normpdf(x,Lambda_MEAN,Lambda_SD));
  hold on
  plot(x,normpdf(x,re_MEAN,re_SD));
  hold on
  iFigure = iFigure + 1;
  
  x=linspace(-5.0,5.0,10000);
  figure(iFigure)
  for i=1:size(W1_MEAN,1)
    for j=1:size(W1_MEAN,2)
      plot(x,normpdf(x,W1_MEAN(i,j),W1_SD(i,j)),'k');
      hold on
    end
  end
  for i=1:size(W2_MEAN,1)
    for j=1:size(W2_MEAN,2)
      plot(x,normpdf(x,W2_MEAN(i,j),W2_SD(i,j)),'r');
      hold on
    end
  end
  for i=1:size(W3_MEAN,1)
    for j=1:size(W3_MEAN,2)
      plot(x,normpdf(x,W3_MEAN(i,j),W3_SD(i,j)),'b');
      hold on
    end
  end
  iFigure = iFigure + 1;

  
  figure(iFigure)
  for i=1:size(b1_MEAN,1)
    plot(x,normpdf(x,b1_MEAN(i,j),b1_SD(i,j)),'k');
    hold on
  end
  for i=1:size(b2_MEAN,1)
    plot(x,normpdf(x,b2_MEAN(i,j),b2_SD(i,j)),'r');
    hold on
  end
  for i=1:size(b3_MEAN,1)
    plot(x,normpdf(x,b3_MEAN(i),b3_SD(i)),'b');
    hold on
  end
  iFigure = iFigure + 1;

  x=linspace(0.0,0.1,10000);
  figure(iFigure)
  plot(x,normpdf(x,Sigma_MEAN(i),Sigma_SD(i)));
  hold on
  iFigure = iFigure + 1;
  
end