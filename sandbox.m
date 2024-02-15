clear;
clc;
close all;
%% Define paths
baseDirectory = "P:\WORK\David\UPF\TFM";
visualizerDirectory = fullfile(baseDirectory, "EEG_visualizer\");
metricsAndMeasuresDirectory = visualizerDirectory + "Metrics_and_measures";

%% Data under analysis
% patientId = "11";
% dataRecord = "53";
patientId = "11";
dataRecord = "2";
% patientId = "8";
% dataRecord = "057";
patientId = "11";
seizure = "113";

%% Load data
dataDirectory = fullfile(baseDirectory, "Data", "Seizure_Data_" + patientId);
cd(dataDirectory);
fullEeg = load(sprintf('Seizure_%03d.mat', str2double(dataRecord)));
cd(visualizerDirectory);

%% Main program

% Customizable features
secondsToVisualize = inf;
plotColor = 'k';
fontSize = 12;
axisFontSize = 50;
offsetY = 1500;
yTickSpacing = 900; % Value may need changes for different totalChannels
doPlot = 1;

% Preprocess EEG data
fs = 400;
fullEeg = fullEeg.data';
%fullEeg = filter_(fullEeg, fs);

% Define channel names
[M, N] = size(fullEeg);
totalChannels = M;
channelNames = cell(1, totalChannels);
for i = 1:totalChannels
    channelNames{i} = ['ch' num2str(i, '%02d')];
end

% Initialize variables
samplesToVisualize = secondsToVisualize * fs;
if(samplesToVisualize > N)
    samplesToVisualize = N;
end
name_channel = channelNames;
names = [];
fs = 400;
time = 0:1/fs:(1/fs) * (size(fullEeg, 2) - 1);
offsetedEeg = offset(fullEeg);
eegToShow= offsetedEeg(:, 1:samplesToVisualize);

%% EEG UNWRAPPED & DETRENDED PHASE

channelToVisualize = 1;
channelEeg = fullEeg(channelToVisualize, :);

% Part of signal

% time1 = 60;
% time2 = 70;
% startSample = time1*fs;
% endSample = time2*fs;
% samples=startSample:endSample;
% time = linspace(time1, time2, length(samples));
%
% uncutHilbertTransform = hilbert(channelEeg(samples));
% phaseUncut = detrend(unwrap(atan2(imag(uncutHilbertTransform), real(uncutHilbertTransform)))) ;

% Full signal

uncutHilbertTransform = hilbert(channelEeg);
hilbertTransform = uncutHilbertTransform(0.05*length(uncutHilbertTransform):0.95*length(uncutHilbertTransform));
phase = detrend(unwrap(atan2(imag(hilbertTransform), real(hilbertTransform)))) ;
regularPhase = atan2(imag(hilbertTransform), real(hilbertTransform));
% phaseUncut = detrend(unwrap(atan2(imag(uncutHilbertTransform), real(uncutHilbertTransform)))) ;
time = (1:length(channelEeg)) / fs;

figure;
plot(real(uncutHilbertTransform), imag(uncutHilbertTransform))
ylabel('$\mathrm{Im}(X_H)$', 'Interpreter', 'latex');
xlabel('$\mathrm{Re}(X_H)$', 'Interpreter', 'latex');
%plot(regularPhase)
% figure;
% plot(time, phaseUncut)
% % plot(time, uncutHilbertTransform)
% ylabel('Phase (radians)');
% xlabel('Time (s)');
% title(['Patient ' num2str(patientId) ', Recording ' num2str(dataRecord) ', Channel ' num2str(channelToVisualize)]);

figure;
channelLength = N;
channelMeans = mean(fullEeg, 2);
eegFullCentered = fullEeg - channelMeans;
signal = eegFullCentered(1, :);
frequencies = (0:channelLength-1)*(fs/channelLength);
fft_signal = fft(signal);
plot(frequencies(1:channelLength/2), abs(fft_signal(1:channelLength/2)));
title('FFT of Channel 1')
xlabel('Frequency (Hz)');
ylabel('Magnitude');

axis tight;

%% FLATLINE DETECTOR

% windowSizeSeconds = 20;
% [isFlatline, flatlineChannels] = flatlineDetector(fullEeg, fs, windowSizeSeconds, false);
% disp(['Flatline found on: ', num2str(flatlineChannels')]);

% % Initialize the matrix to store statistics for each channel
% channelStatistics = zeros(size(fullEeg, 1), 5); % 5 columns for channel index, mean, std, skewness, and kurtosis
%
% % Compute statistics for each channel
% for channel = 1:size(fullEeg, 1)
%     % Take the absolute values of the current channel
%     currentChannel = abs(fullEeg(channel, :));
%
%     % Compute mean, standard deviation, skewness, and kurtosis
%     meanVal = mean(currentChannel);
%     stdVal = std(currentChannel);
%     skewnessVal = skewness(currentChannel);
%     kurtosisVal = kurtosis(currentChannel);
%
%     % Store the statistics in the matrix along with the channel index
%     channelStatistics(channel, :) = [channel, meanVal, stdVal, skewnessVal, kurtosisVal];
% end
%
% % Calculate the mean of the means
% meanMean = mean(channelStatistics(:, 2));
%
% % Display the statistics
% disp('Channel Statistics:');
% disp('Index | Mean | Std | Skewness | Kurtosis');
% disp(channelStatistics);
%
% % Display the mean of the means
% disp(['Mean of Means: ', num2str(meanMean)]);
%
% % Identify and display channels with mean less than the mean of means
% disp('Channels with Mean < Mean of Means:');
% disp(channelStatistics(channelStatistics(:, 2) < meanMean, 1));

% %% WINDOW SEGMENTER
%
% testChannel = 7;
% singleEegSignal = fullEeg(testChannel, :);
% windowSize = 20;
%
% cd(metricsAndMeasuresDirectory);
% metrics = DV_EEGPhaseVelocityAnalyzer(fs, singleEegSignal, windowSize);
% cd(visualizerDirectory);

%% NEW DROPOUT DETECTOR SANDBOX

[dropoutStartingPoints, dropoutEndingPoints, totalDropouts, totalDropoutTime, dropoutRatio] = dropoutDetector(fullEeg, fs);

%% PLOTS FOR DROPOUT

% testChannel = 7;
% singleEegSignal = fullEeg(testChannel, :);
%
% % Intial variable parameters
% histogramResolution = 500;
% differenceThreshold = 10;
% averagingWindowLength = 10;
% binsInUse = 2;
%
% singleEegSignal = fullEeg(testChannel, :);
% eegSignalDerivative = diff(singleEegSignal);
% absoluteDerivative = abs(eegSignalDerivative);
% averagedDerivative = movmean(absoluteDerivative, averagingWindowLength);
% [binCount, binEdges] = histcounts(averagedDerivative, histogramResolution);
% binThreshold = binEdges(binsInUse);
%
% % Plot the single EEG signal
% subplot(3, 1, 1);
% plot(singleEegSignal);
% % title('Original signal', 'FontSize', 16);
% xlabel('Time (s)', 'FontSize', 16);
% ylabel('Amplitude (mV)', 'FontSize', 16);
% xticklabels(get(gca, 'xtick') / 400);
%
% % % Plot the derivative of the single EEG signal
% % subplot(4, 1, 2);
% % plot(eegSignalDerivative);
% % title('Derivative of EEG Signal');
% % xlabel('Time (s)');
% % ylabel('Amplitude (mV)');
% % xticklabels(get(gca, 'xtick') / 400);
%
% % Plot the absolute derivative
% subplot(3, 1, 2);
% plot(absoluteDerivative);
% % title('Smoothed difference', 'FontSize', 16);
% xlabel('Time (s)', 'FontSize', 16);
% ylabel('Amplitude (mV)', 'FontSize', 16);
% xticklabels(get(gca, 'xtick') / 400);
%
% % Plot the histogram of the averaged derivative
% subplot(3, 1, 3);
% histogram(averagedDerivative, histogramResolution);
% % title('Histogram of smoothed difference', 'FontSize', 16);
% xlabel('Bins', 'FontSize', 16);
% ylabel('Frequency', 'FontSize', 16);
%
% axis("tight")
%
% % Create a figure to display the plot
% figure;
%
% % Plot the original signal
% plot(singleEegSignal);
% title('Original EEG Signal', 'FontSize', 16);
% xlabel('Time (s)', 'FontSize', 16);
% ylabel('Amplitude (mV)', 'FontSize', 16);
% xticklabels(get(gca, 'xtick') / 400);
%
% % Highlight samples falling inside the first three bins with red color
% hold on;
% dropoutIndices = find(abs(averagedDerivative) < binThreshold);
% dropoutSamples = singleEegSignal(dropoutIndices);
% plot(dropoutIndices, dropoutSamples, 'r.', 'MarkerSize', 10);
% hold off;

