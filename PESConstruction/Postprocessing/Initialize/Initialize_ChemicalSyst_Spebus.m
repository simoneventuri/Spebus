%% The Function Loads the Variables of the Chemical System
%                       
function [Syst] = Initialize_ChemicalSyst_Spebus(Syst)

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

    
    fprintf('= Initialize_ChemicalSyst_Spebus ===================\n')
    fprintf('====================================================\n')
    fprintf(['Loading Variables for Chemical System: ', char(Syst.NameLong), '\n'])
    
    if strcmp(Syst.NameLong, 'N3_NASA')
        
        %%% System
        Syst.Name          = 'N3';
% 
%         Syst.NProc         = 2; %(Diss+Inel&Exch)
        Syst.NProc         = 3; %(Diss+Inel+Exch)

        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'N';
        Syst.Atom(2).Name  = 'N';
        Syst.Atom(3).Name  = 'N';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 200;

        Syst.Atom(1).Mass  = 14.0067e-3;
        Syst.Atom(2).Mass  = 14.0067e-3;
        Syst.Atom(3).Mass  = 14.0067e-3;
        
        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 1;
        Syst.Molecule(1).Name             = 'N2';
        %Syst.Molecule(1).DissEn           = -9.75;
        Syst.Molecule(1).DegeneracyFactor = [3, 6];
        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2;
        Syst.Molecule(1).NLevelsOrig      = 9390;
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(1).DiatPot          = 'N2_LeRoy';  
        Syst.MolToOtherSyst(1)            = 0;
        
        Syst.OtherSyst_NameLong           = '';

        %%% Pairs
        Syst.Pair(1).Name  = 'N2';
        Syst.Pair(2).Name  = 'N2';
        Syst.Pair(3).Name  = 'N2';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 1;
        Syst.Pair(3).ToMol = 1;

        Syst.Pair(1).Color = [17, 17, 17] ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  2;
        
        Syst.CFDComp(1).Name   = 'N';
        Syst.CFDComp(2).Name   = 'N2';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = 2.0 * Syst.Atom(1).Mass;

        Syst.CFDComp(1).Qe      = 12;
        Syst.CFDComp(2).Qe      = 1;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        
        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-';

        Syst.MolToCFDComp       = [2];

        
%         Syst.RxLxIdx = [ 2,-1;   % Diss;
%                          0, 0];  % Inel+Exch1
% 
%         %% Exchange Properties
%         Syst.ExchToMol          = [];
%         Syst.ExchToAtom         = [];        
%         Syst.PairToExch         = [];

                     
        Syst.RxLxIdx = [-2, 1;   % Diss
                         0, 0;   % Inel
                         0, 0];  % Exch1                        

        %% Exchange Properties
        Syst.ExchToMol          = [1];
        Syst.ExchToAtom         = [3];
        Syst.PairToExch         = [1];
        
        Syst.ToOtherExch        = []    ;
        
        Syst.ColPartToComp      = 1; 
    
    
    elseif strcmp(Syst.NameLong, 'O3_UMN')
        
        %%% System
        Syst.Name              = 'O3';

        Syst.NProc = 3; %(Diss+Inel+Exch)
        
        %%% PESs
        Syst.PESName       = [string('11A1'), string('11A2'), string('13A1'), string('13A2'), string('15A1'), string('15A2'), string('21A1'), string('23A1'), string('25A1')];
        Syst.NPESs         = size(Syst.PESName,2);

        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'O';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'O';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 200;

        Syst.Atom(1).Mass  = 15.9994e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = 15.9994e-3;

        Syst.Atom(1).MassQCT  = 29148.94559e0;
        Syst.Atom(2).MassQCT  = 29148.94559e0;
        Syst.Atom(3).MassQCT  = 29148.94559e0;
        
        %%% Molecules
        Syst.NMolecules                   = 1;
        Syst.Molecule(1).Name             = 'O2';
        %Syst.Molecule(1).DissEn           = -5.211;
        Syst.Molecule(1).DegeneracyFactor = [1/2, 1/2];
        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2.0;
        Syst.Molecule(1).NLevelsOrig      = 6115;
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(1).DiatPot          = 'O2_UMN';
        Syst.MolToOtherSyst(1)            = 0;
        
        Syst.OtherSyst_NameLong           = '';

        %%% Pairs
        Syst.Pair(1).Name  = 'O2';
        Syst.Pair(2).Name  = 'O2';
        Syst.Pair(3).Name  = 'O2';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 1;
        Syst.Pair(3).ToMol = 1;

        Syst.Pair(1).Color = [17, 17, 17] ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  2;
        
        Syst.CFDComp(1).Name   = 'O';
        Syst.CFDComp(2).Name   = 'O2';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = 2.0 * Syst.Atom(1).Mass;

        Syst.CFDComp(1).Qe      = 9;
        Syst.CFDComp(2).Qe      = 3;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        
        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-';
        
        Syst.RxLxIdx = [ 2,-1;   % Diss
                         0, 0;   % Inel 
                         0, 0];  % Exch1
                        
        Syst.MolToCFDComp       = [2];

        
        %% Exchange Properties
        Syst.ExchToMol          = [1];
        Syst.ExchToAtom         = [1];
        
        Syst.PairToExch         = [1];
        
        Syst.ToOtherExch        = [0];
        
        Syst.ColPartToComp      = 1; 
        
    
    elseif strcmp(Syst.NameLong, 'CO2_NASA')
        
        %%% System
        Syst.Name                 = 'CO2';

        Syst.NProc = 4; %(Diss+Inel+Exch+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'C';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'O';

        Syst.Atom(1).Color = [0, 0, 0];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 100;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 200;

        Syst.Atom(1).Mass  = 12.0110e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = 15.9994e-3;

        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 2;
        
        Syst.Molecule(1).Name             = 'CO';
        Syst.Molecule(2).Name             = 'O2';

        %Syst.Molecule(1).DissEn           = -11.228285428314086;
        %Syst.Molecule(2).DissEn           = -5.16;%-5.062189482141;

        Syst.Molecule(1).DegeneracyFactor = [  1,   1];
        Syst.Molecule(2).DegeneracyFactor = [1/2, 1/2];

        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass+Syst.Atom(2).Mass;
        Syst.Molecule(2).Mu               = Syst.Atom(2).Mass*2.0;

        Syst.Molecule(1).NLevelsOrig      = 13521;
        Syst.Molecule(2).NLevelsOrig      = 6078;
    
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(2).ToAtoms          = [2,3];
        
        Syst.Molecule(1).DiatPot          = 'CO_NASA';
        Syst.Molecule(2).DiatPot          = 'O2_NASA';

        Syst.MolToOtherSyst(1)            = 0;
        Syst.MolToOtherSyst(2)            = 1;

        Syst.OtherSyst_NameLong(1,:)      = 'O2C_NASA';

        %%% Pairs
        Syst.Pair(1).Name  = 'CO';
        Syst.Pair(2).Name  = 'CO';
        Syst.Pair(3).Name  = 'O2';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 1;
        Syst.Pair(3).ToMol = 2;

        Syst.Pair(1).Color = [17, 17, 17] ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [0, 0, 256]  ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  4;
        
        Syst.CFDComp(1).Name   = 'C';
        Syst.CFDComp(2).Name   = 'O';
        Syst.CFDComp(3).Name   = 'CO';
        Syst.CFDComp(4).Name   = 'O2';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 0;
        Syst.CFDComp(3).ToMol   = 1;
        Syst.CFDComp(4).ToMol   = 2;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = Syst.Atom(2).Mass;
        Syst.CFDComp(3).Mass    = Syst.Atom(1).Mass + Syst.Atom(2).Mass;
        Syst.CFDComp(4).Mass    = 2.0 * Syst.Atom(3).Mass;

        Syst.CFDComp(1).Qe      = 1;
        Syst.CFDComp(2).Qe      = 9;
        Syst.CFDComp(3).Qe      = 1;
        Syst.CFDComp(4).Qe      = 3;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        Syst.CFDComp(3).Color   = [ 204,   0,   0] ./ 256;
        Syst.CFDComp(4).Color   = [   0,   0, 234] ./ 256;

        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-.';
        Syst.CFDComp(3).LineStyle = '-';
        Syst.CFDComp(4).LineStyle = '--';
        
        Syst.RxLxIdx = [ 1,  1,-1,  0;   % Diss
                         0,  0, 0,  0;   % Inel 
                         0,  0, 0,  0;   % Exch1
                         1, -1,-1,  1];  % Exch2
        
        Syst.MolToCFDComp       = [3, 4];

        
        %% Exchange Properties
        Syst.ExchToMol          = [1; 2];
        Syst.ExchToAtom         = [3; 1];
        
        Syst.PairToExch         = [1; 2];
        
        Syst.ToOtherExch        = [0; 1];
        
        Syst.ColPartToComp      = 2; 
        
        
    elseif strcmp(Syst.NameLong, 'O2C_NASA')
        
        %%% System
        Syst.Name              = 'O2C';

        Syst.NProc = 3; %(Diss+Inel+Exch)

        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'O';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'C';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 0];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 100;

        Syst.Atom(1).Mass  = 15.9994e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = Syst.Atom(1).Mass;

        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 2;
        
        Syst.Molecule(1).Name             = 'O2';
        Syst.Molecule(2).Name             = 'CO';

        %Syst.Molecule(1).DissEn           = -5.16;%-5.062189482141;
        %Syst.Molecule(2).DissEn           = -11.228285428314086;

        Syst.Molecule(1).DegeneracyFactor = [1/2, 1/2];
        Syst.Molecule(2).DegeneracyFactor = [  1,   1];

        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2.0;
        Syst.Molecule(2).Mu               = Syst.Atom(1).Mass+Syst.Atom(3).Mass;

        Syst.Molecule(1).NLevelsOrig      = 6078;
        Syst.Molecule(2).NLevelsOrig      = 13521;
    
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(2).ToAtoms          = [2,3];
        
        Syst.Molecule(1).DiatPot          = 'O2_NASA';
        Syst.Molecule(2).DiatPot          = 'CO_NASA';
        
        Syst.MolToOtherSyst(1)            = 0;
        Syst.MolToOtherSyst(2)            = 1;

        Syst.OtherSyst_NameLong(1,:)      = 'CO2_NASA';
        
        %%% Pairs
        Syst.Pair(1).Name  = 'O2';
        Syst.Pair(2).Name  = 'CO';
        Syst.Pair(3).Name  = 'CO';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 2;
        Syst.Pair(3).ToMol = 2;

        Syst.Pair(1).Color = [0, 0, 256]  ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  4;
        
        Syst.CFDComp(1).Name   = 'C';
        Syst.CFDComp(2).Name   = 'O';
        Syst.CFDComp(3).Name   = 'CO';
        Syst.CFDComp(4).Name   = 'O2';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 0;
        Syst.CFDComp(3).ToMol   = 2;
        Syst.CFDComp(4).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(3).Mass;
        Syst.CFDComp(2).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(3).Mass    = Syst.Atom(1).Mass + Syst.Atom(3).Mass;
        Syst.CFDComp(4).Mass    = 2.0 * Syst.Atom(1).Mass;

        Syst.CFDComp(1).Qe      = 1;
        Syst.CFDComp(2).Qe      = 9;
        Syst.CFDComp(3).Qe      = 1;
        Syst.CFDComp(4).Qe      = 3;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        Syst.CFDComp(3).Color   = [ 204,   0,   0] ./ 256;
        Syst.CFDComp(4).Color   = [   0,   0, 234] ./ 256;

        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-.';
        Syst.CFDComp(3).LineStyle = '-';
        Syst.CFDComp(4).LineStyle = '--';

        Syst.RxLxIdx = [ 0,  2,  0, -1;   % Diss
                         0,  0,  0,  0;   % Inel 
                        -1,  1,  1, -1];  % Exch1
        
        Syst.MolToCFDComp       = [4, 3];

        
        %% Exchange Properties
        Syst.ExchToMol          = [2];
        Syst.ExchToAtom         = [3];

        Syst.PairToExch         = [2];
        
        Syst.ToOtherExch        = [2];
        
        Syst.ColPartToComp      = 1; 
        
        
    elseif strcmp(Syst.NameLong, 'N2O_UMN')
        
        %%% System
        Syst.Name              = 'N2O';

        Syst.NProc = 3; %(Diss+Inel+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'N';
        Syst.Atom(2).Name  = 'N';
        Syst.Atom(3).Name  = 'O';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 0];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 100;

        Syst.Atom(1).Mass  = 14.0067e-3;
        Syst.Atom(2).Mass  = 14.0067e-3;
        Syst.Atom(3).Mass  = 15.9994e-3;
        
        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 2;
        
        Syst.Molecule(1).Name             = 'N2';
        Syst.Molecule(2).Name             = 'NO';

        %Syst.Molecule(1).DissEn           = -9.904361;
        %Syst.Molecule(2).DissEn           = -6.617426;

        Syst.Molecule(1).DegeneracyFactor = [ 3, 6]; %Odd, Even
        Syst.Molecule(2).DegeneracyFactor = [ 2, 2];

        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2.0;
        Syst.Molecule(2).Mu               = Syst.Atom(1).Mass+Syst.Atom(3).Mass;

        Syst.Molecule(1).NLevelsOrig      = 9093;
        Syst.Molecule(2).NLevelsOrig      = 6793;
    
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(2).ToAtoms          = [2,3];
        
        Syst.Molecule(1).DiatPot          = 'N2_UMN_ForN2O2';
        Syst.Molecule(2).DiatPot          = 'NO_UMN';
        
        Syst.MolToOtherSyst(1)            = 0;
        Syst.MolToOtherSyst(2)            = 1;

        Syst.OtherSyst_NameLong(1,:)      = 'NON_UMN';
        
        %%% Pairs
        Syst.Pair(1).Name  = 'N2';
        Syst.Pair(2).Name  = 'NO';
        Syst.Pair(3).Name  = 'NO';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 2;
        Syst.Pair(3).ToMol = 2;

        Syst.Pair(1).Color = [0, 0, 256]  ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  4;
        
        Syst.CFDComp(1).Name   = 'N';
        Syst.CFDComp(2).Name   = 'O';
        Syst.CFDComp(3).Name   = 'N2';
        Syst.CFDComp(4).Name   = 'NO';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 0;
        Syst.CFDComp(3).ToMol   = 1;
        Syst.CFDComp(4).ToMol   = 2;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = Syst.Atom(3).Mass;
        Syst.CFDComp(3).Mass    = 2.0 * Syst.Atom(1).Mass;
        Syst.CFDComp(4).Mass    = Syst.Atom(1).Mass + Syst.Atom(3).Mass;

        Syst.CFDComp(1).Qe      = 12;
        Syst.CFDComp(2).Qe      = 9;
        Syst.CFDComp(3).Qe      = 1;
        Syst.CFDComp(4).Qe      = 4;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        Syst.CFDComp(3).Color   = [ 204,   0,   0] ./ 256;
        Syst.CFDComp(4).Color   = [   0,   0, 234] ./ 256;

        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-.';
        Syst.CFDComp(3).LineStyle = '-';
        Syst.CFDComp(4).LineStyle = '--';

        Syst.RxLxIdx = [ 2,  0, -1,  0;   % Diss
                         0,  0,  0,  0;   % Inel 
                         1, -1, -1,  1];  % Exch1
        
        Syst.MolToCFDComp       = [3, 4];

        
        %% Exchange Properties
        Syst.ExchToMol          = [2];
        Syst.ExchToAtom         = [2];

        Syst.PairToExch         = [2];
        
        Syst.ToOtherExch        = [1];
        
        Syst.ColPartToComp      = 2; 
        
        
        
    elseif strcmp(Syst.NameLong, 'NON_UMN')
        
        %%% System
        Syst.Name              = 'NON';
        
        Syst.NProc = 4; %(Diss+Inel+Exch+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'N';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'N';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 0];
        Syst.Atom(3).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 100;
        Syst.Atom(3).Size  = 200;

        Syst.Atom(1).Mass  = 14.0067e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = 14.0067e-3;

        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 2;
        
        Syst.Molecule(1).Name             = 'NO';
        Syst.Molecule(2).Name             = 'N2';

        %Syst.Molecule(1).DissEn           = -6.617426;
        %Syst.Molecule(2).DissEn           = -9.904361;

        Syst.Molecule(1).DegeneracyFactor = [2, 2];
        Syst.Molecule(2).DegeneracyFactor = [3, 6];

        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass+Syst.Atom(2).Mass;
        Syst.Molecule(2).Mu               = Syst.Atom(1).Mass*2.0;

        Syst.Molecule(1).NLevelsOrig      = 6793;
        Syst.Molecule(2).NLevelsOrig      = 9093;
    
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(2).ToAtoms          = [1,3];
        
        Syst.Molecule(1).DiatPot          = 'NO_UMN';
        Syst.Molecule(2).DiatPot          = 'N2_UMN_ForN2O2';
        
        Syst.MolToOtherSyst(1)            = 0;
        Syst.MolToOtherSyst(2)            = 1;

        Syst.OtherSyst_NameLong(1,:)      = 'N2O_UMN';
        
        %%% Pairs
        Syst.Pair(1).Name  = 'NO';
        Syst.Pair(2).Name  = 'N2';
        Syst.Pair(3).Name  = 'NO';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 2;
        Syst.Pair(3).ToMol = 1;

        Syst.Pair(1).Color = [17, 17, 17] ./ 256;
        Syst.Pair(2).Color = [0, 0, 256]  ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  4;
        
        Syst.CFDComp(1).Name   = 'N';
        Syst.CFDComp(2).Name   = 'O';
        Syst.CFDComp(3).Name   = 'N2';
        Syst.CFDComp(4).Name   = 'NO';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 0;
        Syst.CFDComp(3).ToMol   = 2;
        Syst.CFDComp(4).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = Syst.Atom(2).Mass;
        Syst.CFDComp(3).Mass    = 2.0 * Syst.Atom(3).Mass;
        Syst.CFDComp(4).Mass    = Syst.Atom(1).Mass + Syst.Atom(2).Mass;

        Syst.CFDComp(1).Qe      = 12;
        Syst.CFDComp(2).Qe      = 9;
        Syst.CFDComp(3).Qe      = 1;
        Syst.CFDComp(4).Qe      = 4;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        Syst.CFDComp(3).Color   = [ 204,   0,   0] ./ 256;
        Syst.CFDComp(4).Color   = [   0,   0, 234] ./ 256;

        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-.';
        Syst.CFDComp(3).LineStyle = '-';
        Syst.CFDComp(4).LineStyle = '--';

        Syst.RxLxIdx = [ 1,  1,  0, -1;   % Diss
                         0,  0,  0,  0;   % Inel 
                        -1,  1,  1, -1;   % Exch1
                         0,  0,  0,  0];  % Exch2 

        Syst.MolToCFDComp       = [4, 3];

        
        %% Exchange Properties
        Syst.ExchToMol          = [2; 1];
        Syst.ExchToAtom         = [2; 1];

        Syst.PairToExch         = [2; 3];

        Syst.ToOtherExch        = [0; 1];
        
        Syst.ColPartToComp      = 1; 
    
        
    elseif strcmp(Syst.NameLong, 'O2N_Basel')
        
        %%% System
        Syst.Name              = 'NO2';

        Syst.NProc = 3; %(Diss+Inel+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'O';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'N';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 0];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 100;

        Syst.Atom(1).Mass  = 15.9994e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = 14.0067e-3;

        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 2;
        
        Syst.Molecule(1).Name             = 'O2';
        Syst.Molecule(2).Name             = 'NO';

        %Syst.Molecule(1).DissEn           = 0.0;
        %Syst.Molecule(2).DissEn           = 0.0;

        Syst.Molecule(1).DegeneracyFactor = [1/2, 1/2]; %Odd, Even
        Syst.Molecule(2).DegeneracyFactor = [  2,   2];

        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2.0;
        Syst.Molecule(2).Mu               = Syst.Atom(1).Mass+Syst.Atom(3).Mass;

        Syst.Molecule(1).NLevelsOrig      = 5781;
        Syst.Molecule(2).NLevelsOrig      = 6468;
    
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(2).ToAtoms          = [2,3];
        
        Syst.Molecule(1).DiatPot          = 'O2_Basel';
        Syst.Molecule(2).DiatPot          = 'NO_Basel';
        
        Syst.MolToOtherSyst(1)            = 0;
        Syst.MolToOtherSyst(2)            = 1;

        Syst.OtherSyst_NameLong(1,:)      = 'NO2_Basel';
        
        %%% Pairs
        Syst.Pair(1).Name  = 'O2';
        Syst.Pair(2).Name  = 'NO';
        Syst.Pair(3).Name  = 'NO';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 2;
        Syst.Pair(3).ToMol = 2;

        Syst.Pair(1).Color = [0, 0, 256]  ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  4;
        
        Syst.CFDComp(1).Name   = 'N';
        Syst.CFDComp(2).Name   = 'O';
        Syst.CFDComp(3).Name   = 'O2';
        Syst.CFDComp(4).Name   = 'NO';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 0;
        Syst.CFDComp(3).ToMol   = 1;
        Syst.CFDComp(4).ToMol   = 2;

        Syst.CFDComp(1).Mass    = Syst.Atom(3).Mass;
        Syst.CFDComp(2).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(3).Mass    = 2.0 * Syst.Atom(1).Mass;
        Syst.CFDComp(4).Mass    = Syst.Atom(1).Mass + Syst.Atom(3).Mass;

        Syst.CFDComp(1).Qe      = 12;
        Syst.CFDComp(2).Qe      = 9;
        Syst.CFDComp(3).Qe      = 3;
        Syst.CFDComp(4).Qe      = 4;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        Syst.CFDComp(3).Color   = [ 204,   0,   0] ./ 256;
        Syst.CFDComp(4).Color   = [   0,   0, 234] ./ 256;

        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-.';
        Syst.CFDComp(3).LineStyle = '-';
        Syst.CFDComp(4).LineStyle = '--';

        Syst.RxLxIdx = [ 0,  2, -1,  0;   % Diss
                         0,  0,  0,  0;   % Inel 
                        -1,  1,  1, -1];  % Exch1
        
        Syst.MolToCFDComp       = [3, 4];

        
        %% Exchange Properties
        Syst.ExchToMol          = [2];
        Syst.ExchToAtom         = [2];

        Syst.PairToExch         = [2];
        
        Syst.ToOtherExch        = [2];
        
        Syst.ColPartToComp      = 1; 
        
        
        
    elseif strcmp(Syst.NameLong, 'NO2_Basel')
        
        %%% System
        Syst.Name              = 'NO2';

        Syst.NProc = 4; %(Diss+Inel+Exch+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'N';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'O';

        Syst.Atom(1).Color = [0, 0, 0];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 100;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 200;

        Syst.Atom(1).Mass  = 14.0067e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = 15.9994e-3;
        
        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 2;
        
        Syst.Molecule(1).Name             = 'NO';
        Syst.Molecule(2).Name             = 'O2';

        %Syst.Molecule(1).DissEn           = 0.0;
        %Syst.Molecule(2).DissEn           = 0.0;

        Syst.Molecule(1).DegeneracyFactor = [  2,   2];
        Syst.Molecule(2).DegeneracyFactor = [1/2, 1/2]; %Odd, Even

        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass+Syst.Atom(2).Mass;
        Syst.Molecule(2).Mu               = Syst.Atom(2).Mass*2.0;

        Syst.Molecule(1).NLevelsOrig      = 6468;
        Syst.Molecule(2).NLevelsOrig      = 5781;

        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(2).ToAtoms          = [2,3];
        
        Syst.Molecule(1).DiatPot          = 'NO_Basel';
        Syst.Molecule(2).DiatPot          = 'O2_Basel';
        
        Syst.MolToOtherSyst(1)            = 0;
        Syst.MolToOtherSyst(2)            = 1;

        Syst.OtherSyst_NameLong(1,:)      = 'O2N_Basel';
        
        %%% Pairs
        Syst.Pair(1).Name  = 'NO';
        Syst.Pair(2).Name  = 'NO';
        Syst.Pair(3).Name  = 'O2';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 1;
        Syst.Pair(3).ToMol = 2;

        Syst.Pair(1).Color = [0, 0, 256]  ./ 256;
        Syst.Pair(2).Color = [0, 0, 256]  ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  4;
        
        Syst.CFDComp(1).Name   = 'N';
        Syst.CFDComp(2).Name   = 'O';
        Syst.CFDComp(3).Name   = 'O2';
        Syst.CFDComp(4).Name   = 'NO';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 0;
        Syst.CFDComp(3).ToMol   = 2;
        Syst.CFDComp(4).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = Syst.Atom(2).Mass;
        Syst.CFDComp(3).Mass    = 2.0 * Syst.Atom(2).Mass;
        Syst.CFDComp(4).Mass    = Syst.Atom(1).Mass + Syst.Atom(3).Mass;

        Syst.CFDComp(1).Qe      = 12;
        Syst.CFDComp(2).Qe      = 9;
        Syst.CFDComp(3).Qe      = 3;
        Syst.CFDComp(4).Qe      = 4;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        Syst.CFDComp(3).Color   = [ 204,   0,   0] ./ 256;
        Syst.CFDComp(4).Color   = [   0,   0, 234] ./ 256;

        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-.';
        Syst.CFDComp(3).LineStyle = '-';
        Syst.CFDComp(4).LineStyle = '--';

        Syst.RxLxIdx = [ 1,  1,  0, -1;   % Diss
                         0,  0,  0,  0;   % Inel 
                         0,  0,  0,  0;   % Exch1
                         1,  -1, -1, 1];  % Exch2
        
        Syst.MolToCFDComp       = [4, 3];

        
        %% Exchange Properties
        Syst.ExchToMol          = [1;2];
        Syst.ExchToAtom         = [3;2];

        Syst.PairToExch         = [2;3];
        
        Syst.ToOtherExch        = [0;1];
        
        Syst.ColPartToComp      = 2; 
        
        
    elseif strcmp(Syst.NameLong, 'CNH_UIUC')
        
        %%% System
        Syst.Name          = 'CNH';

        Syst.NProc         = 4; %(Diss+Inel+Exch+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 3;
        
        Syst.Atom(1).Name  = 'C';
        Syst.Atom(2).Name  = 'N';
        Syst.Atom(3).Name  = 'H';

        Syst.Atom(1).Color = [0, 0, 0];
        Syst.Atom(2).Color = [0, 1, 0];
        Syst.Atom(3).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 100;
        Syst.Atom(3).Size  =  50;

        Syst.Atom(1).Mass  = 12.0110e-3;
        Syst.Atom(2).Mass  = 14.0067e-3
        Syst.Atom(3).Mass  = 1.00790e-3;

        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        
        
        %%% Molecules
        Syst.NMolecules                   = 3;
        
        Syst.Molecule(1).Name             = 'CN';
        Syst.Molecule(2).Name             = 'CH';
        Syst.Molecule(3).Name             = 'NH';

        %Syst.Molecule(1).DissEn           = 0.0;
        %Syst.Molecule(2).DissEn           = 0.0;

        Syst.Molecule(1).DegeneracyFactor = [  2,   2];
        Syst.Molecule(2).DegeneracyFactor = [1/2, 1/2]; %Odd, Even
        Syst.Molecule(3).DegeneracyFactor = [1/2, 1/2]; %Odd, Even

        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass+Syst.Atom(2).Mass;
        Syst.Molecule(2).Mu               = Syst.Atom(1).Mass+Syst.Atom(3).Mass;
        Syst.Molecule(3).Mu               = Syst.Atom(2).Mass+Syst.Atom(3).Mass;

        Syst.Molecule(1).NLevelsOrig      = 1;
        Syst.Molecule(2).NLevelsOrig      = 1;
        Syst.Molecule(3).NLevelsOrig      = 1;

        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(2).ToAtoms          = [1,3];
        Syst.Molecule(3).ToAtoms          = [2,3];

        Syst.Molecule(1).DiatPot          = 'CN_UIUC';
        Syst.Molecule(2).DiatPot          = 'CH_UIUC';
        Syst.Molecule(3).DiatPot          = 'NH_UIUC';

        Syst.MolToOtherSyst(1)            = 0;
        Syst.MolToOtherSyst(2)            = 1;
        Syst.MolToOtherSyst(3)            = 2;

        Syst.OtherSyst_NameLong(1,:)      = 'CHN_UIUC';
        Syst.OtherSyst_NameLong(2,:)      = 'NHC_UIUC';

        %%% Pairs
        Syst.Pair(1).Name  = 'CN';
        Syst.Pair(2).Name  = 'CH';
        Syst.Pair(3).Name  = 'NH';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 2;
        Syst.Pair(3).ToMol = 3;

        Syst.Pair(1).Color = [0,   0, 256] ./ 256;
        Syst.Pair(2).Color = [0, 256, 256] ./ 256;
        Syst.Pair(3).Color = [256, 0,   0] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  6;
        
        Syst.CFDComp(1).Name   = 'C';
        Syst.CFDComp(2).Name   = 'N';
        Syst.CFDComp(3).Name   = 'H';
        Syst.CFDComp(4).Name   = 'CN';
        Syst.CFDComp(5).Name   = 'CH';
        Syst.CFDComp(6).Name   = 'NH';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 0;
        Syst.CFDComp(3).ToMol   = 0;
        Syst.CFDComp(4).ToMol   = 1;
        Syst.CFDComp(5).ToMol   = 2;
        Syst.CFDComp(6).ToMol   = 3;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = Syst.Atom(2).Mass;
        Syst.CFDComp(3).Mass    = Syst.Atom(3).Mass;
        Syst.CFDComp(4).Mass    = Syst.Atom(1).Mass + Syst.Atom(2).Mass;
        Syst.CFDComp(5).Mass    = Syst.Atom(1).Mass + Syst.Atom(3).Mass;
        Syst.CFDComp(6).Mass    = Syst.Atom(2).Mass + Syst.Atom(3).Mass;

        Syst.CFDComp(1).Qe      = 1;
        Syst.CFDComp(2).Qe      = 1;
        Syst.CFDComp(3).Qe      = 1;
        Syst.CFDComp(4).Qe      = 1;
        Syst.CFDComp(5).Qe      = 1;
        Syst.CFDComp(6).Qe      = 1;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        Syst.CFDComp(3).Color   = [ 204,   0,   0] ./ 256;
        Syst.CFDComp(4).Color   = [   0,   0, 234] ./ 256;
        Syst.CFDComp(5).Color   = [   0, 234,   0] ./ 256;
        Syst.CFDComp(6).Color   = [ 234,   0,   0] ./ 256;

        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-.';
        Syst.CFDComp(3).LineStyle = '--';
        Syst.CFDComp(4).LineStyle = '-';
        Syst.CFDComp(5).LineStyle = ':';
        Syst.CFDComp(6).LineStyle = '-.';

        Syst.RxLxIdx = [ 1,  1,  0, -1, 0, 0;   % Diss
                         0,  0,  0,  0, 0, 0;   % Inel 
                         0,  1, -1, -1, 1, 0;   % Exch1
                         1,  0, -1, -1, 0, 1];  % Exch2
        
        Syst.MolToCFDComp       = [4, 5, 6];

        
        %% Exchange Properties
        Syst.ExchToMol          = [1;2;3];
        Syst.ExchToAtom         = [3;2;1];

        Syst.PairToExch         = [1;2;3];
        
        Syst.ToOtherExch        = [0;1;2];
        
        Syst.ColPartToComp      = 3; 
        

    elseif strcmp(Syst.NameLong, 'N4_NASA')
        
        %%% System
        Syst.Name          = 'N4';

        Syst.NProc         = 3; %(Diss+Inel+Exch)

        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 4;
        
        Syst.Atom(1).Name  = 'N';
        Syst.Atom(2).Name  = 'N';
        Syst.Atom(3).Name  = 'N';
        Syst.Atom(4).Name  = 'N';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 1];
        Syst.Atom(4).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 200;
        Syst.Atom(4).Size  = 200;

        Syst.Atom(1).Mass  = 14.0067e-3;
        Syst.Atom(2).Mass  = 14.0067e-3;
        Syst.Atom(3).Mass  = 14.0067e-3;
        Syst.Atom(4).Mass  = 14.0067e-3;

        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        Syst.Atom(4).MassQCT  = 25526.04298e0;
        
        %%% Molecules
        Syst.NMolecules                   = 1;
        Syst.Molecule(1).Name             = 'N2';
        %Syst.Molecule(1).DissEn           = -9.75;
        Syst.Molecule(1).DegeneracyFactor = [3, 6];
        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2.0;
        Syst.Molecule(1).NLevelsOrig      = 9399;
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(1).DiatPot          = 'N2_NASA';  
        Syst.MolToOtherSyst(1)            = 0;
        
        Syst.OtherSyst_NameLong           = '';

        %%% Pairs
        Syst.Pair(1).Name  = 'N2';
        Syst.Pair(2).Name  = 'N2';
        Syst.Pair(3).Name  = 'N2';
        Syst.Pair(4).Name  = 'N2';
        Syst.Pair(5).Name  = 'N2';
        Syst.Pair(6).Name  = 'N2';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 1;
        Syst.Pair(3).ToMol = 1;
        Syst.Pair(4).ToMol = 1;
        Syst.Pair(5).ToMol = 1;
        Syst.Pair(6).ToMol = 1;

        Syst.Pair(1).Color = [17, 17, 17] ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;
        Syst.Pair(4).Color = [17, 17, 17] ./ 256;
        Syst.Pair(5).Color = [17, 17, 17] ./ 256;
        Syst.Pair(6).Color = [17, 17, 17] ./ 256;
        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  2;
        
        Syst.CFDComp(1).Name   = 'N';
        Syst.CFDComp(2).Name   = 'N2';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = 2.0 * Syst.Atom(1).Mass;

        Syst.CFDComp(1).Qe      = 12;
        Syst.CFDComp(2).Qe      = 1;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        
        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-';

        Syst.MolToCFDComp       = [2];

        
        Syst.RxLxIdx = [ 2,-1;   % Diss
                         0, 0;   % Inel 
                         0, 0];  % Exch1

        %% Exchange Properties
        Syst.ExchToMol          = [];
        Syst.ExchToAtom         = [];        
        Syst.PairToExch         = [];

                     
%         Syst.RxLxIdx = [-2, 1;   % Diss
%                          0, 0;   % Inel
%                          0, 0];  % Exch1                        

%         %% Exchange Properties
%         Syst.ExchToMol          = [1];
%         Syst.ExchToAtom         = [3];
%         Syst.PairToExch         = [1];
        
        Syst.ToOtherExch        = []    ;
        
        Syst.ColPartToComp      = 2; 
        
        
    elseif strcmp(Syst.NameLong, 'O4_UMN')
        
        %%% System
        Syst.Name              = 'O4';

        Syst.NProc = 3; %(Diss+Inel+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 4;
        
        Syst.Atom(1).Name  = 'O';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'O';
        Syst.Atom(4).Name  = 'O';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 1];
        Syst.Atom(4).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 200;
        Syst.Atom(4).Size  = 200;

        Syst.Atom(1).Mass  = 15.9994e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = 15.9994e-3;
        Syst.Atom(4).Mass  = 15.9994e-3;

        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        Syst.Atom(4).MassQCT  = 25526.04298e0;
        
        %%% Molecules
        Syst.NMolecules                   = 1;
        Syst.Molecule(1).Name             = 'O2';
        %Syst.Molecule(1).DissEn           = -5.211;
        Syst.Molecule(1).DegeneracyFactor = [1/2, 1/2];
        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2.0;
        Syst.Molecule(1).NLevelsOrig      = 6115;
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(1).DiatPot          = 'O2_UMN';
        Syst.MolToOtherSyst(1)            = 0;
        
        Syst.OtherSyst_NameLong           = '';

        %%% Pairs
        Syst.Pair(1).Name  = 'O2';
        Syst.Pair(2).Name  = 'O2';
        Syst.Pair(3).Name  = 'O2';
        Syst.Pair(4).Name  = 'O2';
        Syst.Pair(5).Name  = 'O2';
        Syst.Pair(6).Name  = 'O2';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 1;
        Syst.Pair(3).ToMol = 1;
        Syst.Pair(4).ToMol = 1;
        Syst.Pair(5).ToMol = 1;
        Syst.Pair(6).ToMol = 1;

        Syst.Pair(1).Color = [17, 17, 17] ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;
        Syst.Pair(4).Color = [17, 17, 17] ./ 256;
        Syst.Pair(5).Color = [17, 17, 17] ./ 256;
        Syst.Pair(6).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  2;
        
        Syst.CFDComp(1).Name   = 'O';
        Syst.CFDComp(2).Name   = 'O2';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = 2.0 * Syst.Atom(1).Mass;

        Syst.CFDComp(1).Qe      = 9;
        Syst.CFDComp(2).Qe      = 3;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        
        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-';
        
        Syst.RxLxIdx = [ 2,-1;   % Diss
                         0, 0;   % Inel 
                         0, 0];  % Exch1
                        
        Syst.MolToCFDComp       = [2];

        
        %% Exchange Properties
        Syst.ExchToMol          = [1,1];
        Syst.ExchToAtom         = [1,1];
        
        Syst.PairToExch         = [1,1];
        
        Syst.ToOtherExch        = [0];
        
        Syst.ColPartToComp      = 2; 
        
    
    elseif strcmp(Syst.NameLong, 'OaObOcOd_UMN')
        
        %%% System
        Syst.Name              = 'O4';

        Syst.NProc = 3; %(Diss+Inel+Exch)
        
        %%% PESs
        Syst.PESName       = [string('PES1')];
        Syst.NPESs         = size(Syst.PESName,2);
        
        %%% Atoms
        Syst.NAtoms        = 4;
        
        Syst.Atom(1).Name  = 'O';
        Syst.Atom(2).Name  = 'O';
        Syst.Atom(3).Name  = 'O';
        Syst.Atom(4).Name  = 'O';

        Syst.Atom(1).Color = [0, 0, 1];
        Syst.Atom(2).Color = [0, 0, 1];
        Syst.Atom(3).Color = [0, 0, 1];
        Syst.Atom(4).Color = [0, 0, 1];

        Syst.Atom(1).Size  = 200;
        Syst.Atom(2).Size  = 200;
        Syst.Atom(3).Size  = 200;
        Syst.Atom(4).Size  = 200;

        Syst.Atom(1).Mass  = 15.9994e-3;
        Syst.Atom(2).Mass  = 15.9994e-3;
        Syst.Atom(3).Mass  = 15.9994e-3;
        Syst.Atom(4).Mass  = 15.9994e-3;
        
        Syst.Atom(1).MassQCT  = 25526.04298e0;
        Syst.Atom(2).MassQCT  = 25526.04298e0;
        Syst.Atom(3).MassQCT  = 25526.04298e0;
        Syst.Atom(4).MassQCT  = 25526.04298e0;
        
        %%% Molecules
        Syst.NMolecules                   = 6;
        Syst.Molecule(1).Name             = 'OaOb';
        %Syst.Molecule(1).DissEn           = -5.211;
        Syst.Molecule(1).DegeneracyFactor = [1/2, 1/2];
        Syst.Molecule(1).Mu               = Syst.Atom(1).Mass*2.0;
        Syst.Molecule(1).NLevelsOrig      = 6115;
        Syst.Molecule(1).ToAtoms          = [1,2];
        Syst.Molecule(1).DiatPot          = 'O2_UMN';
        Syst.MolToOtherSyst(1)            = 0;
        
        Syst.Molecule(2)                  = Syst.Molecule(1);
        Syst.Molecule(2).Name             = 'OaOc';
        Syst.Molecule(3)                  = Syst.Molecule(1);
        Syst.Molecule(3).Name             = 'OaOd';
        Syst.Molecule(4)                  = Syst.Molecule(1);
        Syst.Molecule(4).Name             = 'ObOc';
        Syst.Molecule(5)                  = Syst.Molecule(1);
        Syst.Molecule(5).Name             = 'ObOd';
        Syst.Molecule(6)                  = Syst.Molecule(1);
        Syst.Molecule(6).Name             = 'OcOd';
        
        
        Syst.OtherSyst_NameLong           = '';

        %%% Pairs
        Syst.Pair(1).Name  = 'O2';
        Syst.Pair(2).Name  = 'O2';
        Syst.Pair(3).Name  = 'O2';
        Syst.Pair(4).Name  = 'O2';
        Syst.Pair(5).Name  = 'O2';
        Syst.Pair(6).Name  = 'O2';

        Syst.Pair(1).ToMol = 1;
        Syst.Pair(2).ToMol = 2;
        Syst.Pair(3).ToMol = 3;
        Syst.Pair(4).ToMol = 4;
        Syst.Pair(5).ToMol = 5;
        Syst.Pair(6).ToMol = 6;

        Syst.Pair(1).Color = [17, 17, 17] ./ 256;
        Syst.Pair(2).Color = [17, 17, 17] ./ 256;
        Syst.Pair(3).Color = [17, 17, 17] ./ 256;
        Syst.Pair(4).Color = [17, 17, 17] ./ 256;
        Syst.Pair(5).Color = [17, 17, 17] ./ 256;
        Syst.Pair(6).Color = [17, 17, 17] ./ 256;

        
        %% CFD Components (For PLATO and KONIG)
        Syst.NComp             =  2;
        
        Syst.CFDComp(1).Name   = 'O';
        Syst.CFDComp(2).Name   = 'O2';

        Syst.CFDComp(1).ToMol   = 0;
        Syst.CFDComp(2).ToMol   = 1;

        Syst.CFDComp(1).Mass    = Syst.Atom(1).Mass;
        Syst.CFDComp(2).Mass    = 2.0 * Syst.Atom(1).Mass;

        Syst.CFDComp(1).Qe      = 9;
        Syst.CFDComp(2).Qe      = 3;

        Syst.CFDComp(1).Color   = [ 102, 102, 102] ./ 256;
        Syst.CFDComp(2).Color   = [   0,   0,   0] ./ 256;
        
        Syst.CFDComp(1).LineStyle = ':';
        Syst.CFDComp(2).LineStyle = '-';
        
        Syst.RxLxIdx = [ 2,-1;   % Diss
                         0, 0;   % Inel 
                         0, 0];  % Exch1
                        
        Syst.MolToCFDComp       = [2,2,2,2,2,2];

        
        %% Exchange Properties
        Syst.ExchToMol          = [1,6;2,5;3,4];
        Syst.ExchToAtom         = [1,2;1,3;1,4];
        
        Syst.PairToExch         = [1,2,3];
        
        Syst.ToOtherExch        = [0];
        
        Syst.ColPartToComp      = 2; 
    end
    
    Syst
    fprintf('====================================================\n\n')  

end