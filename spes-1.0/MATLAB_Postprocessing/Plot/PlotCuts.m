function [iFigure] = PlotCuts(iFigure, G_MEAN, G_SD, Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det)

  global alphaVec RCutsVec  RStart REnd NPoints 
    
  R3      = linspace(RStart, REnd, NPoints)';
  for iCut   = 1:length(alphaVec)
     R1      = R3.*0.0 + RCutsVec(iCut);
     alpha   = alphaVec(iCut);
     R2      = sqrt( R1.^2 + R3.^2 - 2.d0.*R1.*R3.*cos(alpha/180.d0*pi) );
     R       = [R1, R2, R3];
     [EPred] = ComputeOutput(R, G_MEAN, G_SD, Lambda_Det, re_Det, W1_Det, W2_Det, W3_Det, b1_Det, b2_Det, b3_Det);
     
     figure(iFigure);
     plot(R1, EPred,'Color',[238,238,238]./256,'LineWidth',0.5);
     hold on
     iFigure = iFigure + 1;
  end  
  
end
