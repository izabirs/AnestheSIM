%% Reproduce the results of the AnestheSIM paper
% Validation of the simulator on the VitalDB cohort, the agent-resolution
% check, and the example figures; everything is written to ./results.
% The first run downloads the required VitalDB tracks (about an hour);
% later runs use the local cache.

setup_anesthesim;
study_validation;
study_hemodynamic_sensitivity;
analyze_validation;
study_agent_resolution;
example_bis_models;
example_balanced_case;
example_synthetic_patient;
