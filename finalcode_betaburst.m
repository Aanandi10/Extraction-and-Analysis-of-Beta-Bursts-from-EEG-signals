
clear; close all; clc;

%% 1) EEG Dataset Loading & Raw Plotting 

% 1.1) Load the dataset
data = load("C:\Users\POLY\Documents\sub14_eegdata.mat");

disp("Variables in the given Dataset:");
disp(fieldnames(data));

% 1.2) Assign the main EEG variable to our workspace
EEG = data.EEG;
EEG.data = double(EEG.data);

fprintf("The size of our data = %d channels x %d time points x %d trials\n", size(EEG.data));

% 1.3) Printing the number of channels , time-points and number of trials
fprintf('EEG has %d channels and %d time points per trial, sampled at %.1f Hz.\n', ...
        size(EEG.data,1), size(EEG.data,2), EEG.srate);

% 1.4) Calculating duration of signal (in seconds)
no_of_samples = size(EEG.data, 2); 
time = (0:no_of_samples-1) / EEG.srate;

fprintf("The total duration of our signal = %.2f seconds\n", max(time));






%% 3) USER INPUT FOR CHANNELS AND TRIALS
channels = input('Enter channel numbers as a vector (e.g., [11,12,13]): ');
trialInput = input('Enter trial number(s) as a vector (e.g., [1,4]) or type ''all'': ', 's');

% Sort channels
channels = sort(channels);

% Handle 'all' trials or specific selection
if strcmpi(trialInput, 'all')
    trials = 1:size(EEG.data, 3);  % Assumes EEG is already loaded
else
    trials = str2num(trialInput);  %str2num converts the string to a numeric vector.
    trials = sort(trials);
end

%% 4) PLOTTING RAW EEG SIGNALS

 % amplitude offset to separate traces visually
offsetRaw =100;

for tr = trials
    figure('Name', sprintf('Raw EEG - Trial %d', tr), 'NumberTitle', 'off'); 
    clf; hold on;
    
    for i = 1:numel(channels)
        ch = channels(i);
        plot(time, squeeze(EEG.data(ch,:,tr)) + (i-1)*offsetRaw);
    end
    
    hold off;
    title(sprintf('Raw EEG (Channels %s) - Trial %d', mat2str(channels), tr),FontSize=25);
    xlabel('Time (s)',FontSize=25);
    ylabel('Amplitude + offset (\muV)',FontSize=25);
    legend(arrayfun(@(c) sprintf('Ch %d', c), channels, 'UniformOutput', false),FontSize=25);
    grid on;
end

%% 5)  PLOTTING FILTERED EEG SIGNALS

% 5.1) Designing beta bandpass filter (13–30 Hz)
beta_filter = designfilt('bandpassiir', ...
    'FilterOrder', 6, ...
    'HalfPowerFrequency1', 13, ...
    'HalfPowerFrequency2', 30, ...
    'DesignMethod', 'butter', ...
    'SampleRate', EEG.srate);


% 5.2) Applying beta filter and plotting 
offsetBeta = 50;
for tr = trials
    figure('Name', sprintf('Beta-Filtered - Trial %d', tr), 'NumberTitle', 'off'); clf; hold on;
    for i = 1:numel(channels)
        ch = channels(i);
        betaSig = filtfilt(beta_filter, squeeze(EEG.data(ch,:,tr)));
        plot(time, betaSig + (i-1)*offsetBeta);
    end
    hold off;
    title(sprintf('Beta Signal(13–30 Hz) of Channels %s- Trial %d', mat2str(channels), tr),FontSize=25);
    xlabel('Time (s)',FontSize=25); ylabel('Amplitude + offset (\muV)',FontSize=25);
    yticks((0:numel(channels)-1)*offsetBeta);
    yticklabels(arrayfun(@(c) sprintf('Ch %d',c), channels, 'UniformOutput',false));
    grid on;
end

%% 6) VISUALIZING RAW AND BETA-FILTERED SEPARATELY
for tr = trials
    figure('Name', sprintf('Raw and Filtered EEG - Trial %d', tr), 'NumberTitle', 'off');

    for i = 1:numel(channels)
        ch = channels(i);
        raw_signal = squeeze(EEG.data(ch,:,tr));
        beta_signal = filtfilt(beta_filter, raw_signal);

        % Raw EEG subplot
        subplot(numel(channels), 2, (i-1)*2 + 1);
        plot(time, raw_signal, 'Color', [0.2 0.4 1], 'LineWidth', 1.2);
        title(sprintf('Raw EEG - Ch %d', ch), 'FontSize', 12);
        xlabel('Time (s)', 'FontSize', 11);
        ylabel('Amplitude (\muV)', 'FontSize', 11);
        grid on;

        % Beta-filtered subplot
        subplot(numel(channels), 2, (i-1)*2 + 2);
        plot(time, beta_signal, 'Color', [1 0.3 0.3], 'LineWidth', 1.2);
        title(sprintf('Beta-Filtered (13–30 Hz) - Ch %d', ch), 'FontSize', 12);
        xlabel('Time (s)', 'FontSize', 11);
        ylabel('Amplitude (\muV)', 'FontSize', 11);
        grid on;
    end

    sgtitle(sprintf('Raw vs Beta-Filtered EEG - Trial %d', tr), 'FontWeight', 'bold', 'FontSize', 14);
end



%% 7) PLOTTING POWER SPECTRAL DENSITY (PSD)

fs = EEG.srate;
nfft = 2^12;
window = hamming(1000);
noverlap = 500;
for tr = trials
    figure('Name', sprintf('PSD 13–30 Hz (Beta Filtered) - Trial %d', tr), 'NumberTitle', 'off');
    hold on;
    for i = 1:numel(channels)
        ch = channels(i);
        beta_signal = filtfilt(beta_filter, squeeze(EEG.data(ch,:,tr)));
        [pxx, f] = pwelch(beta_signal, window, noverlap, nfft, fs);
        idx = f >= 13 & f <= 30;
        plot(f(idx), 10*log10(pxx(idx)), 'DisplayName', sprintf('Ch %d', ch));
    end
    hold off;
    title(sprintf('Power Spectrum (13–30 Hz, Beta Filtered) - Trial %d', tr));
    xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
    legend('show'); grid on;
end


%% Combined Beta Signal + Envelope Visualization

offsetVis = 50;
for tr = trials
    figure('Name', sprintf('Beta + Envelope - Trial %d', tr), 'NumberTitle', 'off'); hold on;
    for i = 1:numel(channels)
        ch = channels(i);
        raw_signal = squeeze(EEG.data(ch,:,tr));
        beta_signal = filtfilt(beta_filter, raw_signal);
        analytic_signal = hilbert(beta_signal);
        amplitude_envelope = abs(analytic_signal);
        y_offset = (i-1) * offsetVis;
        plot(time, beta_signal + y_offset, 'b');
        plot(time, amplitude_envelope + y_offset, 'r', 'LineWidth', 1.5);
    end
    xlabel('Time (s)', 'FontSize', 22);
    ylabel('Amplitude + Offset (\muV)', 'FontSize', 22);
    title(sprintf('Amplitude Envelope - Trial %d', tr), 'FontSize', 22);
    legend('Beta Signal', ['Amplitude ' ...
        'Envelope'], 'FontSize', 22);
    yticks((0:numel(channels)-1) * offsetVis);
    yticklabels(arrayfun(@(c) sprintf('Ch %d', c), channels, 'UniformOutput', false));
    grid on;
    hold off;
end



%% 2) COMPUTING THE GLOBAL THRESHOLD FOR BETA BURST DETECTION 

beta_filter= designfilt('bandpassiir', ...
    'FilterOrder', 6, ...
    'HalfPowerFrequency1', 13, ...
    'HalfPowerFrequency2', 30, ...
    'DesignMethod', 'butter', ...
    'SampleRate', EEG.srate);


% 2.1) Precomputing envelope over all channels & all trials
[nCh, nSamps, nTrials] = size(EEG.data);
allEnvs = zeros(nCh*nSamps*nTrials,1);
pos = 1;
for ch = 1:nCh
    for tr = 1:nTrials
        raw      = squeeze(EEG.data(ch,:,tr));
        beta_signal  = filtfilt(beta_filter, raw);
        env      = abs(hilbert(beta_signal));
        allEnvs(pos:pos+numel(env)-1) = env;
        pos = pos + numel(env);
    end
end
allEnvs = allEnvs(~isnan(allEnvs) & ~isinf(allEnvs));   % clean

%2.2) Choosing multiplier k 
k = 1.5;  
med_envlope = median(allEnvs);
std_env = std(allEnvs);

%Computing the threshold
global_threshold = med_envlope + k*std_env;
fprintf('Global threshold (k=%.2f) = %.3f µV\n', k, global_threshold);


%% 8) Clear Beta Burst Visualization Using Global Threshold

fs = EEG.srate;
time = (0:size(EEG.data,2)-1) / fs;
offset = 50;
min_duration_samples = round(0.010 * fs);  % 10 milliseconds in samples

for tr = trials
    figure('Name', sprintf('Beta Bursts (Global Threshold) - Trial %d', tr), 'NumberTitle', 'off');
    for i = 1:numel(channels)
        ch = channels(i);
        beta_signal = filtfilt(beta_filter, squeeze(EEG.data(ch,:,tr)));
        envelope    = abs(hilbert(beta_signal));
        above_thresh = envelope > global_threshold;
        onsets       = find(diff([0, above_thresh]) == 1);
        offsets      = find(diff([above_thresh, 0]) == -1);

        % Burst count
        valid_bursts = 0;
        subplot(numel(channels),1,i); hold on;
        plot(time, beta_signal, 'b', 'LineWidth', 1);
        plot(time, envelope,    'r', 'LineWidth', 1.5);
        yline(global_threshold, ':k', sprintf('Thresh = %.2f \x03bcV', global_threshold), 'FontSize', 20, 'Interpreter', 'none');

        for k = 1:length(onsets)
            startIdx = onsets(k);
            endIdx = offsets(find(offsets > startIdx, 1));
            if isempty(endIdx), continue; end

            % Check for minimum burst duration (10 ms)
            if (endIdx - startIdx + 1) >= min_duration_samples
                valid_bursts = valid_bursts + 1;
                area(time(startIdx:endIdx), envelope(startIdx:endIdx), global_threshold, ...
                     'FaceColor', [0.2 1 0.2], 'EdgeColor', 'none');
            end
        end

        hold off;
        title(sprintf('Channel %d - Trial %d | Bursts: %d', ch, tr, valid_bursts), 'FontWeight', 'bold', 'FontSize', 49);
        xlabel('Time (s)'); ylabel('Amplitude (\x03bcV)', 'Interpreter', 'tex', 'FontSize', 29);
        legend({'Beta','Envelope','Thresh','Burst'}, 'Location','northeast', 'FontSize', 20);
        grid on;
        ax = gca;
        ax.LineWidth = 2;
        ax.XColor = [0.1 0.1 0.1];
        ax.YColor = [0.1 0.1 0.1];
        ax.FontSize = 22;
    end
end

%% 9 COUNTING THE NUMBER OF BURSTS

% Use existing variables: trials, channels, fs, EEG, global_threshold

min_duration_samples = round(0.010 * fs);  % 10 milliseconds in samples

for t = trials
    %fprintf('\n=========================\n');
    fprintf('TRIAL %d\n', t);
    fprintf('-----------------------\n');

    for i = 1:numel(channels)
        ch = channels(i);
        raw_signal = squeeze(EEG.data(ch,:,t));
        beta_signal = filtfilt(beta_filter, raw_signal);
        envelope = abs(hilbert(beta_signal));

        % Threshold crossing logic
        above_thresh = envelope > global_threshold;
        onset_locs = find(diff([0, above_thresh]) == 1);
        offset_locs = find(diff([above_thresh, 0]) == -1);

        % Proper pairing
        burst_times = [];
        valid_bursts = 0;
        for b = 1:length(onset_locs)
            onset_idx = onset_locs(b);
            offset_idx = offset_locs(find(offset_locs > onset_idx, 1));
            if isempty(offset_idx), continue; end

            % Check for minimum burst duration
            if (offset_idx - onset_idx + 1) >= min_duration_samples
                duration = (offset_idx - onset_idx) / fs;
                burst_env = envelope(onset_idx:offset_idx);
                peak_amp = max(burst_env);
                peak_pow = peak_amp^2;
                onset_time = onset_idx / fs;

                % Count & log burst
                valid_bursts = valid_bursts + 1;
                burst_times(end+1,:) = [onset_time, duration, peak_amp, peak_pow];
            end
        end

        % Display channel-wise info
        fprintf('\nChannel %d (%s): %d bursts detected\n', ch, EEG.chanlocs(ch).labels, valid_bursts);
        for b = 1:size(burst_times,1)
            fprintf('  Burst %2d: Onset = %.3fs | Duration = %.3fs | Peak Amp = %.4f | Peak Power = %.4f\n', ...
                b, burst_times(b,1), burst_times(b,2), burst_times(b,3), burst_times(b,4));
        end
    end
end

%% === FFT Plot: Amplitude vs Frequency (0–100 Hz, Beta Filtered) ===
% This version applies the beta filter before FFT, so only beta-band activity is retained.

for tr = trials
    figure('Name', sprintf('FFT (Beta-Filtered) - Trial %d', tr), 'NumberTitle', 'off');

    for i = 1:numel(channels)
        ch = channels(i);
        raw_signal = squeeze(EEG.data(ch,:,tr));
        
        % Apply beta band filter (13–30 Hz)
        beta_signal = filtfilt(beta_filter, raw_signal);

        % Compute FFT of beta-filtered signal
        L = length(beta_signal);
        Y = fft(beta_signal);
        P2 = abs(Y / L);           % Two-sided amplitude spectrum
        P1 = P2(1:floor(L/2)+1);   % One-sided amplitude spectrum
        P1(2:end-1) = 2 * P1(2:end-1);
        f = fs * (0:floor(L/2)) / L;  % Frequency vector

        % Limit to 0–100 Hz
        idx = f <= 100;

        subplot(numel(channels), 1, i);
        plot(f(idx), P1(idx), 'LineWidth', 1.2);
        xlabel('Frequency (Hz)', 'FontSize', 25);
        ylabel('Amplitude', 'FontSize', 25);
        title(sprintf('FFT (Beta Filtered) - Ch %d (Trial %d)', ch, tr), 'FontSize', 22);
        grid on;
    end

    sgtitle(sprintf('FFT Amplitude Spectrum (Beta Filtered) - Trial %d', tr), 'FontWeight', 'bold');
end
%% === Burst Peak Amplitude vs Time + Trend Lines ===

fprintf('\n[INFO] Plotting burst peak amplitude trends  for all trials per selected channel...\n');

duration_limit = 3;  % Seconds

for i = 1:numel(channels)
    ch = channels(i);
    figure('Name', sprintf('Early Burst Trends - Channel %d', ch), 'NumberTitle', 'off', 'Color', 'w');
    sgtitle(sprintf('Burst Peak Amplitude vs Time - Channel %d (%s)', ...
             ch, EEG.chanlocs(ch).labels), 'FontSize', 14, 'FontWeight', 'bold');

    rows = ceil(sqrt(nTrials));
    cols = ceil(nTrials / rows);

    for tr = 1:nTrials
        raw_signal   = squeeze(EEG.data(ch,:,tr));
        beta_signal  = filtfilt(beta_filter, raw_signal);
        envelope     = abs(hilbert(beta_signal));

        % Detect bursts above threshold
        above_thresh = envelope > global_threshold;
        onsets  = find(diff([0, above_thresh]) == 1);
        offsets = find(diff([above_thresh, 0]) == -1);

        onset_times = [];
        peak_amps = [];

        for b = 1:length(onsets)
            start_idx = onsets(b);
            end_idx = offsets(find(offsets > start_idx, 1));
            if isempty(end_idx), continue; end

            segment = envelope(start_idx:end_idx);
            [peak_amp, rel_idx] = max(segment);
            onset_time = time(start_idx + rel_idx - 1);

            if onset_time <= duration_limit
                onset_times(end+1) = onset_time;
                peak_amps(end+1) = peak_amp;
            end
        end

        % Plot per trial
        subplot(rows, cols, tr);
        scatter(onset_times, peak_amps, 25, 'filled', 'MarkerFaceColor', [0 0.447 0.741]);
        hold on;
        plot(onset_times, peak_amps, '-', 'Color', [0 0.447 0.741], 'LineWidth', 1);

        % ===== Linear Trend Line =====
        if numel(onset_times) >= 2
            p = polyfit(onset_times, peak_amps, 1);  % Linear fit
            y_fit = polyval(p, onset_times);
            plot(onset_times, y_fit, '--k', 'LineWidth', 1.2);
        end

        title(sprintf('Trial %d', tr), 'FontSize', 8);
        xlabel('Time (s)', 'FontSize', 8);
        ylabel('Peak (μV)', 'FontSize', 8);
        xlim([0, duration_limit]);
        ylim padded;
        grid on;
    end
end
%% === Global Trend of Burst Peak Amplitude vs Time  — All Trials Combined ===

fprintf('\n[INFO] Computing and plotting GLOBAL peak amplitude trend  across ALL trials...\n');

duration_limit = 3;       % Seconds

for i = 1:numel(channels)
    ch = channels(i);
    all_onsets = [];
    all_peaks  = [];

    for tr = 1:nTrials
        raw_signal   = squeeze(EEG.data(ch,:,tr));
        beta_signal  = filtfilt(beta_filter, raw_signal);
        envelope     = abs(hilbert(beta_signal));

        % Detect bursts above threshold
        above_thresh = envelope > global_threshold;
        onsets  = find(diff([0, above_thresh]) == 1);
        offsets = find(diff([above_thresh, 0]) == -1);

        for b = 1:length(onsets)
            start_idx = onsets(b);
            end_idx = offsets(find(offsets > start_idx, 1));
            if isempty(end_idx), continue; end

            segment = envelope(start_idx:end_idx);
            [peak_amp, rel_idx] = max(segment);
            onset_time = time(start_idx + rel_idx - 1);

            if onset_time <= duration_limit
                all_onsets(end+1) = onset_time;
                all_peaks(end+1)  = peak_amp;
            end
        end
    end

    % Plot global trend for this channel
    figure('Name', sprintf('Global Trend - Channel %d', ch), 'NumberTitle', 'off', 'Color', 'w');
    scatter(all_onsets, all_peaks, 30, 'filled', 'MarkerFaceColor', [0.3010 0.7450 0.9330]);
    hold on;

    % Fit linear trend
    if numel(all_onsets) >= 2
        p = polyfit(all_onsets, all_peaks, 1);  % [slope, intercept]
        y_fit = polyval(p, all_onsets);
        plot(all_onsets, y_fit, '--k', 'LineWidth', 2);

        % Display slope direction
        trend_text = sprintf('Slope = %.4f  → %s', ...
            p(1), ternary(p(1) > 0, 'INCREASING', 'DECREASING'));
        text(0.05, max(all_peaks)*0.95, trend_text, ...
             'FontSize', 22, 'FontWeight', 'bold', ...
             'BackgroundColor', 'w', 'EdgeColor', 'k');
    end

    title(sprintf('Global Burst Trend  - Channel %d (%s)', ch, EEG.chanlocs(ch).labels), 'FontSize', 25);
    xlabel('Onset Time (s)', 'FontSize', 25);
    ylabel('Peak Amplitude (\muV)', 'FontSize', 25);
    xlim([0, duration_limit]);
    ylim padded;
    grid on;
end


%% 10) STFT Time-Frequency Analysis (Per Trial, Per Channel)
fprintf('\n[INFO] Performing STFT Time-Frequency Analysis on each trial...\n');

% Sampling rate
fs = EEG.srate;

% STFT Parameters
window_length = 510;                     % STFT window size (in samples)
overlap_length = window_length / 2;      % 50% overlap
nfft = 1024;                             % Zero-padding to increase frequency resolution

% Output folder
output_folder = 'stft_results';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Frequency limits
freq_max = 100;
beta_min = 8;
beta_max = 30;

% Loop over all trials
for tr = 1:nTrials
    fprintf('→ Processing Trial %d...\n', tr);

    % Preallocate power matrix for all channels
    power_all_ch = [];

    for c = 1:numel(channels)
        ch = channels(c);
        signal = double(squeeze(EEG.data(ch, :, tr)));

        % Perform STFT
        [stft_matrix, freq, tf_time] = stft(signal, fs, ...
            'Window', hann(window_length), ...
            'OverlapLength', overlap_length, ...
            'FFTLength', nfft);

        % Extract magnitude squared (power)
        power = abs(stft_matrix).^2;  % [freq x time]
        power_all_ch(:, :, c) = power;
    end

    % Frequency masks
    freq_idx_120 = freq <= freq_max;
    freq_idx_beta = (freq >= beta_min) & (freq <= beta_max);

    % Get channel labels
    ch_labels = {EEG.chanlocs(channels).labels};

    % Save full and beta-limited spectrograms
    fname = fullfile(output_folder, sprintf('trial%03d_stft.mat', tr));
    save(fname, ...
        'power_all_ch', 'freq', 'tf_time', ...
        'freq_idx_120', 'freq_idx_beta', ...
        'beta_min', 'beta_max', 'freq_max', ...
        'channels', 'ch_labels', 'tr');

    % Save only beta-band log power separately for fast access
    beta_power_log = 10 * log10(power_all_ch(freq_idx_beta, :, :));
    beta_freqs = freq(freq_idx_beta);
    save(fullfile(output_folder, sprintf('trial%03d_beta_only.mat', tr)), ...
        'beta_power_log', 'beta_freqs', 'tf_time', 'tr', 'ch_labels');

    fprintf('    Saved Trial %d → [%d×%d×%d] + beta-band log power.\n', ...
        tr, size(power_all_ch,1), size(power_all_ch,2), size(power_all_ch,3));
end

fprintf('\n✅ [DONE] STFT-based power spectrograms + beta-band data saved for all trials.\n');

%% 11) Visualize STFT Spectrograms for All Trials (Beta Band), One Figure per Channel
fprintf('\n[INFO] Visualizing STFT spectrograms (Beta band) — one window per channel...\n');

% User-specified channels (e.g., [1 2 3])
user_channels = channels;  % Replace with e.g., [5 7 9] if desired

% Adjust time axis from 0–3 to -2 to +1
time_shift = -2;
load(fullfile(output_folder, 'trial001_stft.mat'), 'tf_time', 'freq', 'freq_idx_beta');
tf_time_shifted = tf_time + time_shift;
beta_freqs = freq(freq_idx_beta);

% Plot one figure per selected channel
for c = 1:numel(user_channels)
    ch = user_channels(c);
    ch_plot_idx = find(channels == ch);  % Find index inside power_all_ch

    % Open figure for current channel
    figure('Name', sprintf('STFT Beta Band - Channel %d', ch), ...
           'Color', 'w', 'NumberTitle', 'off', ...
           'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    sgtitle(sprintf('Beta Band STFT (8–30 Hz) — Channel %d', ch), 'FontWeight', 'bold', 'FontSize', 14);

    % Compute subplot layout
    nCols = ceil(sqrt(nTrials));
    nRows = ceil(nTrials / nCols);

    for tr = 1:nTrials
        fname = fullfile(output_folder, sprintf('trial%03d_stft.mat', tr));
        if ~isfile(fname)
            warning('Missing: %s. Skipping...\n', fname);
            continue;
        end

        load(fname, 'power_all_ch', 'ch_labels');

        subplot(nRows, nCols, tr);
        imagesc(tf_time_shifted, beta_freqs, ...
            10*log10(power_all_ch(freq_idx_beta, :, ch_plot_idx)));
        axis xy;
        colormap turbo;
        colorbar off;
        xlim([-2, 1]);
        ylim([beta_min, beta_max]);
        title(sprintf('Trial %d', tr), 'FontSize', 8);
        xlabel('Time (s)');
        ylabel('Freq (Hz)');
    end
end

fprintf('\n✅ [DONE] STFT beta-band spectrograms plotted — one figure per selected channel.\n');






%% 10) STFT Time-Frequency Analysis (0.5–100 Hz)
fprintf('\n[INFO] STFT Time-Frequency Analysis (0.5–100 Hz)...\n');

fs = EEG.srate;
window_length = 510;
overlap_length = window_length / 2;
nfft = 1024;

output_folder = 'stft_0p5_100Hz';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

freq_min = 0.5;
freq_max = 100;

for tr = 1:nTrials
    fprintf('→ Trial %d...\n', tr);
    power_all_ch = [];

    for c = 1:numel(channels)
        ch = channels(c);
        signal = double(squeeze(EEG.data(ch, :, tr)));  % raw, unfiltered

        [stft_matrix, freq, tf_time] = stft(signal, fs, ...
            'Window', hann(window_length), ...
            'OverlapLength', overlap_length, ...
            'FFTLength', nfft);

        power = abs(stft_matrix).^2;
        power_all_ch(:, :, c) = power;
    end

    % Frequency index for 0.5–100 Hz
    freq_idx_fullband = (freq >= freq_min & freq <= freq_max);
    ch_labels = {EEG.chanlocs(channels).labels};

    % Save
    save(fullfile(output_folder, sprintf('trial%03d_stft.mat', tr)), ...
        'power_all_ch', 'freq', 'tf_time', ...
        'freq_idx_fullband', 'freq_min', 'freq_max', ...
        'channels', 'ch_labels', 'tr');

    % Save log power for 0.5–100 Hz
    fullband_power_log = 10 * log10(power_all_ch(freq_idx_fullband, :, :) + eps);
    fullband_freqs = freq(freq_idx_fullband);

    save(fullfile(output_folder, sprintf('trial%03d_fullband_only.mat', tr)), ...
        'fullband_power_log', 'fullband_freqs', 'tf_time', 'tr', 'ch_labels');
end

fprintf('\n✅ [DONE] STFT power + fullband log power saved for all trials.\n');



%% 11) Plot Per-Trial Fullband Spectrograms (0.5–100 Hz)
fprintf('\n[INFO] Plotting 0.5–100 Hz spectrograms per channel...\n');

user_channels = channels;  % Use a subset if desired (e.g., [11])
time_shift = -2;

load(fullfile(output_folder, 'trial001_stft.mat'), 'tf_time', 'freq', 'freq_idx_fullband');
tf_time_shifted = tf_time + time_shift;
fullband_freqs = freq(freq_idx_fullband);

for c = 1:numel(user_channels)
    ch = user_channels(c);
    ch_plot_idx = find(channels == ch);

    figure('Name', sprintf('STFT 0.5–100 Hz — Channel %d', ch), ...
        'Color', 'w', 'Units', 'normalized', ...
        'OuterPosition', [0 0 1 1]);
    sgtitle(sprintf('Time-Frequency Analysis using STFT (0.5–100 Hz) — Channel %d', ch), ...
            'FontWeight', 'bold', 'FontSize', 14);

    nCols = ceil(sqrt(nTrials));
    nRows = ceil(nTrials / nCols);

    for tr = 1:nTrials
        fname = fullfile(output_folder, sprintf('trial%03d_stft.mat', tr));
        if ~isfile(fname)
            continue;
        end

        load(fname, 'power_all_ch');

        subplot(nRows, nCols, tr);
        imagesc(tf_time_shifted, fullband_freqs, ...
            10 * log10(power_all_ch(freq_idx_fullband, :, ch_plot_idx) + eps));
        axis xy;
        colormap turbo;
        colorbar off;
        xlim([-2, 1]);
        ylim([freq_min, freq_max]);
        title(sprintf('Trial %d', tr), 'FontSize', 8);
        xlabel('Time (s)');
        ylabel('Freq (Hz)');
    end
end

fprintf('\n✅ [DONE] 0.5–100 Hz spectrograms plotted.\n');


%% 11) Plot Per-Trial Fullband Spectrograms (2x2 Trials per Figure)
fprintf('\n[INFO] Plotting 0.5–100 Hz spectrograms per channel (2x2 layout)...\n');

user_channels = channels;  % Use a subset if desired (e.g., [11])
time_shift = -2;

load(fullfile(output_folder, 'trial001_stft.mat'), 'tf_time', 'freq', 'freq_idx_fullband');
tf_time_shifted = tf_time + time_shift;
fullband_freqs = freq(freq_idx_fullband);



for c = 1:numel(user_channels)
    ch = user_channels(c);
    ch_plot_idx = find(channels == ch);

    % Plot every 4 trials per figure
    for group_start = 1:4:nTrials
        group_end = min(group_start + 3, nTrials);

        figure('Name', sprintf('STFT 0.5–100 Hz — Channel %d (Trials %d–%d)', ch, group_start, group_end), ...
            'Color', 'w', 'Units', 'normalized', ...
            'OuterPosition', [0 0 1 1]);
        sgtitle(sprintf('STFT Power (0.5–100 Hz) — Channel %d (Trials %d–%d)', ch, group_start, group_end), ...
                'FontWeight', 'bold', 'FontSize', 14);

        for i = 0:(group_end - group_start)
            tr = group_start + i;
            fname = fullfile(output_folder, sprintf('trial%03d_stft.mat', tr));
            if ~isfile(fname), continue; end

            load(fname, 'power_all_ch');

            subplot(2, 2, i + 1);  % 2 rows x 2 cols
            imagesc(tf_time_shifted, fullband_freqs, ...
                10 * log10(power_all_ch(freq_idx_fullband, :, ch_plot_idx) + eps));
            axis xy;
            colormap turbo;
            colorbar off;
            xlim([-2, 1]);
            ylim([freq_min, freq_max]);
            title(sprintf('Trial %d', tr), 'FontSize', 8);
            xlabel('Time (s)');
            ylabel('Freq (Hz)');
        end
    end
end

fprintf('\n✅ [DONE] Spectrograms plotted in 2x2 grids per figure.\n');







%% === Helper Functions ===
function result = ternary(cond, valTrue, valFalse)
    if cond
        result = valTrue;
    else
        result = valFalse;
    end
end

