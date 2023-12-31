clear;
clc;
close all;
%% Define paths
baseDirectory = "P:\WORK\David\UPF\TFM";
visualizerDirectory = fullfile(baseDirectory, "EEG_visualizer\");

%% Data under analysis
patientId = "11";
dataRecord = "003 ";

%% Load data
dataDirectory = fullfile(baseDirectory, "Data", "Seizure_Data_" + patientId);
cd(dataDirectory);
fullEeg = load(sprintf('Seizure_%03d.mat', str2double(dataRecord)));
cd(visualizerDirectory);

%% Main program

% Customizable features
secondsToVisualize = 30; % Set to inf if needed to see the whole recording
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

%% Artifact search

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

%% KEYBOARD SHORTCUTS

%--------------------------------------------------------------------------
% KEYBOARD SHORTCUTS
%--------------------------------------------------------------------------
%   - Right Arrow (Button 29):
%     - Moves the display to the right by plotting the next segment.
%
%   - Left Arrow (Button 28):
%     - Moves the display to the left by plotting the previous segment.
%
%   - Up Arrow (Button 30):
%     - Zooms in on the display by plotting a shorter time interval.
%
%   - Down Arrow (Button 31):
%     - Zooms out on the display by plotting a longer time interval.
%
%   - Plus Key (+) (Button 43):
%     - Increases the amplitude of the EEG signal.
%
%   - Minus Key (-) (Button 45):
%     - Decreases the amplitude of the EEG signal.
%
%   - I Key (105):
%     - Eliminates the y-axis limit, allowing the plot to auto-scale.
%
%   - C Key (99):
%     - Plots the complete EEG signal.
%
%   - P Key (112) + Left Mouse Click:
%     - Plots the periodogram of the selected channel.
%
%--------------------------------------------------------------------------

while fig == 0
    if ishandle(1) == 0
        fig = 1;
    end

    [x, y, button] = ginput(1)

    switch button
    case 1 % Cursor click
        save(end + 1) = y;
        if save(end - 1) ~= -1 && ~amplifyY && save(end - 1) ~= -3
            amplifyY = true;
            [eegnuevo, channel1, channel2] = canalesy(fullEeg, save(end - 1), save(end), coordinatesy);
            [eeg_plotear, time__] = actualizar_new(offset(eegnuevo), time, time__, -1, 0);
            offsetedEeg = filter_(eegnuevo, 400);
            fullEeg = offsetedEeg;
            offsetedEeg = offset(offsetedEeg);
            save(end + 1) = -1;
        end
        if save(end - 1) == -3 && ~amplifyY
            [eegnuevo, channel1, channel2] = canalesy(fullEeg, 0, save(end), coordinatesy);
            % periodogram(eeg1(channel2, :));
            [p, f] = periodogram(fullEeg(channel2, :), [], [], fs);
            plot(f,log(p))
            xlim('tight')
            xlabel('Frequency (Hz)')
            ylabel('Power')
            title(['Periodogram of channel ' + string(name_channel(channel2))]);
        end
        x;
        y;
        
    case 29 % Move to the right (Right arrow)
        save(end + 1) = -1;
        if all == 0
            [eegToShow, time_] = actualizar_new(offsetedEeg, time, time__, round(length(time__) / 2), round(length(time__) / 2));
            time__ = time_;
            plot(time_, eegToShow, plotColor);
            title('Patient ' + patientId + ', seizure ' + dataRecord);
            xlabel(xlabelText, 'FontSize', axisFontSize);
            ylabel(ylabelText, 'FontSize', axisFontSize);
            ylim([0, max(max(eegToShow)) + 500]);
            xlim([time_(1), time_(end)]);
            if amplifyY == true
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel(channel1:channel2), 'Fontsize', fontSize);
            end
            if amplifyY == false
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel, 'Fontsize', fontSize);
            end
        end
        if all == 1
            plot(time__, eegToShow, plotColor);
            title('Patient ' + patientId + ', seizure ' + dataRecord);
            xlabel(xlabelText, 'FontSize', axisFontSize);
            ylabel(ylabelText, 'FontSize', axisFontSize);
            ylim([0, max(max(eegToShow)) + 500]);
            xlim([time__(1), time__(end)]);
            if amplifyY == true
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel(channel1:channel2), 'Fontsize', fontSize);
            end
            if amplifyY == false
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel, 'Fontsize', fontSize);
            end
            all = 0;
        end

    case 28 % Move to the left (Left arrow)
        save(end + 1) = -1;
        if all == 0
            [eegToShow, time_] = actualizar_new(offsetedEeg, time, time__, -round(length(time__) / 2), -round(length(time__) / 2));
            time__ = time_;
            plot(time_, eegToShow, plotColor);
            title('Patient ' + patientId + ', seizure ' + dataRecord);
            xlabel(xlabelText, 'FontSize', axisFontSize);
            ylabel(ylabelText, 'FontSize', axisFontSize);
            ylim([0, max(max(eegToShow)) + 500]);
            xlim([time_(1), time_(end)]);
            if amplifyY == true
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel(channel1:channel2), 'Fontsize', fontSize);
            end
            if amplifyY == false
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel, 'Fontsize', fontSize);
            end
        end
        if all == 1
            plot(time__, eegToShow, plotColor);
            title('Patient ' + patientId + ', seizure ' + dataRecord);
            xlabel(xlabelText, 'FontSize', axisFontSize);
            ylabel(ylabelText, 'FontSize', axisFontSize);
            ylim([0, max(max(eegToShow)) + 500]);
            xlim([time__(1), time__(end)]);
            if amplifyY == true
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel(channel1:channel2), 'Fontsize', fontSize);
            end
            if amplifyY == false
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel, 'Fontsize', fontSize);
            end
            all = 0;
        end

    case 30 % Zoom in (Up arrow)
        save(end + 1) = -1;
        if length(time__) < 2000
            disp('Limit of zoom in has been reached');
        end
        if length(time__) >= 2000
            [eegToShow, time_] = actualizar_new(offsetedEeg, time, time__, 1000, -1000);
            time__ = time_;
            plot(time_, eegToShow, plotColor);
            title('Patient ' + patientId + ', seizure ' + dataRecord);
            xlabel(xlabelText, 'FontSize', axisFontSize);
            ylabel(ylabelText, 'FontSize', axisFontSize);
            ylim([0, max(max(eegToShow)) + 500]);
            xlim([time_(1), time_(end)]);
            if amplifyY == true
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel(channel1:channel2), 'Fontsize', fontSize);
            end
            if amplifyY == false
                set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel, 'Fontsize', fontSize);
            end
        end

    case 31 % Zoom out (Down arrow)
        save(end + 1) = -1;
        [eegToShow, time_] = actualizar_new(offsetedEeg, time, time__, -1000, 1000);
        time__ = time_;
        plot(time_, eegToShow, plotColor);
        title('Patient ' + patientId + ', seizure ' + dataRecord);
        xlabel(xlabelText, 'FontSize', axisFontSize);
        ylabel(ylabelText, 'FontSize', axisFontSize);
        ylim([0, max(max(eegToShow)) + 500]);
        xlim([time_(1), time_(end)]);
        if amplifyY == true
            set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel(channel1:channel2), 'Fontsize', fontSize);
        end
        if amplifyY == false
            set(gca, 'Ytick', yTickSpacing:yTickSpacing:yTickSpacing * totalChannels, 'Yticklabel', name_channel, 'Fontsize', fontSize);
        end
        
    case 43 % Increase amplitude (+)
        save(end+1)=-1;
        [fullEeg,eeg_new,eeg_plotear]=ampliar_amplitud(fullEeg,time,time__,1.5);
        offsetedEeg=eeg_new;
        plot(time__,eeg_plotear, plotColor)
        title('Patient ' + patientId + ', seizure ' + dataRecord);
        xlabel(xlabelText,'FontSize',axisFontSize)
        ylabel(ylabelText,'FontSize',axisFontSize)
        ylim([ 0 max(max(eeg_plotear))+500]);
        xlim([time__(1) time__(length(time__))]);
        if amplifyY==true
               set(gca, 'Ytick', [yTickSpacing:yTickSpacing:yTickSpacing*totalChannels],'Yticklabel',name_channel(channel1:channel2),'Fontsize',fontSize);
        end
        if amplifyY==false
               set(gca, 'Ytick', [yTickSpacing:yTickSpacing:yTickSpacing*totalChannels],'Yticklabel',name_channel,'Fontsize',fontSize);
        end

    case 45 % Decrease amplitude (-)
        save(end+1)=-1;
        [fullEeg,eeg_new,eeg_plotear]=ampliar_amplitud(fullEeg,time,time__,0.5);
        offsetedEeg=eeg_new;
        plot(time__,eeg_plotear, plotColor)
        title('Patient ' + patientId + ', seizure ' + dataRecord);
        xlabel(xlabelText,'FontSize',axisFontSize)
        ylabel(ylabelText,'FontSize',axisFontSize)
        ylim([ 0 max(max(eeg_plotear))+500]);
        xlim([time__(1) time__(length(time__))]);
        if amplifyY==true
               set(gca, 'Ytick', [yTickSpacing:yTickSpacing:yTickSpacing*totalChannels],'Yticklabel',name_channel(channel1:channel2),'Fontsize',fontSize);
        end
        if amplifyY==false
               set(gca, 'Ytick', [yTickSpacing:yTickSpacing:yTickSpacing*totalChannels],'Yticklabel',name_channel,'Fontsize',fontSize);
        end

    case 105 % Eliminate the ylim (I)
            if amplifyY==true
                amplifyY=false;
                ylim([ 0 max(max(offsetedEeg))+500]); %The new ylim is setted
            end
    
    case 99 % Plot the complete EEG (C)
        save(end+1)=-1;
        all=1;
        plot(time,offsetedEeg)
        title('Patient ' + patientId + ', seizure ' + dataRecord);
        xlabel(xlabelText,'FontSize',axisFontSize)
        ylabel(ylabelText,'FontSize',axisFontSize)
        ylim([ 0 max(max(offsetedEeg))+500]);
        xlim([time(1) time(length(time))]);
        if amplifyY==true
               set(gca, 'Ytick', [yTickSpacing:yTickSpacing:yTickSpacing*totalChannels],'Yticklabel',name_channel(channel1:channel2),'Fontsize',fontSize);
        end
        if amplifyY==false
               set(gca, 'Ytick', [yTickSpacing:yTickSpacing:yTickSpacing*totalChannels],'Yticklabel',name_channel,'Fontsize',fontSize);
        end
        case 112 % Plot periodogram (P + Click on desired channel)
        save(end+1)=-3;
            
    end
end


