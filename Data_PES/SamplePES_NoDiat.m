close all
clear all
clc

RIn    = 1.5d0;
REnd   = 10.d0;
RStart = 5.d0 * ones(1,3);

AngleMu = 120.d0;
AngleSD = 20.0;

NTot  = 250000;
NJump = 50;
NBurn = 50000;


ROld     = RStart;
RVec     = [];
iAcc = 0;
for iR = 1:NTot
  RProp     = normrnd(ROld,2.0);
  if sum((RProp < RIn) > 0) || sum((RProp > REnd) > 0)
    alpha = 0.0d0;
  else
    RROld  = sqrt(sum(ROld.^2));
    VOld   = 1./(RROld-RIn);
    RRProp = sqrt(sum(RProp.^2));
    VProp  = 1./(RRProp-RIn);
    alpha  = abs(VProp) ./ abs(VOld);
  end
  if (alpha > rand)
    ROld     = RProp;
    iAcc     = iAcc + 1;
  end
  RVec     = [RVec;         ROld];
end 
PercAcc = iAcc / NTot
RVecClean     = RVec(NBurn:NJump:end,:);
NClean        = size(RVecClean,1)
figure
histogram(RVecClean(:,1),min(floor(NClean/2),100))
hold on
histogram(RVecClean(:,2),min(floor(NClean/2),100))
histogram(RVecClean(:,3),min(floor(NClean/2),100))
figure
plot(RVecClean)



RFinal = [RVecClean];%, RAdd];
NTot   = size(RFinal,1)

% R         = linspace(RIn, REnd, 100);
% [V, dV]   = LeRoy(R);
% V         = V;
% dV        = dV;
% [Vd, dVd] = LeRoy(RdVecClean(:)');
% [Vr, dVr] = LeRoy(RVecClean(:)');
% figure
% plot(R,V.* 27.2114,'g')
% hold on
% plot(R,dV.* 27.2114,'b')
% plot(RVecClean(:),Vr(:).* 27.2114,'go')
% plot(RVecClean(:),dVr(:).* 27.2114,'ro')
% %plot(RAdd,VAdd.* 27.2114,'ro')
% plot(RdVecClean(:),dVd(:).* 27.2114,'bo')
% plot(RdVecClean(:),Vd(:).* 27.2114,'ro')
% %plot(RAdd,dVAdd.* 27.2114,'ro')



NameStr = strcat('./RSampled.csv');
csvwrite(NameStr,[RFinal(:,1),RFinal(:,2),RFinal(:,3)])