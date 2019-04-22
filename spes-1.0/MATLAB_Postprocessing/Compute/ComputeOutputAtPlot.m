function ComputeOutputAtPlot(iAng, R, E, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)
  
  global RFile Network_Folder RMin System AbscissaConverter OnlyTriatFlg

    
  RMinVec     = [RMin, 50.0, 50.0];
  [PredShift] = ComputeOutput(RMinVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
  [EAllPred]  = ComputeOutput(R,       Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);% - PredShift;
  
  
  if strcmp(System,'N3')
    [E1, dE1] = N2_LeRoy(R1'./AbscissaConverter);
    [E2, dE2] = N2_LeRoy(R2'./AbscissaConverter);
    [E3, dE3] = N2_LeRoy(R3'./AbscissaConverter);
  elseif strcmp(System,'O3')
    [E1, dE1] = O2_UMN(R1'./AbscissaConverter);
    [E2, dE2] = O2_UMN(R2'./AbscissaConverter);
    [E3, dE3] = O2_UMN(R3'./AbscissaConverter);
  end
  EDiat = E1 + E2 + E3;
  
  if strcmp(System,'N3')
    [FittedShift, dE1] = N2_LeRoy(RMin);
  elseif strcmp(System,'O3')
    [FittedShift, dE1] = O2_UMN(RMin);
  end
  
  EAllFitted = ETriatFitted + EDiat - FittedShift;
  if (OnlyTriatFlg)
    ETriatPred = EAllPred     - EDiat;
  else
    ETriatPred = EAllPred;
  end
  
  filename = strcat(Network_Folder,'/RE_All.csv.',num2str(iAng));
  fileID = fopen(filename,'w');
  fprintf(fileID,'# R1,R2,R3,EDiat,ETriatFitted,ETriatPred,ETotFitted,ETotPred\n');
  for iPoints=1:size(R1,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R1(iPoints), R2(iPoints), R3(iPoints), EDiat(iPoints), ETriatFitted(iPoints), ETriatPred(iPoints), EAllFitted(iPoints), EAllPred(iPoints));
  end
  fclose(fileID);

end
