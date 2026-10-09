function BIS = bisGreco(CeP, CeR, p)
%BISGRECO Reduced Greco interaction model (intravenous agents only).
%   U = (CeP/C50P) (1 + CeR/C50R),   BIS = E0 - Emax * U^gamma / (1 + U^gamma)
%   CeP [ug/mL], CeR [ng/mL], p from bisParameters. Vectorised.

BIS = bisGrecoVolatile(CeP, CeR, 0, 0, p);
end
