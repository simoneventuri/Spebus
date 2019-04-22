function [] = WriteOutputStats(R, EData, EMean, ESD)

  global alphaPlot Network_Folder NSigmaInt NPlots

  for iPlots=1:NPlots
    
    EPlus  = EMean(:,iPlots) + NSigmaInt.*ESD(:,iPlots);
    EMinus = EMean(:,iPlots) - NSigmaInt.*ESD(:,iPlots);
    
    File = strcat(Network_Folder, '/OutputPosts/OutputStats.csv.',num2str(floor(alphaPlot(iPlots))))
    fileID   = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,EData,EMean,EPlus,EMinus,ESD\n')
    for i = 1:size(EMean,1)
      fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f\n', R(i,1,iPlots),R(i,2,iPlots),R(i,3,iPlots),EData(i,iPlots),EMean(i,iPlots),EPlus(i),EMinus(i),ESD(i,iPlots));
    end 
    fclose(fileID);
    
  end
  
end