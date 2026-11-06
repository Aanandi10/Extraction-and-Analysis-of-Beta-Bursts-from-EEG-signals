# Extraction and Analysis of Beta Bursts from EEG Signals

A MATLAB-based pipeline for the extraction, detection, and analysis of beta bursts in electroencephalography (EEG) signals.

## Overview

Beta bursts are transient increases in beta-band neural activity (13–30 Hz) that are associated with sensorimotor processing and movement control. Studying their temporal and spectral characteristics can provide insights into the neural mechanisms underlying human movement.

This project implements a MATLAB-based signal processing pipeline to identify and analyse beta bursts from EEG recordings. It combines beta-band filtering, Hilbert transform-based amplitude envelope extraction, threshold-based burst detection, spectral analysis, and time-frequency visualisation.

The project was developed as part of the **Summer Research Fellowship Programme (SRFP) 2025** at the Centre for Neuroscience, Indian Institute of Science (IISc), Bengaluru.

## Objectives

- Extract beta-band activity from EEG recordings.
- Estimate the instantaneous amplitude envelope of beta oscillations.
- Detect beta bursts using an amplitude-based thresholding approach.
- Quantify burst characteristics, including onset, duration, peak amplitude, and peak power.
- Examine the spectral properties of beta activity.
- Investigate temporal variations in beta burst activity.
- Visualise neural activity using time-frequency representations.

## Methodology

The analysis pipeline consists of the following stages:

### 1. EEG Data Loading and Preprocessing

The pipeline loads EEG recordings stored in MATLAB `.mat` format. The EEG data are expected to contain signal information, sampling frequency, and channel information.

### 2. Beta-Band Filtering

A sixth-order Butterworth IIR bandpass filter is applied to extract beta-band activity between **13 and 30 Hz**. Zero-phase filtering is performed using MATLAB's `filtfilt` function.

### 3. Amplitude Envelope Extraction

The Hilbert transform is used to estimate the instantaneous amplitude envelope of the filtered beta signal:

\[
A(t)=|\mathcal{H}(x(t))|
\]

where \(x(t)\) represents the filtered EEG signal and \(\mathcal{H}\) denotes the analytic signal obtained through the Hilbert transform.

### 4. Beta Burst Detection

Beta bursts are identified using a global amplitude threshold calculated as:

\[
T = \operatorname{median}(A)+1.5\times\operatorname{std}(A)
\]

Periods during which the amplitude envelope exceeds the threshold are identified as candidate bursts. A minimum burst duration of 10 ms is used.

### 5. Burst Feature Extraction

The detected bursts are characterised using the following features:

- Burst onset
- Burst duration
- Peak amplitude
- Peak power

### 6. Spectral Analysis

Frequency-domain characteristics are investigated using:

- Fast Fourier Transform (FFT)
- Welch's Power Spectral Density (PSD) estimation

### 7. Time-Frequency Analysis

Short-Time Fourier Transform (STFT)-based visualisations are used to examine the temporal evolution of EEG frequency components, including beta-band activity.

## Key Analysis Parameters

| Parameter | Value |
|---|---:|
| Beta-band frequency | 13–30 Hz |
| Filter type | Butterworth IIR |
| Filter order | 6 |
| Threshold | Median + 1.5 × Standard Deviation |
| Minimum burst duration | 10 ms |
| PSD window length | 1000 samples |
| PSD overlap | 500 samples |
| FFT length (PSD) | 4096 |
| STFT window length | 510 samples |
| STFT overlap | 255 samples |
| STFT FFT length | 1024 |

## Requirements

- MATLAB
- Signal Processing Toolbox

The implementation uses MATLAB signal processing functions for filtering, Hilbert transform-based envelope estimation, spectral analysis, and time-frequency visualisation.

## Dataset Description

The script is designed to work with EEG data stored in MATLAB `.mat` format.

The expected EEG structure contains:

- `EEG.data` – EEG recordings arranged as channels × time points × trials.
- `EEG.srate` – Sampling frequency of the recordings.
- `EEG.chanlocs` – Channel location information.

**Note:** The original EEG dataset is not included in this repository. Users must provide their own compatible dataset and ensure that they have permission to use it.

## How to Run

1. Clone or download this repository.
2. Open MATLAB.
3. Ensure that the required Signal Processing Toolbox is available.
4. Place your EEG dataset in an accessible local directory.
5. Update the local dataset path in the MATLAB script to point to your own `.mat` file.
6. Run `finalcode_betaburst.m`.

The script uses a local Windows file path in its current version, so this path must be adjusted when running the code on another system.

## Results and Visualisations

The analysis pipeline generates visualisations to examine different aspects of beta activity, including:

- Raw EEG signals
- Filtered beta-band signals
- Hilbert amplitude envelopes
- Detected beta burst periods
- FFT and power spectral density plots
- Temporal variations in burst amplitude
- STFT-based time-frequency representations

Representative output figures can be added to the `results/figures/` directory.

## Repository Structure

```text
Extraction-and-Analysis-of-Beta-Bursts-from-EEG-signals/
│
├── README.md
├── finalcode_betaburst.m
├── CITATION.cff
│
├── docs/
│   ├── methodology.md
│   ├── parameters.md
│   └── data_description.md
```

## Scientific Context

Beta oscillations in the sensorimotor system are closely associated with movement preparation and execution. Analysing beta bursts, rather than relying exclusively on average beta power, allows transient neural events to be investigated in terms of their timing, duration, and amplitude.

This project focuses on computational approaches for extracting and characterising these transient events from EEG recordings, with an emphasis on understanding beta activity in the context of human movement.

## Acknowledgements

This work was carried out as part of the **Summer Research Fellowship Programme (SRFP) 2025** at the **Centre for Neuroscience, Indian Institute of Science (IISc), Bengaluru**, under the supervision of **Prof. Aditya Murthy**.

## Author

**Anandi Banerjee**

Student Researcher  
Research interests: Computational Neuroscience, EEG Signal Processing, Neural Oscillations, and Machine Learning.

---

If you use this repository in your research, please cite it using the citation information provided in [`CITATION.cff`](CITATION.cff).
