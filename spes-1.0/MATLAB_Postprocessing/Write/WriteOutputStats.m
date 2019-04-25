function [] = WriteOutputStats(R, EData, EMean, ESD)

  global alphaPlot Network_Folder NSigmaInt NPlots

  for iPlots=1:NPlots
    
    EPlus  = EMean(iPlots,:) + NSigmaInt.*ESD(iPlots,:);
    EMinus = EMean(iPlots,:) - NSigmaInt.*ESD(iPlots,:);
    
    File = strcat(Network_Folder, '/OutputPosts/OutputStats.csv.',num2str(floor(alphaPlot(iPlots))))
    fileID   = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,EData,EMean,EPlus,EMinus,ESD\n')
    for i = 1:size(EMean,2)
      fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R(iPlots,i,1),R(iPlots,i,2),R(iPlots,i,3),EData(iPlots,i),EMean(iPlots,i),EPlus(i),EMinus(i),ESD(iPlots,i));
    end 
    fclose(fileID);
    
  end
  
end