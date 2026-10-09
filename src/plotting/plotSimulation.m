function fig = plotSimulation(res, simIn, titleText)
%PLOTSIMULATION Overview of one simulation: inputs, BIS, MAP and HR.
%   Recorded signals (grey) are shown when they are available. MAP is the
%   literature-parameterised separable model; the unified structure
%   (res.MAP.unified) has illustrative parameters and is not drawn.

if nargin < 3
    titleText = '';
end
fig = figure('Color', 'w', 'Position', [100 100 900 800]);
tm = res.t / 60;
grey = [0.7 0.7 0.7];

ax(1) = subplot(4, 1, 1);
yyaxis left
stairs(tm, simIn.u.prop.Data, 'LineWidth', 1.2); hold on
stairs(tm, simIn.u.remi.Data, '--', 'LineWidth', 1.2);
stairs(tm, simIn.u.nepi.Data, ':', 'LineWidth', 1.4); hold off
ylabel('Pump rate (mL/h)');
yyaxis right
plot(tm, simIn.u.sevo.Data, '-', tm, simIn.u.des.Data, '-.', 'LineWidth', 1.2);
ylabel('Et (vol%)');
legend({'Propofol', 'Remifentanil', 'Norepinephrine', 'Sevoflurane', 'Desflurane'}, ...
    'Location', 'eastoutside');
title(titleText);
grid on

map = simIn.meas.MAP;
map(map < 20 | map > 200) = NaN;   % arterial-line artifacts (flushing, sampling)

ax(2) = subplot(4, 1, 2);
panel(tm, simIn.meas.BIS, {res.BIS.greco, res.BIS.volatile}, ...
    {'IV only (reduced Greco)', 'IV + volatiles'}, grey);
ylim([0 100]);
ylabel('BIS');

ax(3) = subplot(4, 1, 3);
panel(tm, map, {res.MAP.separable}, {'Model'}, grey);
ylabel('MAP (mmHg)');

ax(4) = subplot(4, 1, 4);
panel(tm, simIn.meas.HR, {res.HR}, {'Model'}, grey);
ylabel('HR (bpm)');
xlabel('Time (min)');

linkaxes(ax, 'x');
xlim(ax(1), [0 tm(end)]);
end

function panel(tm, measured, models, names, grey)
labels = {};
if any(isfinite(measured))
    plot(tm, measured, 'Color', grey); hold on
    labels{end + 1} = 'Measured';
end
for k = 1:numel(models)
    plot(tm, models{k}, 'LineWidth', 1.3); hold on
end
hold off
legend([labels, names], 'Location', 'eastoutside');
grid on
end
