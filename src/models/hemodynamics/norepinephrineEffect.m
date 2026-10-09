function dMAP = norepinephrineEffect(CcExo, nepi)
%NOREPINEPHRINEEFFECT MAP increase caused by exogenous norepinephrine (Joachim Emax).
%   dMAP = Emax(CcExo + Cendo) - Emax(Cendo), so that no infusion gives no
%   pressor effect. CcExo [nmol/L], nepi from JoachimModel. Vectorised.

total = max(CcExo, 0) + nepi.Cendo;
dMAP = emaxNE(total, nepi) - emaxNE(nepi.Cendo, nepi);
end

function E = emaxNE(Cc, nepi)
r = Cc .^ nepi.gamma;
E = nepi.Emax .* r ./ (r + nepi.EC50 ^ nepi.gamma);
end
