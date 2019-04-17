close all
clear all
clc

RIn    = 1.45d0;
REnd   = 15.d0;
RStart = 5.d0 * ones(1,3);

AngleMu = 120.d0;
AngleSD = 20.0;

NTot  = 180000;
NJump = 50;
NBurn = 10000;


ROld     = RStart;
AngleOld = acos( (ROld(1)^2 + ROld(3)^2 - ROld(2)^2) / (2.0*ROld(1)*ROld(3)) ) / pi * 180.0;
RVec     = [];
AngleVec = [];
iAcc = 0;
for iR = 1:NTot
  RProp     = normrnd(ROld([1,3]),1.0);
  AngleProp = normrnd(AngleMu,AngleSD);
  R2Prop    = sqrt(RProp(1)^2 + RProp(2)^2 - 2.0*RProp(1)*RProp(2)*cos(AngleProp/180.0*pi));
  RProp     = [RProp(1), R2Prop, RProp(2)];
  if sum((RProp < RIn) > 0) || sum((RProp > REnd) > 0)
    alpha = 0.0d0;
  else
    [VProp, dVProp] = LeRoy(RProp);
    VTProp  = sum(abs(VProp));
    dVTProp = sum(abs(dVProp));
    [VOld,  dVOld]  = LeRoy(ROld);
    VTOld  = sum(abs(VOld));
    dVTOld = sum(abs(dVOld));
    alpha  = abs(VTProp) ./ abs(VTOld);
  end
  if (alpha > rand)
    ROld     = RProp;
    AngleOld = AngleProp;
    iAcc     = iAcc + 1;
  end
  RVec     = [RVec;         ROld];
  AngleVec = [AngleVec; AngleOld];
end 
PercAcc = iAcc / NTot
RVecClean     = RVec(NBurn:NJump:end,:);
AngleVecClean = AngleVec(NBurn:NJump:end,:);
NClean        = size(RVecClean,1)
figure
histogram(RVecClean(:,1),min(floor(NClean/2),100))
hold on
histogram(RVecClean(:,2),min(floor(NClean/2),100))
histogram(RVecClean(:,3),min(floor(NClean/2),100))
figure
histogram(AngleVecClean,min(floor(NClean/2),100))
figure
plot(RVecClean)
figure
plot(AngleVecClean)



RIn    = 1.45d0;
REnd   = 15.d0;
RStart = 5.d0 * ones(1,3);

AngleMu = 120.d0;
AngleSD = 20.0;

NTot  = 60000;
NJump = 50;
NBurn = 10000;


ROld     = RStart;
AngleOld = acos( (ROld(1)^2 + ROld(3)^2 - ROld(2)^2) / (2.0*ROld(1)*ROld(3)) ) / pi * 180.0;
RdVec    = [];
AngleVec = [];
iAcc = 0;
for iR = 1:NTot
  RProp     = normrnd(ROld([1,3]),1.0);
  AngleProp = normrnd(AngleMu,AngleSD);
  R2Prop    = sqrt(RProp(1)^2 + RProp(2)^2 - 2.0*RProp(1)*RProp(2)*cos(AngleProp/180.0*pi));
  RProp     = [RProp(1), R2Prop, RProp(2)];
  if sum((RProp < RIn) > 0) || sum((RProp > REnd) > 0)
    alpha = 0.0d0;
  else
    [VProp, dVProp] = LeRoy(RProp);
    VTProp  = sum(abs(VProp));
    dVTProp = sum(abs(dVProp));
    [VOld,  dVOld]  = LeRoy(ROld);
    VTOld  = sum(abs(VOld));
    dVTOld = sum(abs(dVOld));
    alpha  = abs(dVTProp) ./ abs(dVTOld);
  end
  if (alpha > rand)
    ROld     = RProp;
    AngleOld = AngleProp;
    iAcc     = iAcc + 1;
  end
  RdVec    = [RdVec;        ROld];
  AngleVec = [AngleVec; AngleOld];
end 
PercAcc = iAcc / NTot
RdVecClean    = RdVec(NBurn:NJump:end,:);
AngleVecClean = AngleVec(NBurn:NJump:end,:);
NdClean       = size(RdVecClean,1)
figure
histogram(RdVecClean(:,1),min(floor(NdClean/2),100))
hold on
histogram(RdVecClean(:,2),min(floor(NdClean/2),100))
histogram(RdVecClean(:,3),min(floor(NdClean/2),100))
figure
histogram(AngleVecClean,min(floor(NClean/2),100))
figure
plot(RdVecClean)
figure
plot(AngleVecClean)



%RAdd          = [RIn:0.2:2];
%RAdd          = [RAdd, [5:2:REnd]];
%[VAdd, dVAdd] = LeRoy(RAdd);



RFinal = [RVecClean; RdVecClean];%, RAdd];
NTot   = size(RFinal,1)

R         = linspace(RIn, REnd, 100);
[V, dV]   = LeRoy(R);
V         = V;
dV        = dV;
[Vd, dVd] = LeRoy(RdVecClean(:)');
[Vr, dVr] = LeRoy(RVecClean(:)');
figure
plot(R,V.* 27.2114,'g')
hold on
plot(R,dV.* 27.2114,'b')
plot(RVecClean(:),Vr(:).* 27.2114,'go')
plot(RVecClean(:),dVr(:).* 27.2114,'ro')
%plot(RAdd,VAdd.* 27.2114,'ro')
plot(RdVecClean(:),dVd(:).* 27.2114,'bo')
plot(RdVecClean(:),Vd(:).* 27.2114,'ro')
%plot(RAdd,dVAdd.* 27.2114,'ro')



NameStr = strcat('./RSampled.csv');
csvwrite(NameStr,[RFinal(:,1),RFinal(:,2),RFinal(:,3)])