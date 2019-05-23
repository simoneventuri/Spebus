function [RCut, ECut, EFittedCut, NPoitsVec, RCutPred] = ReadCutData(RData, EData, EFitted, NPtCut)

  global RFile alphaCutsVec RCutsVec AbscissaConverter Network_Folder DiatMin
  

  REData = [RData, EData, EFitted];
  NData  = size(EData,1);
  
  RCut       = zeros(size(alphaCutsVec,1),NPtCut,3);
  ECut       = zeros(size(alphaCutsVec,1),NPtCut,3);
  EFittedCut = zeros(size(alphaCutsVec,1),NPtCut,3);
  NPoitsVec  = zeros(size(alphaCutsVec,1),1);
  
  iCut = 1;
  for iAng = alphaCutsVec
    iAng
    RCutsVec(iCut)
    File    = strcat(Network_Folder,'/RECut.csv.',num2str(iCut));
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
      
      if     ((Ang1 <= iAng + DeltaMaxAng) && (Ang1 >= iAng - DeltaMaxAng))
        if (R2 <= RCutsVec(iCut) + DeltaMaxR) && (R2 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f,%f,%f\n', R3,R1,R2, E);
          iPoints              = iPoints+1;
          RCut(iCut,iPoints,:) = [R3,R1,R2];
          ECut(iCut,iPoints)   = E;
          EFittedCut(iCut,iPoints) = EFit;
        elseif (R3 <= RCutsVec(iCut) + DeltaMaxR) && (R3 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f,%f,%f\n', R2,R1,R3, E);
          iPoints              = iPoints+1;
          RCut(iCut,iPoints,:) = [R2,R1,R3];
          ECut(iCut,iPoints)   = E;
          EFittedCut(iCut,iPoints) = EFit;
        end
      elseif ((Ang2 <= iAng + DeltaMaxAng) && (Ang2 >= iAng - DeltaMaxAng))
        if (R1 <= RCutsVec(iCut) + DeltaMaxR) && (R1 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f,%f,%f\n', R3,R2,R1, E);
          iPoints              = iPoints+1;
          RCut(iCut,iPoints,:) = [R3,R2,R1];
          ECut(iCut,iPoints)   = E;
          EFittedCut(iCut,iPoints) = EFit;
        elseif (R3 <= RCutsVec(iCut) + DeltaMaxR) && (R3 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f,%f,%f\n', R1,R2,R3, E);
          iPoints              = iPoints+1;
          RCut(iCut,iPoints,:) = [R1,R2,R3];
          ECut(iCut,iPoints)   = E;
          EFittedCut(iCut,iPoints) = EFit;
        end
      elseif ((Ang3 <= iAng + DeltaMaxAng) && (Ang3 >= iAng - DeltaMaxAng))
        if (R2 <= RCutsVec(iCut) + DeltaMaxR) && (R2 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f,%f,%f\n', R1,R3,R2, E);
          iPoints              = iPoints+1;
          RCut(iCut,iPoints,:) = [R1,R3,R2];
          ECut(iCut,iPoints)   = E;
          EFittedCut(iCut,iPoints) = EFit;
        elseif (R1 <= RCutsVec(iCut) + DeltaMaxR) && (R1 >= RCutsVec(iCut) - DeltaMaxR)
          fprintf(fileID,'%f,%f,%f,%f\n', R2,R3,R1, E);
          iPoints              = iPoints+1;
          RCut(iCut,iPoints,:) = [R2,R3,R1];
          ECut(iCut,iPoints)   = E;
          EFittedCut(iCut,iPoints) = EFit;
        end
      end
    end
    
    fclose(fileID);
    NPoitsVec(iCut)             = iPoints;
    RCutPred(iCut,1:NPtCut,1)   = linspace(1.5,10.0,NPtCut);
    RCutPred(iCut,1:NPtCut,3)   = RCutsVec(iCut);
    RCutPred(iCut,1:NPtCut,2)   = sqrt( RCutPred(iCut,1:NPtCut,1).^2 + RCutPred(iCut,1:NPtCut,3).^2 - 2.d0.*RCutPred(iCut,1:NPtCut,1).*RCutPred(iCut,1:NPtCut,3).*cos(iAng./180.0.*pi) );
    iCut                        = iCut+1;
  end  
  
end