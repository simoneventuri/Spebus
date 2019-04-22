function [iFigure] = Plotscatter(iFigure, R, EData, EDiatData, EFitted, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3)
  
  global OnlyTriatFlg RMin EGroupsVec Network_Folder System ShiftScatter AbscissaConverter
  
  RMinVec      = [RMin, 50.0, 50.0];
  [PredShift]  = ComputeOutput(RMinVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, 0.0);
  
  [EPred]      = ComputeOutput(R,       Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, 0.0) - PredShift;
  
  if strcmp(System,'N3')
    [FittedShift, dE1] = N2_LeRoy(RMin);
    %[FittedShift, dE1] = N2_MRCI(2.088828)
    [PRedShift, dE1]   = N2_LeRoy(RMin);
  elseif strcmp(System,'O3')
    [FittedShift, dE1] = O2_UMN(RMin);
    [PRedShift, dE1]   = O2_UMN(RMin);
  end
  

  if (OnlyTriatFlg)
    EData   = EData   + EDiatData;
    EFitted = EFitted + EDiatData - FittedShift;
  else
    EData   = EData + PRedShift;
  end
  
  % EAllFitted = ETriatFitted + EDiat;
  % EAllPred   = ETriatPred   + EDiat + PredShift;
  % EAllData   = ETriatData   + EDiat;
  % EAllFitted = ETriatFitted + EDiat;
  % EAllPred   = ETriatPred   + EDiat;
  % EAllData   = ETriatData   + EDiat + FittedShift;

  figure(iFigure);
  scatter(EData,EFitted,'g','filled');
  hold on
  scatter(EData,EPred,'b','filled');
  plot([0, 30.0],[0, 30.0],'-');
  iFigure = iFigure + 1;
 
  
  UME_Data_Vec  = abs(EFitted-EData);
  UME_Pred_Vec  = abs(EPred-EData);
  UME_Data      = mean(UME_Data_Vec);
  UME_Pred      = mean(UME_Pred_Vec);
  figure(iFigure);
  scatter(EData,UME_Data_Vec,'g','filled');
  hold on
  scatter(EData,UME_Pred_Vec,'b','filled');
  iFigure = iFigure + 1;
    
  RMSE_Data_Vec = (EFitted-EData).^2;
  RMSE_Pred_Vec = (EPred-EData).^2;
  RMSE_Data     = sqrt(mean(RMSE_Data_Vec));
  RMSE_Pred     = sqrt(mean(RMSE_Pred_Vec));
  figure(iFigure);
  scatter(EData,RMSE_Data_Vec,'g','filled');
  hold on
  scatter(EData,RMSE_Pred_Vec,'b','filled');
  iFigure = iFigure + 1;
  
  RMSE_Data_Group = zeros(size(EGroupsVec,2),1);
  RMSE_Pred_Group = zeros(size(EGroupsVec,2),1);
  UME_Data_Group  = zeros(size(EGroupsVec,2),1);
  UME_Pred_Group  = zeros(size(EGroupsVec,2),1);
  Point_in_Group  = zeros(size(EGroupsVec,2),1);
  
  for i=1:size(EData,1)
    Idx=1;
    while EData(i) >= EGroupsVec(Idx) - ShiftScatter
      Idx=Idx+1;
    end
    GroupIdx(i) = Idx;
    
    Point_in_Group(GroupIdx(i))  = Point_in_Group(GroupIdx(i))  + 1;
    RMSE_Data_Group(GroupIdx(i)) = RMSE_Data_Group(GroupIdx(i)) + RMSE_Data_Vec(i);
    RMSE_Pred_Group(GroupIdx(i)) = RMSE_Pred_Group(GroupIdx(i)) + RMSE_Pred_Vec(i);
    UME_Data_Group(GroupIdx(i))  = UME_Data_Group(GroupIdx(i))  + UME_Data_Vec(i);
    UME_Pred_Group(GroupIdx(i))  = UME_Pred_Group(GroupIdx(i))  + UME_Pred_Vec(i);
  end
  
  RMSE_Data_Group = sqrt(RMSE_Data_Group ./ Point_in_Group);
  RMSE_Pred_Group = sqrt(RMSE_Pred_Group ./ Point_in_Group);
  UME_Data_Group  =      UME_Data_Group  ./ Point_in_Group;
  UME_Pred_Group  =      UME_Pred_Group  ./ Point_in_Group;
  
  filename = strcat(Network_Folder,'/Errors.csv');
  fileID = fopen(filename,'w');
  fprintf(fileID,'# Group, En Interval, NPoints,     Orig UME,       NN UME,    Orig RMSE,      NN RMSE\n');
  for iGroup=1:size(EGroupsVec,2)
    fprintf(fileID,'%7i,%12f,%8i,%13f,%13f,%13f,%13f\n', iGroup, EGroupsVec(iGroup), Point_in_Group(iGroup), UME_Data_Group(iGroup), UME_Pred_Group(iGroup), RMSE_Data_Group(iGroup), RMSE_Pred_Group(iGroup) );
  end
  fclose(fileID);
    
  
  figure(iFigure);
  ErrMat=[UME_Data_Group,UME_Pred_Group];
  bar(ErrMat)
  iFigure = iFigure + 1;
  
  figure(iFigure);
  ErrMat=[RMSE_Data_Group,RMSE_Pred_Group];
  bar(ErrMat)
  iFigure = iFigure + 1;
  
end