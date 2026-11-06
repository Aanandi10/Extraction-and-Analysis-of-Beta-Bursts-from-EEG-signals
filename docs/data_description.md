# Data Description

## Dataset Format

The analysis pipeline uses EEG recordings stored in MATLAB `.mat` format.

## Expected Data Structure

The script expects an EEG structure containing:

- `EEG.data`: EEG recordings arranged as channels × time points × trials.
- `EEG.srate`: Sampling frequency.
- `EEG.chanlocs`: Channel location information.

## Dataset Availability

The original EEG dataset is not included in this repository.

Users must provide their own compatible EEG dataset and ensure that they have the necessary permissions to use it.

## Data Loading

The current MATLAB script uses a local Windows file path. Users must update this path in their local copy to match the location of their dataset.
