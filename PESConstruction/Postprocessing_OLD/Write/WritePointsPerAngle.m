function WritePointsPerAngle(RData, EData)

  global ResultsFolder alphaVec
  
  for iAlpha=1:length(alphaVec)
    
    File = strcat(ResultsFolder, '/OutputPosts/Points.csv.', num2str(floor(alphaVec(iAlpha))));
    fileID   = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,EData\n')
    for iPoints=1:size(RData,1)
      R1 = RData(iPoints,1);
      R2 = RData(iPoints,2);
      R3 = RData(iPoints,3);
      alpha1 = acos( (R2^2 + R3^2 - R1^2) / (2.0*R2*R3) )/pi*180.0;
      alpha2 = acos( (R1^2 + R3^2 - R2^2) / (2.0*R1*R3) )/pi*180.0;
      alpha3 = acos( (R1^2 + R2^2 - R3^2) / (2.0*R1*R2) )/pi*180.0;
      if     (alpha1 > (alphaVec(iAlpha) - 0.01)) && (alpha1 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R2,R3,R1,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R3,R2,R1,EData(iPoints));
      elseif (alpha2 > (alphaVec(iAlpha) - 0.01)) && (alpha2 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R1,R3,R2,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R3,R1,R2,EData(iPoints));
      elseif (alpha3 > (alphaVec(iAlpha) - 0.01)) && (alpha3 < (alphaVec(iAlpha) + 0.01))
        fprintf(fileID,'%f,%f,%f,%f\n', R2,R1,R3,EData(iPoints));
        fprintf(fileID,'%f,%f,%f,%f\n', R1,R2,R3,EData(iPoints));
      end      
    end
    fclose(fileID);
    
  end

end