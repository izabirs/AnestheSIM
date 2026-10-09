function p = hemodynamicParameters(MAP0, HR0)
%HEMODYNAMICPARAMETERS Turnover model of MAP and HR under propofol and remifentanil.
%   Final-model bootstrap medians of Garraza-Obaldia M. et al.,
%   "Pharmacodynamic Model of the Hemodynamic Effects of Propofol and
%   Remifentanil and Their Interaction with Noxious Stimulation",
%   Pharmaceutics 2024;16:1615, doi:10.3390/pharmaceutics16121615.
%
%   MAP0 [mmHg] and HR0 [bpm] are the patient baselines (see
%   estimateBaselines); the published HR0 = 70.8 bpm is the default.

if nargin < 1 || isempty(MAP0)
    MAP0 = 100;
end
if nargin < 2 || isempty(HR0)
    HR0 = 70.8;
end

p.C50P  = 7.38;          % ug/mL, propofol plasma concentration
p.EmaxP = 0.77;          % fractional MAP production inhibition
p.C50R  = 3.63;          % ng/mL, remifentanil plasma concentration
p.gammaR = 1.37;
p.EmaxR = 0.65;          % fractional HR production inhibition
p.kout  = 0.126 / 60;    % 1/s
p.Stim  = 0.277;         % relative stimulation amplitude
p.kStim = 0.018 / 60;    % 1/s, stimulation decay
p.tStim = 0;             % s, onset of noxious stimulation
p.FBhr  = 0.842;         % HR -> MAP feedback exponent
p.MAP0  = MAP0;
p.HR0   = HR0;
end
