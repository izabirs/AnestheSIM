%% Cohort search from a signal specification
% A study cohort is defined by the canonical signals it needs, not by a
% hand-curated case list, so it can be re-derived on a refreshed database.

setup_anesthesim;

% Balanced anaesthesia: BIS, MAP, HR, propofol, remifentanil, sevoflurane and total gas
balanced = searchPatients(vitaldbDefaultSignals('balanced'));

% Haemodynamics with vasopressor: invasive MAP (EV1000), propofol, remifentanil, norepinephrine
hemodynamic = searchPatients(vitaldbDefaultSignals('map'));

% A custom specification
custom = [VitalSignal(TrackName.BIS,    TrackSource.BIS), ...
          VitalSignal(TrackName.PROP20, TrackSource.ORCHESTRA), ...
          VitalSignal(TrackName.REMI50, TrackSource.ORCHESTRA), ...
          VitalSignal(TrackName.DES,    TrackSource.PRIMUS)];
desflurane = searchPatients(custom);

disp(hemodynamic');
