%% The Function Loads Unlabeled Data for 2D Cuts
%
function Read_CutData(NPtCut)

    %%==============================================================================================================
    % 
    % Spebus, Machine Learning Toolbox for constructing Deterministic and Stochastic Potential Energy Surfaces 
    % 
    % Copyright (C) 2018 Simone Venturi (University of Illinois at Urbana-Champaign). 
    % 
    % This program is free software; you can redistribute it and/or modify it under the terms of the 
    % Version 2.1 GNU Lesser General Public License as published by the Free Software Foundation. 
    % 
    % This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    % without e=ven the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    % See the GNU Lesser General Public License for more details. 
    % 
    % You should have received a copy of the GNU Lesser General Public License along with this library; 
    % if not, write to the Free Software Foundation, Inc. 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA 
    % 
    %---------------------------------------------------------------------------------------------------------------
    %%==============================================================================================================

    global Param Input Data Fit Cut
 
    fprintf('  = Read_CutData (2D Cuts) ===========================\n')
    fprintf('  ====================================================\n')

    fprintf(['  Input.ParamsFldr = ', Input.ParamsFldr, '\n'])
    

    REData = [Data.R, Data.E, Data.EFit];

    Cut.R     = zeros(Input.Cuts.NCuts,NPtCut,3);
    Cut.E     = zeros(Input.Cuts.NCuts,NPtCut,3);
    Cut.EFit  = zeros(Input.Cuts.NCuts,NPtCut,3);
    Cut.NData = zeros(Input.Cuts.NCuts,1);

    iCut = 1;
    for iAng = Input.Cuts.AngVec
        fprintf('  Angle = %fdeg; R =%fa0 \n', iAng, Input.Cuts.rVec(iCut))
        
        File    = strcat( Input.ParamsFldr,'/RECut.csv.',num2str(iCut));
        fileID  = fopen(File,'w');
        fprintf(fileID,'R1,R2,R3,E\n');
        iPoints = 0;

        for iData=1:Data.N
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
            if (R2 <= Input.Cuts.rVec(iCut) + DeltaMaxR) && (R2 >= Input.Cuts.rVec(iCut) - DeltaMaxR)
              fprintf(fileID,'%f,%f,%f,%f\n', R3,R1,R2, E);
              iPoints                = iPoints+1;
              Cut.R(iCut,iPoints,:)  = [R3,R1,R2];
              Cut.E(iCut,iPoints)    = E;
              Cut.EFit(iCut,iPoints) = EFit;
            elseif (R3 <= Input.Cuts.rVec(iCut) + DeltaMaxR) && (R3 >= Input.Cuts.rVec(iCut) - DeltaMaxR)
              fprintf(fileID,'%f,%f,%f,%f\n', R2,R1,R3, E);
              iPoints                = iPoints+1;
              Cut.R(iCut,iPoints,:)  = [R2,R1,R3];
              Cut.E(iCut,iPoints)    = E;
              Cut.EFit(iCut,iPoints) = EFit;
            end
          elseif ((Ang2 <= iAng + DeltaMaxAng) && (Ang2 >= iAng - DeltaMaxAng))
            if (R1 <= Input.Cuts.rVec(iCut) + DeltaMaxR) && (R1 >= Input.Cuts.rVec(iCut) - DeltaMaxR)
              fprintf(fileID,'%f,%f,%f,%f\n', R3,R2,R1, E);
              iPoints                = iPoints+1;
              Cut.R(iCut,iPoints,:)  = [R3,R2,R1];
              Cut.E(iCut,iPoints)    = E;
              Cut.EFit(iCut,iPoints) = EFit;
            elseif (R3 <= Input.Cuts.rVec(iCut) + DeltaMaxR) && (R3 >= Input.Cuts.rVec(iCut) - DeltaMaxR)
              fprintf(fileID,'%f,%f,%f,%f\n', R1,R2,R3, E);
              iPoints                = iPoints+1;
              Cut.R(iCut,iPoints,:)  = [R1,R2,R3];
              Cut.E(iCut,iPoints)    = E;
              Cut.EFit(iCut,iPoints) = EFit;
            end
          elseif ((Ang3 <= iAng + DeltaMaxAng) && (Ang3 >= iAng - DeltaMaxAng))
            if (R2 <= Input.Cuts.rVec(iCut) + DeltaMaxR) && (R2 >= Input.Cuts.rVec(iCut) - DeltaMaxR)
              fprintf(fileID,'%f,%f,%f,%f\n', R1,R3,R2, E);
              iPoints                = iPoints+1;
              Cut.R(iCut,iPoints,:)  = [R1,R3,R2];
              Cut.E(iCut,iPoints)    = E;
              Cut.EFit(iCut,iPoints) = EFit;
            elseif (R1 <= Input.Cuts.rVec(iCut) + DeltaMaxR) && (R1 >= Input.Cuts.rVec(iCut) - DeltaMaxR)
              fprintf(fileID,'%f,%f,%f,%f\n', R2,R3,R1, E);
              iPoints                = iPoints+1;
              Cut.R(iCut,iPoints,:)  = [R2,R3,R1];
              Cut.E(iCut,iPoints)    = E;
              Cut.EFit(iCut,iPoints) = EFit;
            end
          end
        end

        fclose(fileID);
        Cut.Data(iCut)             = iPoints;
        Cut.RPred(iCut,1:NPtCut,1) = linspace(1.5,10.0,NPtCut);
        Cut.RPred(iCut,1:NPtCut,3) = Input.Cuts.rVec(iCut);
        Cut.RPred(iCut,1:NPtCut,2) = sqrt( Cut.RPred(iCut,1:NPtCut,1).^2 + Cut.RPred(iCut,1:NPtCut,3).^2 - 2.d0.*Cut.RPred(iCut,1:NPtCut,1).*Cut.RPred(iCut,1:NPtCut,3).*cos(iAng./180.0.*pi) );
        iCut                       = iCut+1;
    end
    
    fprintf('  ====================================================\n\n')

end