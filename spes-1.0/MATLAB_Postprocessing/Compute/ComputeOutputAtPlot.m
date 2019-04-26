function ComputeOutputAtPlot(iAng, R, EAllFitted, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)
  
  global RFile Network_Folder RMin System AbscissaConverter OnlyTriatFlg alphaPlot

  RMinVec     = [RMin, 50.0, 50.0];
  [PredShift] = ComputeOutput(RMinVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
  [EAllPred]  = ComputeOutput(R,       Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);% - PredShift;
  
  filename = strcat(Network_Folder,'/RE_All.csv.',num2str(floor(alphaPlot(iAng))));
  fileID = fopen(filename,'w');
  fprintf(fileID,'# R1,R2,R3,EFitted,EPred\n');
  for iPoints=1:size(R,1)
    fprintf(fileID,'%f,%f,%f,%f,%f\n', R(iPoints,1), R(iPoints,2), R(iPoints,3), EAllFitted(iPoints), EAllPred(iPoints));
  end
  fclose(fileID);

end
