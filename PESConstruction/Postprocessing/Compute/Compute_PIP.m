%% Computing PIP transformation (p -> G) 
%
function [G] = Compute_PIP(p1, p2, p3)

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

    global PIP

    if strcmp(PIP.Fun(1),'Simone')

        GVec1  = [p1.*p2; p2.*p3; p1.*p3];
        GVec2  = [GVec1(1,:).*p1; GVec1(1,:).*p2; GVec1(2,:).*p2; GVec1(2,:).*p3; GVec1(3,:).*p1; GVec1(3,:).*p3];

        G(:,1) = sum(GVec1,1);
        G(:,2) = (p1.*p2.*p3);
        G(:,3) = sum(GVec2,1);

        G(:,4) = GVec2(1,:).*p1 + GVec2(2,:).*p2 + GVec2(3,:).*p2 + GVec2(4,:).*p3 + GVec2(5,:).*p1 + GVec2(6,:).*p3;
        G(:,5) = GVec2(1,:).*p3 + GVec2(3,:).*p1 + GVec2(6,:).*p2;
        G(:,6) = GVec2(1,:).*p2 + GVec2(3,:).*p3 + GVec2(5,:).*p3;

    elseif strcmp(PIP.Fun(1),'Alberto')

        if     strcmp(PIP.Fun(2), 'Old')
            G(:,1)   = (p1+p2+p3);
        elseif strcmp(PIP.Fun(2), 'New')
            G(:,1)   = (p1.*p2.*p3).*(p1+p2+p3);
        elseif strcmp(PIP.Fun(2), 'Dif')
            G(:,1)   = (p1.*p2 + p2.*p3 + p3.*p1).*(p1+p2+p3);
        end

        G(:,2)   = (p1.*p2 + p2.*p3 + p3.*p1);
        G(:,3)   = (p1.*p2.*p3);

    end

end