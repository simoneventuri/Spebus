function [EDiat] = ComputeDiat(R)

  global System AbscissaConverter

  if strcmp(System,'N3')
    [E1, dE1] = N2_LeRoy(R(:,1)./AbscissaConverter);
    [E2, dE2] = N2_LeRoy(R(:,2)./AbscissaConverter);
    [E3, dE3] = N2_LeRoy(R(:,3)./AbscissaConverter);
    E1 = E1';
    E2 = E2';
    E3 = E3';
  elseif strcmp(System,'O3')
    [E1, dE1] = O2_UMN(R(:,1)./AbscissaConverter);
    [E2, dE2] = O2_UMN(R(:,2)./AbscissaConverter);
    [E3, dE3] = O2_UMN(R(:,3)./AbscissaConverter);
  end
  EDiat = E1 + E2 + E3;
  
end