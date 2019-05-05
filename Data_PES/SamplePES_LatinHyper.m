close all
clear all
clc

rIn      = 1.5d0
rEnd     = 6.d0
rSamples = 23
rPoints  = floor(rSamples)
rh       = (rEnd-rIn)/(rPoints-1)
rPPoints = [rIn:rh:rEnd];

yIn      = 1.5d0
yEnd     = 15.d0
ySamples = 22
yPoints  = ySamples
yh       = (yEnd-yIn)/(yPoints-1)
yPPoints = [yIn:yh:yEnd];

alphaIn      = 0.d0
alphaEnd     = 90.d0
alphaSamples = 10
alphaPoints  = floor(alphaSamples)
alphah       = (alphaEnd-alphaIn)/(alphaPoints-1)
alphaPPoints = [alphaIn:alphah:alphaEnd];


ii = 1;
R  = [];
for ir=1:rSamples
  for iy=1:ySamples
    for ialpha=1:alphaSamples
      R(ii,1) = rPPoints(ir);
      R(ii,2) = sqrt( (R(ii,1)./2.d0).^2 + yPPoints(iy).^2 + R(ii,1).*yPPoints(iy).*sin(alphaPPoints(ialpha)./180.d0*pi) );
      R(ii,3) = sqrt( (R(ii,1)./2.d0).^2 + yPPoints(iy).^2 - R(ii,1).*yPPoints(iy).*sin(alphaPPoints(ialpha)./180.d0*pi) );
      ii = ii + 1;
    end
  end 
end
size(R)
figure
scatter3(R(:,1),R(:,2),R(:,3))
hold on
scatter3(R(:,1),R(:,3),R(:,2))
scatter3(R(:,2),R(:,1),R(:,3))
scatter3(R(:,2),R(:,3),R(:,1))
scatter3(R(:,3),R(:,1),R(:,2))
scatter3(R(:,3),R(:,2),R(:,1))


NameStr = strcat('./RSampled.csv');
csvwrite(NameStr,[R(:,1),R(:,2),R(:,3)])



RFinal      = [];
AngleFinal  = 120;
RDaje       = [];
ii = 1;
for i=1:NPoints
  for j=1:NPoints
    RFinal = sqrt(Points(i)^2 + Points(j)^2 - 2.0*Points(i)*Points(j)*cos(120.0/180.0*pi));
    %if (RFinal(i,1).^2 < RFinal(i,2).^2 + RFinal(i,3).^2) && (RFinal(i,2).^2 < RFinal(i,1).^2 + RFinal(i,3).^2) && (RFinal(i,3).^2 < RFinal(i,1).^2 + RFinal(i,2).^2)
      RDaje = [RDaje; [Points(i), RFinal, Points(j)]];
    %end
    ii = ii + 1;
  end
end
size(RDaje)

NameStr = strcat('./RSampled.csv');
csvwrite(NameStr,[RDaje(:,1),RDaje(:,2),RDaje(:,3)])



RIn      = 1.55d0
REnd     = [10.d0, 10.d0, 10.d0]
NPoints  = 17;

% h = (REnd-RIn)/(NPoints-1);
% 
% NameStr = strcat('./RSampled.csv');
% ii = 1
% for i=1:NPoints
%   for j=1:i
%     for k=1:j
%       R(ii,1) = RIn + (i-1)*h;
%       R(ii,2) = RIn + (j-1)*h;
%       R(ii,3) = RIn + (k-1)*h;
%       ii      = ii+1;
%       csvwrite(NameStr,[R(:,1),R(:,2),R(:,3)])
%     end
%   end
% end
% size(R,1)
% figure
% scatter3(R(:,1),R(:,2),R(:,3))


NSamples   = 10000;
RIn        = 1.5d0;
REnd       = 10.d0;
Samples    = lhsdesign(NSamples,3);
RFinal     = Samples      .* (REnd-RIn)   + RIn;
AngleFinal = Samples(:,2) .* (180.0-35.0) + 35.0;
RDaje  = [];
for i=1:NSamples
  RFinal(i,2) = sqrt(RFinal(i,1)^2 + RFinal(i,3)^2 - 2.0*RFinal(i,1)*RFinal(i,3)*cos(AngleFinal(i)/180.0*pi));
  %if (RFinal(i,1).^2 < RFinal(i,2).^2 + RFinal(i,3).^2) && (RFinal(i,2).^2 < RFinal(i,1).^2 + RFinal(i,3).^2) && (RFinal(i,3).^2 < RFinal(i,1).^2 + RFinal(i,2).^2)
    RDaje = [RDaje; RFinal(i,:)];
  %end
end
size(RDaje)
R = RDaje;
figure
scatter3(R(:,1),R(:,2),R(:,3))
hold on
scatter3(R(:,1),R(:,3),R(:,2))
scatter3(R(:,2),R(:,1),R(:,3))
scatter3(R(:,2),R(:,3),R(:,1))
scatter3(R(:,3),R(:,1),R(:,2))
scatter3(R(:,3),R(:,2),R(:,1))

figure(1)
Grp  = ones(size(R,1),1);
gplotmatrix(R,[],Grp)

NameStr = strcat('./RSampled.csv');
csvwrite(NameStr,[RDaje(:,1),RDaje(:,2),RDaje(:,3)])


NSamples = 7000

Samples    = lhsdesign(NSamples,3);
RFinal     = Samples      .* (REnd-RIn)   + RIn;
RDaje  = [];
for i=1:NSamples
  %RFinal(i,2) = sqrt(RFinal(i,1)^2 + RFinal(i,3)^2 - 2.0*RFinal(i,1)*RFinal(i,3)*cos(AngleFinal(i)/180.0*pi));
  if (RFinal(i,1) < RFinal(i,2) + RFinal(i,3)) && (RFinal(i,2) < RFinal(i,1) + RFinal(i,3)) && (RFinal(i,3) < RFinal(i,1) + RFinal(i,2))
    RDaje = [RDaje; RFinal(i,:)];
  end
end
size(RDaje)
R = RDaje;
figure
scatter3(R(:,1),R(:,2),R(:,3))
hold on
scatter3(R(:,1),R(:,3),R(:,2))
scatter3(R(:,2),R(:,1),R(:,3))
scatter3(R(:,2),R(:,3),R(:,1))
scatter3(R(:,3),R(:,1),R(:,2))
scatter3(R(:,3),R(:,2),R(:,1))



% 
% RIn      = 1.5d0
% REnd     = 10.d0
% NSamples = 1000
% 
% RFinal      = [];
% Samples     = lhsdesign(NSamples,2);
% RFinal(:,1) = Samples(:,1)      .* (REnd-RIn)   + RIn;
% RFinal(:,3) = Samples(:,2)      .* (REnd-RIn)   + RIn;
% AngleFinal  = 120;
% RDaje  = [];
% for i=1:NSamples
%   RFinal(i,2) = sqrt(RFinal(i,1)^2 + RFinal(i,3)^2 - 2.0*RFinal(i,1)*RFinal(i,3)*cos(120.0/180.0*pi));
%   if (RFinal(i,1).^2 < RFinal(i,2).^2 + RFinal(i,3).^2) && (RFinal(i,2).^2 < RFinal(i,1).^2 + RFinal(i,3).^2) && (RFinal(i,3).^2 < RFinal(i,1).^2 + RFinal(i,2).^2)
%     RDaje = [RDaje; RFinal(i,:)];
%   end
% end
% size(RDaje)
% 
% NameStr = strcat('./RSampled.csv');
% csvwrite(NameStr,[RDaje(:,1),RDaje(:,2),RDaje(:,3)])




% RIn      = 1.5d0
% REnd     = 10.d0
% NSamples = 81
% 
% NPoints  = floor(sqrt(NSamples))
% h        = (REnd-RIn)/(NPoints-1)
% Points   = [RIn:h:REnd];
% 
% RFinal      = [];
% AngleFinal  = 120;
% RDaje       = [];
% ii = 1;
% for i=1:NPoints
%   for j=1:NPoints
%     RFinal = sqrt(Points(i)^2 + Points(j)^2 - 2.0*Points(i)*Points(j)*cos(120.0/180.0*pi));
%     %if (RFinal(i,1).^2 < RFinal(i,2).^2 + RFinal(i,3).^2) && (RFinal(i,2).^2 < RFinal(i,1).^2 + RFinal(i,3).^2) && (RFinal(i,3).^2 < RFinal(i,1).^2 + RFinal(i,2).^2)
%       RDaje = [RDaje; [Points(i), RFinal, Points(j)]];
%     %end
%     ii = ii + 1;
%   end
% end
% size(RDaje)
% 
% NameStr = strcat('./RSampled.csv');
% csvwrite(NameStr,[RDaje(:,1),RDaje(:,2),RDaje(:,3)])



RIn      = 1.5d0
REnd     = 10.d0
NSamples = 2000

G1Min = 3.0*exp(-10.0);
G1Max = 3.0*exp(-1.5);
G2Min = 3.0*exp(-10.0).^2;
G2Max = 3.0*exp(-1.5).^2;
G3Min = exp(-10.0).^3;
G3Max = exp(-1.5).^3;
G10   = 3.0*exp(-5.0);
G20   = 3.0*exp(-5.0).^2;
G30   = exp(-5.0).^3;
R0    = 5.0;


GSamp      = [];
Samples    = lhsdesign(NSamples,3);
GSamp(:,1) = Samples(:,1)      .* (G1Max-G1Min) + G1Min;
GSamp(:,2) = Samples(:,2)      .* (G2Max-G2Min) + G2Min;
GSamp(:,3) = Samples(:,3)      .* (G3Max-G3Min) + G3Min;

iSample = 1;
iAcc    = 0;
RFinal  = [];
while (size(RFinal,1) < 1000) 
  
  G = GSamp(iSample,:);
  
  options      = optimoptions('fsolve','Display','none','PlotFcn',@optimplotfirstorderopt,'MaxFunctionEvaluations',300);
  f            = @(R) PIP(R,G);
  R00          = [2.0, 8.0, 5.0];
  [RTemp,fval] = fsolve(f,R00);
  %GG           = PIP(RTemp, G)
  if (RTemp(1) <= RTemp(2) + RTemp(3)) && (RTemp(2) <= RTemp(1) + RTemp(3)) && (RTemp(3) <= RTemp(1) + RTemp(2)) && (sum(RTemp>=1.5)==3) &&  (sum(RTemp<=10.0)==3)
    RFinal = [RFinal; RTemp];
    iAcc   = iAcc + 1
  end
  
  iSample = iSample + 1;
end

GFinale = PIP_New(RFinal);
figure(1)
histogram(GFinale(:,1),100)
hold on 
histogram(GSamp(:,1),100)
figure(2)
histogram(GFinale(:,2),100)
hold on 
histogram(GSamp(:,2),100)
figure(3)
histogram(GFinale(:,3),100)
hold on 
histogram(GSamp(:,3),100)

figure
scatter3(RFinal(:,1),RFinal(:,2),RFinal(:,3))