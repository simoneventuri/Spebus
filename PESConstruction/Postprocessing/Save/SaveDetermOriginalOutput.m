function [] = SaveDetermOriginalOutput(R, EPred)
  
  global Network_Folder
  
  File = strcat(Network_Folder, '/RFake.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3\n');
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f,%f,%f\n', R(i,1),R(i,2),R(i,3));
  end 
  
  File = strcat(Network_Folder, '/EFake.csv');
  fileID   = fopen(File,'w');
  fprintf(fileID,'EData\n');
  for i = 1:size(EPred,1)
    fprintf(fileID,'%f\n',EPred(i));
  end 
  
end