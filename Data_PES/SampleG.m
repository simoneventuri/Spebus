close all
clear all
clc


G1  = rand(1000,1);
G3  = rand(1000,1);
Ang = normrnd(120.0,18.0,1000,1);

R1 = log( 1.0 ./ (exp(-1.5) + G1 .*(-exp(-1.5) + exp(-10.0))) );
R3 = log( 1.0 ./ (exp(-1.5) + G3 .*(-exp(-1.5) + exp(-10.0))) );

R2 = sqrt(R1.^2 + R3.^2 - 2.0*R1.*R3.*cos(Ang/180.0*pi));

NameStr = strcat('./RSampled.csv');
csvwrite(NameStr,[R1,R2,R3])


% G1 = rand(1000,1);
% G2 = rand(1000,1);
% G3 = rand(1000,1);
% figure
% histogram(G1,300)
% 
% R1 = log( 1.0 ./ (exp(-1.5) + G1 .*(-exp(-1.5) + exp(-10.0))) );
% R2 = log( 1.0 ./ (exp(-1.5) + G2 .*(-exp(-1.5) + exp(-10.0))) );
% R3 = log( 1.0 ./ (exp(-1.5) + G3 .*(-exp(-1.5) + exp(-10.0))) );
% figure
% histogram(R1,300)
% 
% 
% GG1  = exp(-R1);
% GG2  = exp(-R2);
% GG3  = exp(-R3);
% figure
% histogram(GG1,300)
% hold on
% histogram(GG2,300)
% histogram(GG3,300)
% 
% 
% % R1 = rand(100000,1).*(10.0-1.5)+1.5;
% % R2 = rand(100000,1).*(10.0-1.5)+1.5;
% % R3 = rand(100000,1).*(10.0-1.5)+1.5;
% 
% GG1 = exp(-R1) + exp(-R2) + exp(-R3);
% figure
% histogram(GG1,300)
% 
% GG2 = exp(-R1).*exp(-R2) + exp(-R3).*exp(-R2) + exp(-R1).*exp(-R3);
% figure
% histogram(GG2,300)
% 
% GG3 = exp(-R1).*exp(-R2).*exp(-R3);
% figure
% histogram(GG3,300)


% close all
% ROld     = [5.0, 2.0, 3.0];
% GOld = exp(-ROld(1)) + exp(-ROld(2))+ exp(-ROld(3));
% PropSD   = 1.d0;
% RChain   = ROld;
% NSamples = 1000000;
% iBurn    = 50000;
% iJump    = 30;
% iAcc     = 0;
% for i=1:NSamples
%   
%   RNew = ROld + normrnd(0,PropSD,1,3);
%   GNew = exp(-RNew(1)) + exp(-RNew(2))+ exp(-RNew(3));
%   
%   alpha=GNew/GOld;
%   if (alpha > rand) && (sum(RNew >= 1.5)==3) && (sum(RNew <= 10.0)==3)
%     ROld = RNew;    
%     GOld = GNew;
%     iAcc = iAcc + 1;
%   end
%   RChain = [RChain; ROld];
%   
%   i;
% end
% iAcc/NSamples*100
% RClean = RChain(iBurn:iJump:end,:);
% 
% figure
% histogram(RClean,300)
% 
% GG1 = exp(-RClean(:,1)) + exp(-RClean(:,2)) + exp(-RClean(:,3));
% figure
% histogram(GG1,300)



% close all
% ROld     = [5.0];
% PropSD   = 1.d0;
% RChain   = ROld;
% NSamples = 1000000;
% iBurn    = 5000;
% iJump    = 30;
% iAcc     = 0;
% for i=1:NSamples
%   
%   RNew = ROld + normrnd(0,PropSD);
%   GOld = exp(-ROld);
%   GNew = exp(-RNew);
%   
%   alpha=GNew/GOld;
%   if (alpha > rand) && (sum(RNew > 1.5)==1) && (sum(RNew < 10.0)==1)
%     ROld = RNew;    
%     iAcc = iAcc + 1;
%   end
%   RChain = [RChain; ROld];
%   
%   i;
% end
% iAcc/NSamples*100
% RClean = RChain(iBurn:iJump:end);
% 
% figure
% histogram(RClean,300)
% 
% GG1 = exp(-RClean);
% figure
% histogram(GG1,300)