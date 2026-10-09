function BIS = bisGrecoVolatile(CeP, CeR, CeSevo, CeDes, p)
%BISGRECOVOLATILE Reduced Greco model extended with volatile agents.
%   Propofol and the volatile agents are GABAergic hypnotics whose
%   normalised potencies add; remifentanil potentiates the combined
%   hypnotic drive multiplicatively:
%
%       U = (CeP/C50P + CeSevo/C50Sevo + CeDes/C50Des) (1 + CeR/C50R)
%       BIS = E0 - Emax * U^gamma / (1 + U^gamma),   clamped to [0, 100]
%
%   CeP [ug/mL], CeR [ng/mL], CeSevo/CeDes [vol%], p from bisParameters.
%   With no volatile agent this is exactly bisGreco. Vectorised.

Uh = max(CeP, 0) ./ p.Prop.C50 + max(CeSevo, 0) ./ p.Sevo.C50 + max(CeDes, 0) ./ p.Des.C50;
U = Uh .* (1 + max(CeR, 0) ./ p.Remi.C50);
BIS = clampBIS(p.Interaction.E0 - p.Interaction.Emax .* hill(U, p.Interaction.gamma));
end
