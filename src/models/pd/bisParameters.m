function p = bisParameters(model, patient)
%BISPARAMETERS Default (literature) parameter set of a BIS interaction model.
%   p = bisParameters('greco' | 'bouillon' | 'minto', patient)
%
%   All models share one parameter structure:
%       p.Prop.C50 [ug/mL], p.Prop.gamma
%       p.Remi.C50 [ng/mL], p.Remi.gamma
%       p.Sevo.C50, p.Des.C50 [vol%]  age-adjusted (VolatileModel)
%       p.Interaction.E0    baseline BIS
%       p.Interaction.Emax  maximal BIS decrease (BIS -> E0 - Emax)
%       p.Interaction.gamma steepness of the combined potency
%   so the same Simulink wiring accepts any of them, and user-supplied
%   parameter sets drop in unchanged.

if nargin < 2 || isempty(patient)
    patient = Patient(0, 40, 170, 70, 'M');  % reference 40-year-old
end

switch lower(model)
    case 'greco'        % reduced Greco
        prop = [3.34, 1.2];
        remi = [2.41, 1.2];
        E0 = 95; Emax = 70; gamma = 1.2;
    case 'bouillon'     % Bouillon et al. 2004, BIS (additive, beta = 0)
        prop = [4.47, 1.43];
        remi = [19.3, 1.43];
        E0 = 97.4; Emax = 97.4; gamma = 1.43;
    case 'minto'        % Minto et al. 2000, additive
        prop = [3.35, 1.58];
        remi = [7.96, 7.85];
        E0 = 93; Emax = 83; gamma = 1.0;   % per-drug slopes are used
    otherwise
        error('anesthesim:bisParameters:unknownModel', 'Unknown BIS model "%s".', model);
end

sevo = VolatileModel('sevoflurane', patient);
des = VolatileModel('desflurane', patient);

p.Prop = struct('C50', prop(1), 'gamma', prop(2));
p.Remi = struct('C50', remi(1), 'gamma', remi(2));
p.Sevo = struct('C50', sevo.C50, 'gamma', sevo.gamma);
p.Des = struct('C50', des.C50, 'gamma', des.gamma);
p.Interaction = struct('E0', E0, 'Emax', Emax, 'gamma', gamma);
end
