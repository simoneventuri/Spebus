function [] = SaveDetermOutput(R, EData, EPred)
  
  global Network_Folder
  
  File = strcat(Network_Folder, '/MATLABDetermTest.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,EData,EPred,\n');
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f,%f,%f,%f,%f\n', R(i,1),R(i,2),R(i,3),EData(i),EPred(i));
  end 
  
end