function [RCut, ECut, EFittedCut, RCutPred, AngleVec, AngFake] = ReadCutDataAngle(RData, EData, EFitted, NPtCut)

  global RFile RCutsVecAngle AbscissaConverter Network_Folder DiatMin
  

  REData = [RData, EData, EFitted];
  NData  = size(EData,1);
    
  RCut       = [];
  ECut       = [];
  EFittedCut = [];
  
  hAng = (175.d0 - 35.d0) / (NPtCut-1);
  
  
  Ang1 = 35.d0;
  RCutPred=[];
  File    = strcat(Network_Folder,'/RECutAngleFake.csv');
  fileID  = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3\n');
  for i=1:NPtCut
    R2   = RCutsVecAngle(1);
    R3   = RCutsVecAngle(2);
    R1   = sqrt( R2.^2 + R3.^2 - 2.d0.*R2.*R3.*cos(Ang1./180.*pi) );
    RCutPred(i,1:3) = [R1,R2,R3];
    Ang1 = Ang1 + hAng;
    fprintf(fileID,'%f,%f,%f\n', R3,R1,R2);
    AngFake(i) = Ang1;
  end
  fclose(fileID);

  
  
  File    = strcat(Network_Folder,'/RECutAngle.csv');
  fileID  = fopen(File,'w');
  fprintf(fileID,'R1,R2,R3,E\n');
  iPoints = 0;
    
  for iData=1:NData
    R1   = (REData(iData,1));
    R2   = (REData(iData,2));
    R3   = (REData(iData,3));
    E    = (REData(iData,4));
    EFit = (REData(iData,5));
    Ang3 = acos( (R1.^2 + R2.^2 - R3.^2) ./ (2.d0.*R1.*R2) ) .* 180 ./ pi;
    Ang1 = acos( (R2.^2 + R3.^2 - R1.^2) ./ (2.d0.*R2.*R3) ) .* 180 ./ pi;
    Ang2 = acos( (R3.^2 + R1.^2 - R2.^2) ./ (2.d0.*R1.*R3) ) .* 180 ./ pi;

    DeltaMaxAng = 0.05;
    DeltaMaxR   = 0.001;

    if ( (abs(R1 - RCutsVecAngle(1)) < DeltaMaxR) && (abs(R2 - RCutsVecAngle(2)) < DeltaMaxR) )
      fprintf(fileID,'%f,%f,%f,%f\n', R3,R1,R2, E);
      iPoints             = iPoints+1;
      RCut(iPoints,:)     = [R3,R1,R2];
      ECut(iPoints)       = E;
      EFittedCut(iPoints) = EFit;
      AngleVec(iPoints)   = Ang3;
    elseif ( (abs(R2 - RCutsVecAngle(1)) < DeltaMaxR) && (abs(R1 - RCutsVecAngle(2)) < DeltaMaxR) )
      fprintf(fileID,'%f,%f,%f,%f\n', R3,R2,R1, E);
      iPoints             = iPoints+1;
      RCut(iPoints,:)     = [R3,R2,R1];
      ECut(iPoints)       = E;
      EFittedCut(iPoints) = EFit;
      AngleVec(iPoints)   = Ang3;
    elseif ( (abs(R1 - RCutsVecAngle(1)) < DeltaMaxR) && (abs(R3 - RCutsVecAngle(2)) < DeltaMaxR) )
      fprintf(fileID,'%f,%f,%f,%f\n', R2,R1,R3, E);
      iPoints             = iPoints+1;
      RCut(iPoints,:)     = [R2,R1,R3];
      ECut(iPoints)       = E;
      EFittedCut(iPoints) = EFit;
      AngleVec(iPoints)   = Ang2;
    elseif ( (abs(R3 - RCutsVecAngle(1)) < DeltaMaxR) && (abs(R1 - RCutsVecAngle(2)) < DeltaMaxR) )
      fprintf(fileID,'%f,%f,%f,%f\n', R2,R3,R1, E);
      iPoints             = iPoints+1;
      RCut(iPoints,:)     = [R2,R3,R1];
      ECut(iPoints)       = E;
      EFittedCut(iPoints) = EFit;
      AngleVec(iPoints)   = Ang2;
    elseif ( (abs(R2 - RCutsVecAngle(1)) < DeltaMaxR) && (abs(R3 - RCutsVecAngle(2)) < DeltaMaxR) ) 
      fprintf(fileID,'%f,%f,%f,%f\n', R1,R3,R2, E);
      iPoints             = iPoints+1;
      RCut(iPoints,:)     = [R1,R3,R2];
      ECut(iPoints)       = E;
      EFittedCut(iPoints) = EFit;
      AngleVec(iPoints)   = Ang1;
    elseif ( (abs(R3 - RCutsVecAngle(1)) < DeltaMaxR) && (abs(R2 - RCutsVecAngle(2)) < DeltaMaxR) ) 
      fprintf(fileID,'%f,%f,%f,%f\n', R1,R2,R3, E);
      iPoints             = iPoints+1;
      RCut(iPoints,:)     = [R1,R2,R3];
      ECut(iPoints)       = E;
      EFittedCut(iPoints) = EFit;
      AngleVec(iPoints)   = Ang1;
    end
  end
  
  fclose(fileID);


end  
