function [G] = ComputePIP(p1, p2, p3, G_MEAN, G_SD)

  global PIPFun
  
  if strcmp(BondOrderFun,'Simone')
  
    GVec1 = [p1.*p2; p2.*p3; p1.*p3];
    GVec2 = [GVec1(1,:).*p1; GVec1(1,:).*p2; GVec1(2,:).*p2; GVec1(2,:).*p3; GVec1(3,:).*p1; GVec1(3,:).*p3];

    G(:,1)   = sum(GVec1,1);
    G(:,2)   = (p1.*p2.*p3);
    G(:,3)   = sum(GVec2,1);

    G(:,4)   = GVec2(1,:).*p1 + GVec2(2,:).*p2 + GVec2(3,:).*p2 + GVec2(4,:).*p3 + GVec2(5,:).*p1 + GVec2(6,:).*p3;
    G(:,5)   = GVec2(1,:).*p3 + GVec2(3,:).*p1 + GVec2(6,:).*p2;
    G(:,6)   = GVec2(1,:).*p2 + GVec2(3,:).*p3 + GVec2(5,:).*p3;
    
  elseif strcmp(BondOrderFun,'Alberto')
    
    
  end

end