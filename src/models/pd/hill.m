function e = hill(U, gamma)
%HILL Normalised sigmoid U^gamma / (1 + U^gamma) for U >= 0.

Ug = max(U, 0) .^ gamma;
e = Ug ./ (1 + Ug);
end
