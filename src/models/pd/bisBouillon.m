function BIS = bisBouillon(CeP, CeR, p)
%BISBOUILLON Bouillon interaction model (additive normalised potencies).
%   U = CeP/C50P + CeR/C50R,   BIS = E0 - Emax * U^gamma / (1 + U^gamma)
%   CeP [ug/mL], CeR [ng/mL], p from bisParameters. Vectorised.

U = max(CeP, 0) ./ p.Prop.C50 + max(CeR, 0) ./ p.Remi.C50;
BIS = clampBIS(p.Interaction.E0 - p.Interaction.Emax .* hill(U, p.Interaction.gamma));
end
