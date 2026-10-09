function m = MintoModel(patient)
%MINTOMODEL Three-compartment remifentanil PK (Minto 1997) with effect site.
%   m = MintoModel(patient) returns the continuous state-space model
%       x = [C1; C2; C3; Ce],   u: remifentanil mass rate [ug/s],
%       y = [Cp; Ce] [ng/mL]
%   with the age-dependent ke0 = 0.595 - 0.007 (age - 40) min^-1.

age = patient.age;
lbm = patient.lbm;

% Volumes [L]
V1 = 5.1 - 0.0201 * (age - 40) + 0.072 * (lbm - 55);
V2 = 9.82 - 0.0811 * (age - 40) + 0.108 * (lbm - 55);
V3 = 5.42;

% Clearances [L/min]
Cl1 = 2.6 - 0.0162 * (age - 40) + 0.0191 * (lbm - 55);
Cl2 = 2.05 - 0.0301 * (age - 40);
Cl3 = 0.076 - 0.00113 * (age - 40);

ke0 = (0.595 - 0.007 * (age - 40)) / 60;  % 1/s

m = threeCompartmentModel(V1, V2, V3, Cl1, Cl2, Cl3, ke0);
m.drug = 'remifentanil';
m.inputUnit = 'ug/s';
m.outputUnit = 'ng/mL';
end
