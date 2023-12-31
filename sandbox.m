clear;
clc;
close all;
%% Define paths
baseDirectory = "P:\WORK\David\UPF\TFM";
visualizerDirectory = fullfile(baseDirectory, "EEG_visualizer\");

%% Data under analysis
patientId = "11";
dataRecord = "003";
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

% Create a figure for visualization
h = figure;

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

% Initialize plotting
xlabelText = 'Time (s)';
ylabelText = 'Channels';

plot(time(1:samplesToVisualize), offsetedEeg(:, 1:samplesToVisualize), plotColor);
title('Patient ' + patientId + ', seizure ' + dataRecord);
xlabel(xlabelText, 'FontSize', axisFontSize);
ylabel(ylabelText, 'FontSize', axisFontSize);
ylim([0, max(max(offsetedEeg)) + 500]);
set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel, 'Fontsize', fontSize);
time__ = time(1:samplesToVisualize);

fig = 0;
all = 0;
save = [-1, -1];
amplifyY = false;
coordinatesy = coordinatesy_(fullEeg, offsetY);

%% DROPOUT DETECTOR SANDBOX
% V2
% 
% D = deepSignalAnomalyDetector(totalChannels);
% opts = trainingOptions("adam",MaxEpochs=100);
% trainDetector(D,fullEeg(1,:),opts)
% [lbls,loss] = detect(D,fullEeg(14,:));

% V1
thresholdValue = 1.5;
consecutiveThreshold = 20;
maxDropouts = 0; 
maxDropoutsInfo = 'No droputs have been found';
maxDropoutsDurations = [];
totalDropoutTime = 0;
dropoutPercentage = 0;

for i = 1:totalChannels
    [dropoutIndices, dropoutGroups, dropoutCount, dropoutDurations, dropoutInfo] = ...
        dropout_detector(fullEeg(i, :), thresholdValue, consecutiveThreshold, fs, i, false);

    % Check if the current channel has more dropouts than the previous maximum
    if dropoutCount > maxDropouts
        maxDropouts = dropoutCount;
        maxDropoutsChannel = i;
        maxDropoutsDurations = dropoutDurations;
        maxDropoutsInfo = dropoutInfo;
        totalDropoutTime = totalDropoutTime + sum(dropoutDurations);
        dropoutPercentage = (totalDropoutTime / (N/fs)) * 100;
    end
end

% Add the total dropout time information to maxDropoutsInfo
maxDropoutsInfo = [maxDropoutsInfo, sprintf('\nTotal Dropout Time: %.2f seconds (%.2f%%)', totalDropoutTime, dropoutPercentage)];
% Display the information
disp('********************************************');
disp(maxDropoutsInfo);


%% Plot test
testChannel = 8;
testSignal = fullEeg(testChannel, :);

[dropoutIndices, dropoutGroups, dropoutCount, dropoutDurations, dropoutInfo] = ...
        dropout_detector(testSignal, thresholdValue, consecutiveThreshold, fs, testChannel, false);

% Plot the original signal with dropouts highlighted
figure;

subplot(2,1,1);
plot(1:length(testSignal), testSignal, 'b');
title('Original EEG Signal');
xlabel('Sample Index');
ylabel('Signal Amplitude');

subplot(2,1,2);
plot(1:length(testSignal), testSignal, 'b');
hold on;
plot(dropoutIndices, testSignal(dropoutIndices), 'ro', 'MarkerSize', 10);
title('EEG Signal with Identified Dropouts');
xlabel('Sample Index');
ylabel('Signal Amplitude');
legend('Original Signal', 'Dropout Regions');
hold off;