function tests = testAlarms
tests = functiontests(localfunctions);
end

function testEpisodesDetected(tc)
t = (0:1:600)';
bis = 50 * ones(size(t));
bis(t >= 100 & t < 250) = 30;      % 150 s too deep
bis(t >= 400 & t < 430) = 70;      % 30 s too light: shorter than minDuration
ev = detectAlarms(t, struct('BIS', bis));
tc.verifyEqual(height(ev), 1);
tc.verifyEqual(ev.Signal, "BIS");
tc.verifyEqual(ev.Type, "low");
tc.verifyEqual([ev.Start, ev.Stop], [100, 249]);
tc.verifyEqual(ev.Extreme, 30);
end

function testCustomLimitsAndUnknownSignals(tc)
t = (0:1:300)';
L = alarmLimits();
L.MAP = [70 100];
L.minDuration = 10;
ev = detectAlarms(t, struct('MAP', 68 * ones(size(t)), 'Other', zeros(size(t))), L);
tc.verifyEqual(height(ev), 1);
tc.verifyEqual(ev.Duration, 300);
none = detectAlarms(t, struct('HR', 70 * ones(size(t))));
tc.verifyEmpty(none);
end
