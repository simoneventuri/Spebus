function [] = SaveMomenta(R, EData, ESum, ESqrSum)

  global NSamples ResultsFolder MomentaFileName

  EMean  = ESum ./ NSamples; 
  ESD    = (ESqrSum./NSamples - EMean.^2).^0.5;
  EPlus  = EMean + 3.0.*ESD;
  EMinus = EMean - 3.0.*ESD;

  File = strcat(ResultsFolder, '/OutputPosts/', MomentaFileName);
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,EData,EMean,EPlus,EMinus,ESD\n')
  for i = 1:size(EMean,1)
    fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R(i,1),R(i,2),R(i,3),EData(i),EMean(i),EPlus(i),EMinus(i),ESD(i));
  end 
  fclose(fileID);
  
end