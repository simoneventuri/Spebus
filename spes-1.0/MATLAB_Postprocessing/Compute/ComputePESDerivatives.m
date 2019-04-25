function ComputePESDerivatives(AngVec, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma)

  global Network_Folder

  Coeff    = [1/280, -4/105, 1/5, -4/5, 0, 4/5, -1/5, 4/105, -1/280];
  eV_To_Eh = 27.2113839712790;
  
  NPoints1 = 150;
  NPoints3 = 150;
  R10      = 1.5;
  R30      = 1.5;
  R1End    = 5.0;
  R3End    = 5.0;
  h1       = (R1End-R10)./NPoints1;
  h3       = (R3End-R30)./NPoints3;
  h2       = (h1+h3)/2;
  
  iAng = 1;
  for Ang = AngVec
    E   = zeros(NPoints1,NPoints3);
    dE1 = zeros(NPoints1,NPoints3);
    dE2 = zeros(NPoints1,NPoints3);
    dE3 = zeros(NPoints1,NPoints3);
    
    File = strcat(Network_Folder, '/DerivativesTest.csv.',num2str(floor(Ang)))
    fileID   = fopen(File,'w');
    fprintf(fileID,'R1,R2,R3,E,dEdR1,dEdR2,dEdR3\n');
    
    R1 = R10 - h1;
    for i1 = 1:NPoints1
      R1 = R1  + h1;
      R3 = R30 - h3;
      for i3 = 1:NPoints3
        R3 = R3 + h3;
        R2 = sqrt( R1.^2 + R3.^2 - 2.d0.*R1.*R3.*cos(Ang./180.0.*pi) );
        R  = [R1, R2, R3];
        
        E(i1,i3)   =  ComputeOutput(R, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);

        RTemp      = repmat(R,9,1);
        RTemp(:,1) = R1 + h1 .* [-4,-3,-2,-1,0,1,2,3,4]';
        ETemp      = ComputeOutput(RTemp, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
        dE1(i1,i3) = sum(Coeff .* ETemp') ./ h1;
        
        RTemp      = repmat(R,9,1);
        RTemp(:,2) = R2 + h2 .* [-4,-3,-2,-1,0,1,2,3,4]';
        ETemp      = ComputeOutput(RTemp, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
        dE2(i1,i3) = sum(Coeff .* ETemp') ./ h2;
        
        RTemp      = repmat(R,9,1);
        RTemp(:,3) = R3 + h3 .* [-4,-3,-2,-1,0,1,2,3,4]';
        ETemp      = ComputeOutput(RTemp, Lambda, re, G_MEAN, G_SD, W1, W2, W3, b1, b2, b3, Sigma);
        dE3(i1,i3) = sum(Coeff .* ETemp') ./ h3;
        
        fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f\n', R1,R2,R3,E(i1,i3),dE1(i1,i3),dE2(i1,i3),dE3(i1,i3));
      end
    end
   
    fclose(fileID);
    
    iAng = iAng+1;
  end
  
end