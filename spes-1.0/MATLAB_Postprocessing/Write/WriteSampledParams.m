function WriteSampledParams(OutputFolder, iSample, Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Noise)

  global NHL

  File   = strcat(OutputFolder, '/Lambda.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%f\n', Lambda(1));
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/re.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%f\n', re(1));
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/W1.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  Str=' ';
  for j=1:NHL(2)-1
    Str=strcat(Str,'%f,');
  end
  Str=strcat(Str,'%f\n');
  for i=1:NHL(1)
    fprintf(fileID,Str,W1(i,:));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/W2.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  Str='';
  for j=1:NHL(3)-1
    Str=strcat(Str,'%f,');
  end
  Str=strcat(Str,'%f\n');
  for i=1:NHL(2)
    fprintf(fileID,Str,W2(i,:));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/W3.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  for i=1:NHL(3)
    fprintf(fileID,'%f\n',W3(i));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/b1.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  for i=1:NHL(2)
    fprintf(fileID,'%f\n',b1(i));
  end
  fclose(fileID);
  
   File   = strcat(OutputFolder, '/b2.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  for i=1:NHL(3)
    fprintf(fileID,'%f\n',b2(i));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/b3.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%f\n', b3);
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/Sigma.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%f\n', Sigma);
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/Noise.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%f\n', Noise);
  fclose(fileID);

end 