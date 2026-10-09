function p = mapUnifiedParameters(MAP0, nepi)
%MAPUNIFIEDPARAMETERS Nominal parameters of the unified three-drug MAP model.
%   p = mapUnifiedParameters(MAP0, nepiModel)
%
%   The unified structure has no published parameter set: the propofol and
%   remifentanil values below are illustrative and should be replaced by
%   the user's own estimates. The norepinephrine term defaults to the
%   Joachim Emax model, so the pressor response equals the published
%   population model.

if nargin < 1 || isempty(MAP0)
    MAP0 = 85;
end

p.MAP0   = MAP0;   % mmHg
p.EmaxP  = 30;     % mmHg, maximal propofol depression
p.C50P   = 2.0;    % ug/mL
p.kR     = 0.5;    % remifentanil shift of the propofol C50 (0 <= kR < 1)
p.C50R   = 2.0;    % ng/mL
if nargin >= 2 && ~isempty(nepi)
    p.EmaxNE = nepi.Emax;    % mmHg
    p.EC50NE = nepi.EC50;    % nmol/L
    p.gammaNE = nepi.gamma;
else
    p.EmaxNE = 59.7;
    p.EC50NE = 15.7;
    p.gammaNE = 1.46;
end
end
