clear;
clc;
close all;
%% Define paths
baseDirectory = "P:\WORK\David\UPF\TFM";
visualizerDirectory = fullfile(baseDirectory, "EEG_visualizer\");

%% Data under analysis
patientId = "11";
dataRecord = "53";
% patientId = "11";
% dataRecord = "2";
% patientId = "8";
% dataRecord = "057";

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
fullEeg = filter_(fullEeg, fs);

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


%% NEW DROPOUT DETECTOR SANDBOX

[dropoutStartingPoints, dropoutEndingPoints, totalDropouts, totalDropoutTime, dropoutRatio] = dropoutDetector(fullEeg, fs);

%% PLOTS

testChannel = 7;
singleEegSignal = fullEeg(testChannel, :);

% Intial variable parameters
histogramResolution = 500;
differenceThreshold = 10;
averagingWindowLength = 10;

singleEegSignal = fullEeg(testChannel, :);
eegSignalDerivative = diff(singleEegSignal);
absoluteDerivative = abs(eegSignalDerivative);
averagedDerivative = movmean(absoluteDerivative, averagingWindowLength);
[binCount, binEdges] = histcounts(averagedDerivative, histogramResolution);
binThreshold = binEdges(2);

% Plot the single EEG signal
subplot(4, 1, 1);
plot(singleEegSignal);
title('Single EEG Signal');
xlabel('Time');
ylabel('Amplitude');

% Plot the derivative of the single EEG signal
subplot(4, 1, 2);
plot(eegSignalDerivative);
title('Derivative of EEG Signal');
xlabel('Time');
ylabel('Derivative');

% Plot the absolute derivative
subplot(4, 1, 3);
plot(absoluteDerivative);
title('Absolute Derivative');
xlabel('Time');
ylabel('Absolute Derivative');

% Plot the histogram of the averaged derivative
subplot(4, 1, 4);
histogram(averagedDerivative, histogramResolution);
title('Histogram of Averaged Derivative');
xlabel('Averaged Derivative');
ylabel('Frequency');

% Adjust the layout
sgtitle('EEG Signal and Derivatives');

% Create a figure to display the plot
figure;

% Plot the original signal
plot(singleEegSignal);
title('Original EEG Signal');
xlabel('Sample Index');
ylabel('Amplitude');

% Highlight samples falling inside the first three bins with red color
hold on;
dropoutIndices = find(abs(averagedDerivative) < binThreshold);
dropoutSamples = singleEegSignal(dropoutIndices);
plot(dropoutIndices, dropoutSamples, 'r.', 'MarkerSize', 10);
hold off;

% Adjust the layout
title('Original EEG Signal with Red Highlights');