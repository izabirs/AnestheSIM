function y = simulateLTI(m, u, Ts, delay)
%SIMULATELTI Simulate a continuous state-space model on a uniform grid.
%   y = simulateLTI(m, u, Ts) integrates x' = A x + B u, y = C x + D u
%   exactly for piecewise-constant input samples u (N-by-1) with step Ts,
%   starting from rest. y is N-by-ny. An optional input delay [s] is
%   applied by shifting the input (rounded to the grid).
%
%   This is the offline counterpart of the Simulink State-Space blocks, for
%   fast analyses that need the concentrations without running Simulink.

if nargin < 4
    delay = 0;
end
u = double(u(:));
u(~isfinite(u)) = 0;
shift = round(delay / Ts);
if shift > 0
    u = [zeros(shift, 1); u(1:end - shift)];
end

n = size(m.A, 1);
M = expm([m.A, m.B; zeros(1, n + 1)] * Ts);
Ad = M(1:n, 1:n);
Bd = M(1:n, n + 1);

N = numel(u);
X = zeros(n, N);
x = zeros(n, 1);
for k = 1:N
    X(:, k) = x;
    x = Ad * x + Bd * u(k);
end
y = (m.C * X + m.D * u')';
end
