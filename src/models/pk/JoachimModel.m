function m = JoachimModel(patient)
%JOACHIMMODEL Covariate PK/PD model of norepinephrine (Joachim et al. 2024).
%   Joachim J. et al., Br J Clin Pharmacol 2024;90:2861-2869, doi:10.1111/bcp.16180.
%
%   PK (states: depot, central, peripheral amounts [nmol]):
%       Ad' = -ka Ad + I(t - Tlag)
%       Ac' =  ka Ad - (k12 + kel) Ac + k21 Ap
%       Ap' =  k12 Ac - k21 Ap
%       y   =  Ac / V1    exogenous plasma concentration [nmol/L]
%   with input I the norepinephrine mass rate [nmol/s]. The total plasma
%   concentration is Cc = y + Cendo.
%
%   PD, either the static Emax form (better BIC in the source paper)
%       MAP = E0 + Emax Cc^gamma / (Cc^gamma + EC50^gamma)
%   or the over-damped second-order (Windkessel) form
%       E'' + 2 zeta omega E' + omega^2 E = nu y.
%
%   Covariates enter as log(theta) = log(theta_pop) + beta log(c). Binary
%   covariates not available in VitalDB (smoking, hypertension) are set to
%   0; sex is coded 1 = male, 0 = female. The depot non-linearity
%   (beta = 1.21) is linearised (beta = 1).

age = patient.age;
weight = patient.weight;
lbm = patient.lbm;
bmi = patient.bmi;
male = double(patient.isMale());
smoking = 0;
hypertension = 0;

% Individual parameters (covariate model)
Cendo = exp(0.57 * log(age) + 0.67 * log(bmi) - 0.11 * hypertension - 4.56);  % nmol/L
kel   = exp(0.64 * log(lbm) - 5.52);                                         % 1/s
ka    = exp(-0.44 * smoking - 3.31);                                         % 1/s
Tlag  = exp(0.26 * male + 3.21);                                             % s
E0    = exp(-0.40 * log(age) + 5.61);                                        % mmHg
zeta  = exp(-0.62 * log(bmi) + 4.95);                                        % -
omega = exp(0.21 * log(weight) - 0.90);                                      % rad/s
Emax  = exp(-0.46 * male + 4.09);                                            % mmHg, effect amplitude

% Population parameters without covariates
V1    = 0.49;   % L
k12   = 0.06;   % 1/s
k21   = 0.04;   % 1/s
EC50  = 15.7;   % nmol/L
gamma = 1.46;
nu    = 2.12;   % mmHg L / (s^2 nmol)

m.A = [-ka,  0,            0;
        ka, -(k12 + kel),  k21;
        0,   k12,         -k21];
m.B = [1; 0; 0];
m.C = [0, 1 / V1, 0];
m.D = 0;

m.windkessel.A = [0, 1; -omega^2, -2 * zeta * omega];
m.windkessel.B = [0; nu];
m.windkessel.C = [1, 0];
m.windkessel.D = 0;

m.Tlag = Tlag;
m.Cendo = Cendo;
m.E0 = E0;
m.Emax = Emax;
m.EC50 = EC50;
m.gamma = gamma;
m.V1 = V1;
m.ka = ka;
m.kel = kel;
m.k12 = k12;
m.k21 = k21;
m.drug = 'norepinephrine';
m.inputUnit = 'nmol/s';
m.outputUnit = 'nmol/L';
end
