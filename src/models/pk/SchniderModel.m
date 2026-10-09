function m = SchniderModel(patient, ke0)
%SCHNIDERMODEL Three-compartment propofol PK (Schnider 1998) with effect site.
%   m = SchniderModel(patient) returns the continuous state-space model
%       x' = A x + B u,  y = C x,   u: propofol mass rate [mg/s]
%       x = [C1; C2; C3; Ce],       y = [Cp; Ce] [ug/mL]
%   and its parameters. Rate constants are per second.
%
%   ke0 defaults to 1.21 min^-1 (Marsh value used by Orchestra TCI pumps)
%   instead of the original Schnider 0.456 min^-1.

if nargin < 2
    ke0 = 1.21 / 60;  % 1/s
end

age = patient.age;
weight = patient.weight;
height = patient.height;
lbm = patient.lbm;

% Volumes [L]
V1 = 4.27;
V2 = 18.9 - 0.391 * (age - 53);
V3 = 238;

% Clearances [L/min]
Cl1 = 1.89 + 0.0456 * (weight - 77) - 0.0681 * (lbm - 59) + 0.0264 * (height - 177);
Cl2 = 1.29 - 0.024 * (age - 53);
Cl3 = 0.836;

m = threeCompartmentModel(V1, V2, V3, Cl1, Cl2, Cl3, ke0);
m.drug = 'propofol';
m.inputUnit = 'mg/s';
m.outputUnit = 'ug/mL';
end
