%% Computing transformation R -> p 
%
function [p] = Compute_BondOrder(R, iP)

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

    if     strcmp(PIP.BondOrder_Fun, 'MorseFun')
        p = exp( - PIP.Lambda(iP,1) .* (R - PIP.re(iP,1)) )';

    elseif strcmp(PIP.BondOrder_Fun, 'GaussFun')
        p = exp( - PIP.Lambda(iP,1) .* (R - PIP.re(iP,1)).^2 )';

    elseif strcmp(PIP.BondOrder_Fun, 'MEGFun')
        p = exp( - PIP.Lambda(iP,1) .* (R - PIP.re(iP,1)) - PIP.Lambda(iP,2) .* (R - PIP.re(iP,2)).^2 )';

    end
  
end
