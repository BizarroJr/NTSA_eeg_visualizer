function [] = plots(eeg,time,patient,seizure,varargin)
num=numel(varargin);

% Define channel names
[M, N] = size(eeg);
totalChannels = M;
channelNames = cell(1, totalChannels);
for i = 1:totalChannels
    channelNames{i} = ['ch' num2str(i, '%02d')];
end

plotColor = "black";
axisFontSize = 50;
channelNameFontSize = 12;
interpreter = 'latex';

set(groot,'defaultAxesTickLabelInterpreter',interpreter);
set(groot,'defaulttextinterpreter',interpreter);
set(groot,'defaultLegendInterpreter',interpreter);

hold off
plot(time,eeg,'Color', plotColor);
xlabel('Time (s)','FontSize',axisFontSize)
ylabel('Name of the channels','FontSize',axisFontSize)
xlim('tight')
set(gca, 'Ytick', [900:900:900*16],'Yticklabel',channelNames,'Fontsize',channelNameFontSize);
title('Seizure number '+string(seizure)+' from patient '+string(patient))
if num==1
    limits=varargin{1};
    ylim([ limits(1)  limits(2)])
elseif ((num==2) || (num==3))
    tstart=varargin{1}; %The times in which the dropout starts
    tend=varargin{2}; %The times in which the dropout finishes
    locStart=ismember(time, tstart); %The locations of these times in the current window are searched
    timestoplotStart=time(locStart);
    locEnd=ismember(time, tend); %The locations of these times in the current window are searched
    timestoplotEnd=time(locEnd);
    if isempty(timestoplotStart)==false
        hold on
        plot(timestoplotStart,eeg(:,locStart),'o','Color','green')
    end
    if isempty(timestoplotEnd)==false
        hold on
        plot(timestoplotEnd,eeg(:,locEnd),'*','Color','magenta')
    end
    if num==2
        ylim([ 0 max(max(eeg))+500])
    else
        limits=varargin{3};
        ylim([ limits(1)  limits(2)])
    end
else
    ylim([ 0 max(max(eeg))+500])
end
end