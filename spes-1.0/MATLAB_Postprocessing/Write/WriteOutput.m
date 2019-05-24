function [] = WriteOutput(R, EData, EDataPred)

  global alphaPlot Network_Folder NPlots
  
  for iPlots=1:NPlots
    iPlots
    
    FolderPath = strcat(Network_Folder, '/Output/');
    [status,msg,msgID] = mkdir(FolderPath);
    File = strcat(FolderPath, '/Output.csv.',num2str(floor(alphaPlot(iPlots))))
    fileID   = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,EData,EDataPred,ErrorAbs,ErrorNorm\n');
    for i = 1:size(EDataPred,2)
      ErrorAbs  = abs( EDataPred(iPlots,i) - EData(iPlots,i));
      ErrorNorm = abs((EDataPred(iPlots,i) - EData(iPlots,i)) ./ EData(iPlots,i)) .* 100.0;
      fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f\n', R(iPlots,i,1),R(iPlots,i,2),R(iPlots,i,3),EData(iPlots,i),EDataPred(iPlots,i),ErrorAbs,ErrorNorm);
    end 
    fclose(fileID);
    
  end
  
end