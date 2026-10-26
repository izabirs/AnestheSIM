# AnestheSIM

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23338918.svg)](https://doi.org/10.5281/zenodo.23338918)

**An open, extensible patient simulator for closed-loop anesthesia research and teaching, driven by VitalDB records (MATLAB/Simulink).**

AnestheSIM lets real intraoperative records, or designed dosing schedules, drive interchangeable
pharmacokinetic/pharmacodynamic (PK/PD) models of propofol, remifentanil, norepinephrine and
inhaled agents, and compares the simulated BIS, MAP and HR with what was measured. Clinical-data
acquisition is a native layer of the tool. Signals are requested by canonical name and device,
and a thin mapping translates them to repository channels. The same simulation core therefore
runs unchanged on VitalDB, on synthetic patients, or on any other database once its loader exists.

- **Database abstraction.** `TrackName`, `TrackSource`, `VitalSignal` and `DatabaseType` separate
  physiological quantities from device- and repository-specific channel names.
- **VitalDB acquisition.** Cases stream from the VitalDB API with local caching. A cohort can be
  searched from a signal specification.
- **Drugs.** Propofol, remifentanil and norepinephrine enter in pump units (mL/h). Sevoflurane and
  desflurane enter as end-tidal vol%, with automatic agent resolution from the Primus and
  Solar8000 gas analysers.
- **PK.** Schnider (propofol), Minto (remifentanil), Joachim covariate model (norepinephrine), and
  first-order volatile effect sites with Mapleson age adjustment.
- **PD.** Additive Minto, Bouillon and reduced Greco BIS surfaces run in parallel. A reduced Greco
  model covers intravenous–inhalational interaction. A turnover MAP/HR model and a unified
  propofol–remifentanil–norepinephrine MAP model complete the set.
- **Validation on real data.** One script re-derives a VitalDB cohort from its signal
  specification, replays every case through the simulator and reports Varvel performance
  metrics for BIS, MAP and HR.
- **Teaching.** Synthetic patients and designed dosing schedules run without internet access;
  every model is a short, documented MATLAB function next to its Simulink block.
- **Speed.** A 3-hour case simulates in under a second on a laptop.
- **Alarms.** Excursions beyond configurable safety limits are detected.

## Requirements

- MATLAB and Simulink, tested with R2025b. On other releases `setup_anesthesim` regenerates the
  Simulink model from `simulator/build_anesthesim_model.m`.
- Statistics and Machine Learning Toolbox, only for the statistical tests of `analyze_validation`
- Internet access for the first download of each VitalDB case (cached in `./cache` afterwards)

## Quick start

```matlab
setup_anesthesim      % paths; regenerates the Simulink model if needed
main                  % simulate VitalDB case 2809 end to end
run_tests             % unit tests, no internet needed
```

Simulating a case in a few lines:

```matlab
signals = vitaldbDefaultSignals('balanced');           % BIS, MAP, HR, propofol, remifentanil, gases
[patient, data] = loadPatientCase(DatabaseType.VitalDB, 2809, signals);
simIn = buildSimulationInputs(data);                    % common 1 s clock
res = runAnesthesim(patient, simIn, 'Data', data);      % Simulink patient model
plotSimulation(res, simIn);
```

`res` contains `BIS.minto`, `BIS.bouillon`, `BIS.greco` (intravenous agents only), `BIS.volatile`,
`MAP.separable`, `MAP.unified`, `HR` and all model concentrations, on the time grid `res.t`.

To test a controller, pass its commanded pump rates as `data.Propofol.infRate` (and so on) on a
synthetic patient. See [examples/example_synthetic_patient.m](examples/example_synthetic_patient.m).

## Examples

| Script | Content |
| --- | --- |
| [`main.m`](main.m) | One VitalDB case: acquisition, simulation, metrics, alarms |
| [`example_cohort_search.m`](examples/example_cohort_search.m) | Cohorts defined by a signal specification |
| [`example_bis_models.m`](examples/example_bis_models.m) | Minto / Bouillon / reduced Greco BIS on recorded infusions |
| [`example_balanced_case.m`](examples/example_balanced_case.m) | Balanced anesthesia: BIS with and without the inhaled agents |
| [`example_synthetic_patient.m`](examples/example_synthetic_patient.m) | Synthetic patient and designed dosing, no internet needed |
| [`study_validation.m`](examples/study_validation.m) | Replays a VitalDB cohort through the simulator (resumable) |
| [`analyze_validation.m`](examples/analyze_validation.m) | Validation tables, statistics and figures |
| [`study_agent_resolution.m`](examples/study_agent_resolution.m) | Blind check of the sevoflurane/desflurane resolution |
| [`reproduce_paper_figures.m`](examples/reproduce_paper_figures.m) | All results of the accompanying paper, written to `./results` |

## Architecture

```
 Database abstraction        TrackName · TrackSource · VitalSignal · DatabaseType      (database aware)
          │ canonical signal requests
 Acquisition & preprocessing loadPatientCase → vitaldbLoadCase → patientData
          │ Patient + canonical patientData        buildSimulationInputs (common clock)
 ─────────┼──────────────────────────── database boundary ─────────────────────────────────
 Patient & models            Patient · SchniderModel · MintoModel · JoachimModel · VolatileModel
          │ state-space PK, PD parameter structures (bisParameters, mapUnifiedParameters, ...)
 Simulation & output         simulator/anesthesim.slx · runAnesthesim · detectAlarms · plotting
```

```
src/
  database/        TrackName, TrackSource, VitalSignal, DatabaseType
    vitaldb/       VitalDB loader, cached downloads, volatile-agent resolution, searchPatients
    population/    synthetic patients (data/population)
  acquisition/     loadPatientCase, canonical patientData
  patient/         Patient (immutable demographics, BMI, James lean body mass)
  models/pk/       Schnider, Minto, Joachim, volatile effect sites
  models/pd/       BIS interaction models and parameter sets
  models/hemodynamics/  turnover MAP/HR, unified MAP, norepinephrine effect
  simulation/      model instantiation, inputs on the simulation clock, runAnesthesim
  validation/      BIS cleaning, Varvel performance metrics
  monitoring/      alarm limits and detection
  plotting/
simulator/         build_anesthesim_model.m and the generated anesthesim.slx
examples/   tests/   data/
```

The PD equations live in one place, `src/models`: the Simulink MATLAB Function blocks call the
same functions that are available at the command line, and `simulateLTI` integrates the same
state-space matrices as the Simulink State-Space blocks. The test suite checks that both agree.

### Pharmacological models

| Block | Model | Input → output |
| --- | --- | --- |
| Propofol PK | Schnider 1998, ke0 = 1.21 min⁻¹ (Orchestra/Marsh) | mL/h → mg/s → Cp, Ce [µg/mL] |
| Remifentanil PK | Minto 1997, age-dependent ke0 | mL/h → µg/s → Cp, Ce [ng/mL] |
| Norepinephrine PK/PD | Joachim 2024 covariate model, transport lag, Emax or Windkessel | mL/h → nmol/s → C [nmol/L] |
| Volatile effect site | first order, ke0 = 0.47 min⁻¹; C50 = C50,40 · 10^(−0.00269 (age−40)) | Et [vol%] → Ce [vol%] |
| BIS (IV) | additive Minto, Bouillon 2004, reduced Greco (in parallel) | Ce → BIS |
| BIS (IV + volatiles) | U = (U_prop + U_sevo + U_des)(1 + U_remi), BIS = E0 − Emax·U^γ/(1+U^γ) | Ce → BIS |
| MAP / HR, separable | Garraza-Obaldia 2024 turnover model + Joachim norepinephrine pressor effect | Cp, C_NE → MAP, HR |
| MAP, unified | C50P,eff = C50P (1 − kR·CeR/(CeR + C50R)); MAP = MAP0 − E_P + E_NE | Ce, C_NE → MAP |

In every BIS model `Emax` is the maximal BIS decrease, so BIS tends to `E0 − Emax`. All models use
published parameters, except the unified MAP structure, whose propofol/remifentanil values are
illustrative and meant to be replaced by the user's own.

## Extending AnestheSIM

- **Add a database.** Write a loader that returns a `Patient` and the canonical structure of
  `emptyPatientData`, add a member to `DatabaseType`, and add a case to `loadPatientCase`.
  Nothing in the models or the Simulink core changes.
- **Add a drug or signal.** Add a `TrackName` (and a `TrackSource` for a new device), extend
  `VitalSignal.channelStrings`, and map the channel in `vitaldbToCanonical`. Then add its PK/PD
  block in `build_anesthesim_model`. The volatile-agent channels are a worked example.
- **Add a PK/PD model.** Provide a state-space constructor (PK) or a function plus parameter
  structure (PD), wire it in `build_anesthesim_model`, and pass its parameters in `runAnesthesim`.

## Data

AnestheSIM uses only the public, de-identified records of the
[VitalDB](https://vitaldb.net) open dataset. Records are downloaded on demand and are not
redistributed with this repository. Use of VitalDB data is governed by the VitalDB data-use terms.
Please cite: Lee H.-C. et al., *VitalDB, a high-fidelity multi-parameter vital signs database in
surgical patients*, Scientific Data 9, 279 (2022).

`data/population` contains synthetic demographic records only.

## Citation

If you use AnestheSIM, please cite the software:

> Birs, I. (2026). *AnestheSIM: an open, extensible patient simulator for closed-loop anesthesia
> driven by VitalDB records*. Zenodo. https://doi.org/10.5281/zenodo.23338918

This DOI always resolves to the latest release. The DOI of each release is listed on
[Zenodo](https://doi.org/10.5281/zenodo.23338918), and the metadata are in [`CITATION.cff`](CITATION.cff).

## License

[MIT](LICENSE) © 2026 Isabela Birs
