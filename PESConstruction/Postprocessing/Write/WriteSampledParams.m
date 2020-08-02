function WriteSampledParams(OutputFolder, iSample, Lambda, re, W1, W2, W3, b1, b2, b3, Sigma, Noise)

  global NHL
  
  OutputFolder = strcat(OutputFolder, '/CalibratedParams/');
  [status,msg,msgID] = mkdir(OutputFolder);

  File   = strcat(OutputFolder, '/Lambda.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%d\n', Lambda(1));
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/re.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%d\n', re(1));
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/W1.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  Str=' ';
  for j=1:NHL(2)-1
    Str=strcat(Str,'%d,');
  end
  Str=strcat(Str,'%d\n');
  for i=1:NHL(1)
    fprintf(fileID,Str,W1(i,:));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/W2.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  Str='';
  for j=1:NHL(3)-1
    Str=strcat(Str,'%d,');
  end
  Str=strcat(Str,'%d\n');
  for i=1:NHL(2)
    fprintf(fileID,Str,W2(i,:));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/W3.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  for i=1:NHL(3)
    fprintf(fileID,'%d\n',W3(i));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/b1.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  for i=1:NHL(2)
    fprintf(fileID,'%d\n',b1(i));
  end
  fclose(fileID);
  
   File   = strcat(OutputFolder, '/b2.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  for i=1:NHL(3)
    fprintf(fileID,'%d\n',b2(i));
  end
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/b3.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%d\n', b3);
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/Sigma.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%d\n', Sigma);
  fclose(fileID);
  
  File   = strcat(OutputFolder, '/Noise.csv.',num2str(iSample));
  fileID = fopen(File,'w');
  fprintf(fileID,'%d\n', Noise);
  fclose(fileID);

end 