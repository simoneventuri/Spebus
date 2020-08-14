close all
clear all
clc

global Input Syst Param


Input.WORKSPACE_PATH = '/home/venturi/WORKSPACE/'
Input.SystNameLong   = 'CNH_UIUC';
Input.FigureFormat   = 'PrePrint';
Input.iFig           = 101;
Input.DATA_PATH      = '/Spebus/PESConstruction/AbInitio_Data/CNH/';%'/Spebus/PESConstruction/AbInitio_Data/O3/UMN_AbInitio/';
Input.RConv          = 1.0;
Input.EConv          = 1.0;
Input.EShift         = 0.0;%120.311d0

Syst.NameLong = Input.SystNameLong;
Syst          = Initialize_ChemicalSyst(Syst)
Initialize_Parameters()


% figure
iPES = 0;
for PES_NAME = Syst.PESName
    iPES = iPES + 1
    PES_NAME
    WriteDataFldr        = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES));
    [status, msg, msgID] = mkdir(WriteDataFldr)

    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%% READING in POTLIB FORMAT
%     filename   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, PES_NAME(:), '.dat')
%     delimiter  = ' ';
%     formatSpec = '%f%f%f%[^\n\r]';
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN, 'ReturnOnError', false);
%     fclose(fileID);
%     Col1 = dataArray{:, 1};
%     Col2 = dataArray{:, 2};
%     Col3 = dataArray{:, 3};
%     clearvars filename delimiter formatSpec fileID dataArray ans;
%     for i=1:5:length(Col1)
%         E(Col1(i),1) = (Col2(i) - Input.EShift) .* Param.KcmToeV;
%         E(Col1(i),2) = (Col3(i) - Input.EShift) .* Param.KcmToeV;
%     end
%     iPoint=1;
%     for i=3:5:length(Col1)
%         X2(iPoint,:) = [Col1(i), Col2(i)];
%         iPoint=iPoint+1;
%     end
%     iPoint=1;
%     for i=4:5:length(Col1)
%         X3(iPoint,:) = [Col1(i), Col2(i)];
%         iPoint=iPoint+1;
%     end
%     r1 = sqrt(X2(:,1).^2 + X2(:,2).^2);
%     r3 = sqrt(X3(:,1).^2 + X3(:,2).^2);
%     r2 = sqrt((X2(:,1) - X3(:,1)).^2 + (X2(:,2) - X3(:,2)).^2);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% READING in [R1,R2,R3,E] FORMAT
    opts = delimitedTextImportOptions("NumVariables", 4);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["r1", "r2", "r3", "E"];
    opts.VariableTypes = ["double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    filename = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/EOrig_Tot.dat')
    tbl      = readtable("/home/venturi/WORKSPACE/Spebus/PESConstruction/AbInitio_Data/CNH/PES_1/EOrig_Tot.csv", opts);
    r1Temp = tbl.r1;
    r2Temp = tbl.r2;
    r3Temp = tbl.r3;
    ETemp  = tbl.E;
    clear opts tbl
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% COMPUTING DIATOMIC AND TRIATOMIC CONTRIBUTION
    ii=0;
    jj=0;
    kk=0;
    r1 = [];
    r2 = [];
    r3 = [];
    E  = [];
    for i=1:size(ETemp,1)
        if     (r1Temp(i)+r2Temp(i) < r3Temp(i))
           ii=ii+1;
           %pause
        elseif (r1Temp(i)+r3Temp(i) < r2Temp(i))
           jj=jj+1;
           %pause
        elseif (r3Temp(i)+r2Temp(i) < r1Temp(i))
           kk=kk+1;
           %pause 
        else
           r1 = [r1; r1Temp(i)];
           r2 = [r2; r2Temp(i)];
           r3 = [r3; r3Temp(i)];
           E  = [E;   ETemp(i)];
        end
            
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% COMPUTING ANGLES
    R       = [r1, r2, r3] .* Input.RConv;
    RSorted = R; %sort(R,2);
    Ang3 = acos( (RSorted(:,1).^2 + RSorted(:,2).^2 - RSorted(:,3).^2) ./ (2.d0.*RSorted(:,1).*RSorted(:,2)) ) .* 180 ./ pi;
    Ang1 = acos( (RSorted(:,2).^2 + RSorted(:,3).^2 - RSorted(:,1).^2) ./ (2.d0.*RSorted(:,2).*RSorted(:,3)) ) .* 180 ./ pi;
    Ang2 = acos( (RSorted(:,1).^2 + RSorted(:,3).^2 - RSorted(:,2).^2) ./ (2.d0.*RSorted(:,1).*RSorted(:,3)) ) .* 180 ./ pi;
    ANG  = [Ang1, Ang2, Ang3];
    Grp  = ones(size(E,1),1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% COMPUTING DIATOMIC AND TRIATOMIC CONTRIBUTION
    for i=1:size(RSorted,1)
        EDiat(i)      = 0.0;
        for iP=1:3
            clear( Syst.Molecule(iP).DiatPot )   
            [Ve, dVv] = feval(Syst.Molecule(iP).DiatPot, RSorted(i,iP));
            EDiat(i)  = EDiat(i) + Ve;
        end
        ETriat(i) = E(i) - EDiat(i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% WRITING Rs and Es ALL TOGETHER IN ONE FILE
    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/REData.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,ETriat,EDiat,E\n')
    % figure(1)
    % iEq=0;
    for iPoints=1:size(ANG,1)
        %   if (R(iPoints,1) >= 10.0) && (R(iPoints,2) >= 10.0)
        %     plot(R(iPoints,3),E(iPoints),'ko')
        %   elseif (R(iPoints,1) >= 10.0) && (R(iPoints,3) >= 10.0)
        %     plot(R(iPoints,2),E1(iPoints),'ro')
        %   elseif (R(iPoints,3) >= 10.0) && (R(iPoints,2) >= 10.0)
        %     plot(R(iPoints,1),E(iPoints),'bo')
        %   end
        %   hold on

        %   for jPoints=1:size(ANG,1)
        %     if (R(iPoints,1) == R(jPoints,1)) && (R(iPoints,2) == R(jPoints,2)) && (R(iPoints,3) == R(jPoints,3)) && (iPoints ~= jPoints)
        %       R(iPoints,1)
        %       R(iPoints,2)
        %       R(iPoints,3)
        %       plot3(R(iPoints,1),R(iPoints,2),E(iPoints),'ko')
        %       iEq=iEq+1;
        %     end
        %   end
        %   hold on

        fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), ETriat(iPoints), EDiat(iPoints), E(iPoints));
        %fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,3), RSorted(iPoints,2), RSorted(iPoints,1), ETriat(iPoints), EDiat(iPoints), E(iPoints));
    end
    fclose(fileID);
    % iEq
    % pause
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% SPLITTING Rs and Es BASED ON ANGLES
    DeltaAngle = 0.1;
    AtMat = [1,3,2; 1,2,3; 2,1,3];
    PaMat = [2,1,3; 1,2,3; 1,3,2];
    for jP=1:3
        for iAng=[[0:5:180],[106.75:10:126.75]]
            File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_',num2str(iPES), '/REData_', Syst.Atom(AtMat(jP,1)).Name, Syst.Atom(AtMat(jP,2)).Name, Syst.Atom(AtMat(jP,3)).Name, '.csv.', num2str(floor(iAng)));
            fileID = fopen(File,'w');
            fprintf(fileID,'R1,R2,R3,ETriat,EDiat,E\n')

            for iPoints=1:size(ANG,1)
                if (ANG(iPoints,jP) >= iAng-DeltaAngle) && (ANG(iPoints,jP) <= iAng+DeltaAngle)
                    fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,PaMat(jP,1)), RSorted(iPoints,PaMat(jP,2)), RSorted(iPoints,PaMat(jP,3)), ETriat(iPoints), EDiat(iPoints), E(iPoints));
                    %fprintf(fileID,'%f,%f,%f,%f,%f,%f\n', RSorted(iPoints,3), RSorted(iPoints,1), RSorted(iPoints,2), ETriat(iPoints), EDiat(iPoints), E(iPoints));
                end
            end

            fclose(fileID);
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% WRITING Rs and Es SEPARATELY
    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/RSampled.csv.', num2str(iPES));
    fileID = fopen(File,'w');
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3));
    end
    fclose(fileID);
    
    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/R.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'# R1,R2,R3\n')
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3));
    end
    fclose(fileID);

    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/EOrig.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'# E\n')
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f\n', E(iPoints));
    end
    fclose(fileID);
    
    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/EDiatOrig.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'# EDiat\n')
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f\n', EDiat(iPoints));
    end
    fclose(fileID);

    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/ETriatOrig.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'# ETriat\n')
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f\n', ETriat(iPoints));
    end
    fclose(fileID);

    
    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/REOrig.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'# R1,R2,R3,E\n')
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), E(iPoints));
    end
    fclose(fileID);
    
    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/REDiat.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'# R1,R2,R3,EDiat\n')
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), EDiat(iPoints));
    end
    fclose(fileID);

    File   = strcat(Input.WORKSPACE_PATH, Input.DATA_PATH, '/PES_', num2str(iPES), '/RETriatOrig.csv');
    fileID = fopen(File,'w');
    fprintf(fileID,'# R1,R2,R3,ETriat\n')
    for iPoints=1:size(RSorted,1)
        fprintf(fileID,'%f,%f,%f,%f\n', RSorted(iPoints,1), RSorted(iPoints,2), RSorted(iPoints,3), ETriat(iPoints));
    end
    fclose(fileID);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PLOTTING POINTS
    figure(iPES)
    gplotmatrix(RSorted,[],Grp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    clear Col1 Col2 Col3 E ETriat ENew r1 r2 r3 X2 X3 R RSorted alpha Grp Ang1 Ang2 Ang3 ANG
end