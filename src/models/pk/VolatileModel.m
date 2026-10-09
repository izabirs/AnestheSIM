function m = VolatileModel(agent, patient)
%VOLATILEMODEL Effect-site model and age-adjusted potency of a volatile agent.
%   m = VolatileModel('sevoflurane', patient)
%   m = VolatileModel('desflurane', patient)
%
%   End-tidal concentration Et [vol%] drives a first-order effect site
%       Ce' = ke0 (Et - Ce),  ke0 = 0.47 min^-1,
%   and the BIS half-effect concentration is adjusted for age (Mapleson 1996)
%       C50(age) = C50_40 * 10^(-0.00269 (age - 40)).
%
%   Sevoflurane: C50_40 = 1.2 vol%. Desflurane has no BIS C50 in the
%   shipped literature set; it is obtained from the sevoflurane value
%   scaled by the MAC40 ratio of the two agents (6.6 / 1.8, Mapleson 1996).
%   The same ke0 is assumed for both agents. Replace these with
%   agent-specific estimates where available.

AGE_DECAY = -0.00269;  % 1/year
C50_SEVO_40 = 1.2;     % vol%

switch lower(agent)
    case {'sevoflurane', 'sevo'}
        C50_40 = C50_SEVO_40;
        m.agent = 'sevoflurane';
    case {'desflurane', 'des'}
        C50_40 = C50_SEVO_40 * 6.6 / 1.8;
        m.agent = 'desflurane';
    otherwise
        error('anesthesim:VolatileModel:unknownAgent', 'Unknown volatile agent "%s".', agent);
end

ke0 = 0.47 / 60;  % 1/s
m.A = -ke0;
m.B = ke0;
m.C = 1;
m.D = 0;
m.ke0 = ke0;
m.C50_40 = C50_40;
m.C50 = C50_40 * 10^(AGE_DECAY * (patient.age - 40));
m.gamma = 3;
end
