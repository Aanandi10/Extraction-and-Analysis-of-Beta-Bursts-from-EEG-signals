# Extraction-and-Analysis-of-Beta-Bursts-from-EEG-signals

# Extraction and Analysis of Beta Bursts from EEG Signals

A MATLAB-based signal processing pipeline for the extraction, detection, and analysis of beta bursts from electroencephalography (EEG) signals.

The project investigates transient beta-band oscillatory activity through signal filtering, amplitude envelope extraction, threshold-based burst detection, spectral analysis, and time-frequency visualisation.

## Overview

Beta oscillations (13–30 Hz) are associated with sensorimotor processing and the regulation of voluntary movement. Rather than occurring continuously, beta activity can appear as brief, transient high-amplitude events known as **beta bursts**.

This project implements a computational pipeline to identify and characterise beta bursts in EEG recordings and investigate their temporal and spectral properties.

## Objectives

- Extract beta-band activity from raw EEG recordings.
- Estimate the instantaneous amplitude envelope using the Hilbert transform.
- Implement global threshold-based beta burst detection.
- Quantify burst characteristics, including onset, duration, peak amplitude, and peak power.
- Examine temporal variations in burst peak amplitude.
- Perform frequency-domain and time-frequency analysis using FFT, PSD, and Short-Time Fourier Transform (STFT).

## Methodology

The analysis pipeline consists of the following stages:

### 1. EEG Data Loading and Inspection

EEG recordings are loaded from MATLAB `.mat` files. The pipeline examines the number of channels, time points, trials, and sampling frequency.

The expected data structure is an EEGLAB-style structure containing:

- `EEG.data`: EEG recordings arranged as channels × time points × trials.
- `EEG.srate`: Sampling frequency in Hz.
- `EEG.chanlocs`: Channel information and labels.

### 2. Beta-Band Filtering

A sixth-order Butterworth IIR bandpass filter is designed to extract beta-band activity between 13 and 30 Hz.

Zero-phase filtering is performed using MATLAB's `filtfilt` function to avoid phase distortion.

### 3. Amplitude Envelope Extraction

The Hilbert transform is applied to the filtered EEG signal to obtain its analytic representation.

The instantaneous amplitude envelope is calculated as:

\[
A(t)=|\mathcal{H}(x_\beta(t))|
\]

where \(x_\beta(t)\) is the beta-filtered EEG signal and \(\mathcal{H}\) denotes the analytic signal obtained using the Hilbert transform.

### 4. Global Threshold Estimation

A global amplitude threshold is calculated using the median and standard deviation of the amplitude envelopes across channels and trials:

\[
T = \operatorname{median}(A) + k \cdot \operatorname{std}(A)
\]

The implementation uses:

- Threshold multiplier: \(k=1.5\)
- Minimum burst duration: 10 ms

### 5. Beta Burst Detection and Feature Extraction

A beta burst is identified when the amplitude envelope exceeds the global threshold for at least the specified minimum duration.

The following features are extracted:

- Burst onset time
- Burst duration
- Peak amplitude
- Peak power

### 6. Temporal Trend Analysis

Burst peak amplitudes are examined as a function of time.

The implementation includes trial-wise and combined-trial visualisations, with linear trend fitting to examine temporal patterns.

### 7. Spectral Analysis

The pipeline includes:

- Fast Fourier Transform (FFT) for frequency-domain analysis.
- Welch's Power Spectral Density (PSD) estimation.
- Short-Time Fourier Transform (STFT) for time-frequency analysis.
- Beta-band and broader frequency-range spectrogram visualisations.

## Analysis Parameters

| Parameter | Value |
|---|---|
| Beta frequency range | 13–30 Hz |
| Filter type | Butterworth IIR |
| Filter order | 6 |
| Filtering method | Zero-phase (`filtfilt`) |
| Envelope extraction | Hilbert transform |
| Threshold method | Median + k × SD |
| Threshold multiplier | 1.5 |
| Minimum burst duration | 10 ms |
| STFT window length | 510 samples |
| STFT overlap | 50% |
| STFT FFT length | 1024 |

Note: The beta-band STFT visualisation in the current implementation uses an 8–30 Hz display range. This is distinct from the 13–30 Hz filtering range.

## Requirements

- MATLAB
- Signal Processing Toolbox

The implementation uses MATLAB functions including `designfilt`, `filtfilt`, `hilbert`, `pwelch`, and `stft`.

The MATLAB release used for development and testing will be specified after verification.

## Dataset

The original EEG recordings are not distributed with this repository.

To run the analysis, provide an appropriately structured EEG `.mat` file containing the required EEG variables.

Please ensure that you have the necessary permissions to use and analyse your EEG data.

## How to Run

1. Clone or download this repository.
2. Open MATLAB.
3. Navigate to the project directory.
4. Add the `src` directory and its subdirectories to the MATLAB path.
5. Provide the path to your EEG dataset.
6. Run the main analysis script.
7. Select the channels and trials for analysis when prompted.

```matlab
addpath(genpath('src'));
run('src/main.m');
```

The dataset path and configuration should be updated according to your local environment.

## Outputs

The pipeline generates visualisations and analysis outputs including:

- Raw EEG signal plots.
- Beta-filtered EEG signals.
- Raw versus filtered signal comparisons.
- Power Spectral Density plots.
- FFT amplitude spectra.
- Beta amplitude envelope visualisations.
- Threshold-based beta burst detection plots.
- Burst feature summaries.
- Temporal burst amplitude trends.
- Beta-band STFT spectrograms.
- Broader frequency-range spectrograms.

STFT-derived intermediate data are saved as MATLAB `.mat` files in the corresponding output directories.

## Project Structure

```text
.
├── README.md
├── LICENSE
├── CITATION.cff
├── src/
├── docs/
├── results/
└── references/
```

## Scientific Context

This project is motivated by the role of transient beta-band activity in sensorimotor processing and movement control.

The analysis provides a computational framework for studying the temporal organisation and characteristics of beta bursts in EEG recordings.

## Author

**Anandi Banerjee**

Student Researcher  
Research interests: Computational Neuroscience, EEG Signal Processing, Machine Learning, and Movement Control.

## Acknowledgements

This work was undertaken as part of the Summer Research Fellowship Programme (SRFP) 2025 at the Centre for Neuroscience, Indian Institute of Science (IISc), Bengaluru.

## License

The licensing terms for this repository will be specified in the accompanying LICENSE file.

## Citation

If you use this code in your research, please cite this repository using the information provided in `CITATION.cff`.

