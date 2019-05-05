function ComputeOutputAtPlot_GP(iAng, R, EAllFitted, G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise)
  
  global RFile Network_Folder RMin System AbscissaConverter OnlyTriatFlg alphaPlot DiatMin

  RMinVec     = [RMin, 50.0, 50.0];
  [PredShift] = ComputeOutput(RMinVec, G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise);
  [EAllPred]  = ComputeOutput(R,       G_MEAN, G_SD, Lambda, re, Exp1, Exp2, Exp3, Exp4, l1, l2, Amp, SigmaNoise);% - PredShift;
  
  filename = strcat(Network_Folder,'/RE_All.csv.',num2str(floor(alphaPlot(iAng))));
  fileID = fopen(filename,'w');
  fprintf(fileID,'# R1,R2,R3,EFitted,EPred\n');
  for iPoints=1:size(R,1)
    fprintf(fileID,'%f,%f,%f,%f,%f\n', R(iPoints,1), R(iPoints,2), R(iPoints,3), EAllFitted(iPoints), EAllPred(iPoints));
  end
  fclose(fileID);

end
