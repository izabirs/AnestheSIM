function BIS = bisMinto(CeP, CeR, p)
%BISMINTO Additive Minto interaction model.
%   BIS = E0 - Emax * S / (1 + S),  S = (CeP/C50P)^gammaP + (CeR/C50R)^gammaR
%   CeP [ug/mL], CeR [ng/mL], p from bisParameters. Vectorised.

Up = (max(CeP, 0) ./ p.Prop.C50) .^ p.Prop.gamma;
Ur = (max(CeR, 0) ./ p.Remi.C50) .^ p.Remi.gamma;
S = Up + Ur;
BIS = clampBIS(p.Interaction.E0 - p.Interaction.Emax .* S ./ (1 + S));
end
