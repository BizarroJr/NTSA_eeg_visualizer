clear;
clc;
close all;
%% Define paths
baseDirectory = "P:\WORK\David\UPF\TFM";
visualizerDirectory = fullfile(baseDirectory, "eeg visualizator\");

%% Data under analysis
patientId = "11";
dataRecord = "003";

%% Load data
dataDirectory = fullfile(baseDirectory, "Data", "Seizure_Data_" + patientId);
cd(dataDirectory);
myEeg = load(sprintf('Seizure_%03d.mat', str2double(dataRecord)));
cd(visualizerDirectory);

%% Main program

% Preprocess EEG data
fs = 400;
myEeg = myEeg.data';
myEeg = filter_(myEeg, fs);

% Define channel names
channelNames = {'ch01', 'ch02', 'ch03', 'ch04', 'ch05', 'ch06', 'ch07', 'ch08', 'ch09', 'ch10', 'ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'};

% Create a figure for visualization
h = figure;

% Initialize variables
samplesToVisualize = 20000;
name_channel = channelNames;
names = [];
fs = 400;
time = 0:1/fs:(1/fs) * (size(myEeg, 2) - 1);
[M, N] = size(myEeg);
myEeg = offset(myEeg); 
eeg_ = myEeg(:, 1:samplesToVisualize);

% Initialize plotting
plotColor = 'k';
fontSize = 12;
xlabelText = 'Time (s)';
ylabelText = 'Channels';

plot(time(1:samplesToVisualize), myEeg(:, 1:samplesToVisualize), plotColor);
title('Patient ' + patientId + ', seizure ' + dataRecord);
xlabel(xlabelText, 'FontSize', 50);
ylabel(ylabelText, 'FontSize', 50);
ylim([0, max(max(myEeg)) + 500]);
set(gca, 'Ytick', 900:900:900 * 16, 'Yticklabel', name_channel, 'Fontsize', fontSize);
time__ = time(1:samplesToVisualize);

fig = 0;
all = 0;
save = [-1, -1];
ampliary = false;
coordinatesy = coordinatesy_(myEeg, 1500);