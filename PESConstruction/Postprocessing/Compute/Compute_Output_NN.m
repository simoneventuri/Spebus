%% Predicting Potential through PIP-NN 
%
function [EPred, EPredTot] = Compute_Output_NN(R)

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
    
    global Input Param Syst PIP NN
    
    NData = size(R,1);

    p1 = Compute_BondOrder(R(:,1), 1);
    p2 = Compute_BondOrder(R(:,2), 2);
    p3 = Compute_BondOrder(R(:,3), 3);

    if strcmp(Input.ModelType,'NN')

        G  = Compute_PIP(p1, p2, p3);

        b1Mat = repmat(NN.b1',[NData,1]);
        b2Mat = repmat(NN.b2',[NData,1]);
        b3Mat = repmat(NN.b3',[NData,1]);

        z1     = G * NN.W1 + b1Mat;
        y1     = tanh(z1);
        z2     = y1 * NN.W2 + b2Mat;
        y2     = tanh(z2);
        EPred  = y2 * NN.W3 + b3Mat;

        
    elseif strcmp(Input.ModelType,'BNN')

        G  = Compute_PIP(p1, p2, p3);

        b1Mat = repmat(BNN.b1',[NData,1]);
        b2Mat = repmat(BNN.b2',[NData,1]);
        b3Mat = repmat(BNN.b3',[NData,1]);

        z1     = G * BNN.W1 + b1Mat;
        y1     = tanh(z1);
        z2     = y1 * BNN.W2 + b2Mat;
        y2     = tanh(z2);
        EPred  = y2 * BNN.W3 + b3Mat;

        EPred  = EPred.*exp(BNN.Noise);%normrnd(0.0,BNN.Sigma);

        %     if (BNN.Sigma > 0.0)
        %       EPredSum = EPred.*0.0;
        %       for iSigma = 1:BNN.NSigma
        %         EPred    = EPred + normrnd(0.0,BNN.Sigma);
        %         EPredSum = EPredSum + EPred;
        %       end
        %       EPred = EPredSum ./ BNN.NSigma;
        %     end

        
    elseif strcmp(Input.ModelType,'Pol')

        IdxVecs  = [[1,1,0]; ...
                    [1,1,1]; [2,1,0]; ...
                    [2,1,1]; [2,2,0]; [3,1,0]; ...       
                    [2,2,1]; [3,1,1]; [3,2,0]; [4,1,0]; ...
                    [2,2,2]; [3,2,1]; [4,1,1]; [3,3,0]; [4,2,0]; [5,1,0]; ...
                    [3,2,2]; [3,3,1]; [4,2,1]; [5,1,1]; [4,3,0]; [5,2,0]; [6,1,0]; ...
                    [3,3,2]; [4,2,2]; [4,3,1]; [5,2,1]; [6,1,1]; [4,4,0]; [5,3,0]; [6,2,0]; [7,1,0]; ...   
                    [3,3,3]; [4,3,2]; [4,4,1]; [5,2,2]; [5,3,1]; [6,2,1]; [7,1,1]; [5,4,0]; [6,3,0]; [7,2,0]; [8,1,0]; ...
                    [4,3,3]; [4,4,2]; [5,3,2]; [5,4,1]; [6,2,2]; [6,3,1]; [7,2,1]; [8,1,1]; [5,5,0]; [6,4,0]; [7,3,0]; [8,2,0]; [9,1,0]; ...           
                    [4,4,3]; [5,3,3]; [5,4,2]; [5,5,1]; [6,3,2]; [6,4,1]; [6,5,0]; [7,2,2]; [7,3,1]; [7,4,0]; [8,2,1]; [8,3,0]; [9,1,1]; [9,2,0]; [10,1,0]; ...
                    [4,4,4]; [5,4,3]; [5,5,2]; [6,4,2]; [6,5,1]; [6,6,0]; [7,3,2]; [7,4,1]; [7,5,0]; [8,2,2]; [8,3,1]; [8,4,0]; [9,2,1]; [9,3,0]; [10,1,1]; [10,2,0]; [11,1,0]; ...
                    [5,4,4]; [6,4,4]; [6,5,2]; [6,4,2]; [6,6,1]; [7,3,3]; [7,4,2]; [7,5,1]; [8,3,2]; [8,4,1]; [8,5,0]; [9,2,2]; [9,3,1]; [9,4,0]; [10,2,1]; [10,3,0]; [11,2,0]; [11,1,1]; [12,1,0]; ...
                    [5,5,4]; [6,3,5]; [6,4,4]; [7,3,4]; [7,5,2]; [7,6,1]; [7,7,0]; [8,3,3]; [8,4,2]; [8,5,1]; [8,6,0]; [9,3,2]; [9,4,1]; [9,5,0]; [10,2,2]; [10,3,1]; [10,4,0]; [11,2,1]; [11,3,0]; [12,2,0]; [13,1,0]];
        PermVecs  = [2; ...
                     6; 1; ...
                     2; 2; 1; ... 
                     2; 2; 1; 1; ...
                     6; 1; 2; 2; 1; 1; ...
                     2; 2; 1; 2; 1; 1; 1; ...
                     2; 2; 1; 1; 2; 2; 1; 1; 1; ...  
                     6; 1; 2; 2; 1; 1; 2; 1; 1; 1; 1; ...
                     2; 2; 1; 1; 2; 1; 1; 2; 2; 1; 1; 1; 1; ...    
                     2; 2; 1; 2; 1; 1; 1; 2; 1; 1; 1; 1; 2; 1; 1; ... 
                     6; 1; 2; 1; 1; 2; 1; 1; 1; 2; 1; 1; 1; 1; 2; 1; 1; ... 
                     2; 2; 1; 1; 2; 2; 1; 1; 1; 1; 1; 2; 1; 1; 1; 1; 1; 2; 1; ...
                     2; 1; 2; 1; 1; 1; 2; 2; 1; 1; 1; 1; 1; 1; 2; 1; 1; 1; 1; 1; 1];
        NbVecs   = [1,0,1,2,3,4,6,7,9,11,13,15,17,19,21];

        Sum  = p1.*0.0;
        iCum = 1;
        for iOrd=2:NN.NOrd
            for iIdx=1:NbVecs(iOrd+1)
                IdxVec = IdxVecs(iCum,:);
                Sum    = Sum + W1(iCum) .* (p1.^IdxVec(1) .* p2.^IdxVec(2) .* p3.^IdxVec(3) + p1.^IdxVec(1) .* p2.^IdxVec(3) .* p3.^IdxVec(2) + ...
                                            p1.^IdxVec(2) .* p2.^IdxVec(1) .* p3.^IdxVec(3) + p1.^IdxVec(2) .* p2.^IdxVec(3) .* p3.^IdxVec(1) + ...
                                            p1.^IdxVec(3) .* p2.^IdxVec(1) .* p3.^IdxVec(2) + p1.^IdxVec(3) .* p2.^IdxVec(2) .* p3.^IdxVec(1)) ./ PermVecs(iCum);
                iCum   = iCum + 1;
            end
        end

        EPred = Sum' .* 0.159360144e-2.*27.2113839712790;
        EPred = EPred - Syst.VMin;

    end 

    
    if (Input.MultErrorFlg) 
        EPred = exp(EPred);
        EPred = EPred - Input.PreLogShift;
    end
    
    
    if (Input.OnlyTriatFlg)
        EDiat = R(:,1).*0.0;
        for iP=1:3
            iMol  = Syst.Pair(iP).ToMol;
            EDiat = EDiat + DiatPot_Spebus(R(:,iP),  0, iMol);
        end
        EPredTot = EPred + EDiat;       
    end

end