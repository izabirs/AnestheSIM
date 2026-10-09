function m = threeCompartmentModel(V1, V2, V3, Cl1, Cl2, Cl3, ke0)
%THREECOMPARTMENTMODEL Mammillary 3-compartment PK plus first-order effect site.
%   Volumes in L, clearances in L/min, ke0 in 1/s. The returned state-space
%   model has states [C1; C2; C3; Ce], input mass rate, outputs [Cp; Ce].

k10 = Cl1 / V1 / 60;
k12 = Cl2 / V1 / 60;
k13 = Cl3 / V1 / 60;
k21 = Cl2 / V2 / 60;
k31 = Cl3 / V3 / 60;

A = [-(k10 + k12 + k13), k21,  k31,  0;
      k12,              -k21,  0,    0;
      k13,               0,   -k31,  0;
      ke0,               0,    0,   -ke0];
B = [1 / V1; 0; 0; 0];
C = [1 0 0 0;
     0 0 0 1];
D = [0; 0];

m = struct('A', A, 'B', B, 'C', C, 'D', D, ...
    'V1', V1, 'V2', V2, 'V3', V3, 'Cl1', Cl1, 'Cl2', Cl2, 'Cl3', Cl3, ...
    'k10', k10, 'k12', k12, 'k13', k13, 'k21', k21, 'k31', k31, 'ke0', ke0);
end
