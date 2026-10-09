function MAP = mapUnified(CeP, CeR, CcN, p)
%MAPUNIFIED Unified propofol-remifentanil-norepinephrine MAP model.
%   Remifentanil shifts the propofol half-effect concentration,
%       C50P_eff = C50P (1 - kR CeR / (CeR + C50R)),
%       E_P  = EmaxP CeP / (CeP + C50P_eff),
%       E_NE = EmaxNE r / (1 + r),  r = (CcN / EC50NE)^gammaNE,
%       MAP  = MAP0 - E_P + E_NE.
%   CeP [ug/mL], CeR [ng/mL], CcN exogenous NE plasma concentration
%   [nmol/L]; p from mapUnifiedParameters. Vectorised.

CeP = max(CeP, 0);
CeR = max(CeR, 0);
CcN = max(CcN, 0);

C50eff = max(p.C50P .* (1 - p.kR .* CeR ./ (CeR + p.C50R)), 1e-6);
EP = p.EmaxP .* CeP ./ (CeP + C50eff);
r = (CcN ./ p.EC50NE) .^ p.gammaNE;
ENE = p.EmaxNE .* r ./ (1 + r);
MAP = p.MAP0 - EP + ENE;
end
