function DV_phasePlotter(fullEeg, fs, varargin)
numVaragin = numel(varargin);

% Define channel names
[totalChannels, eegLength] = size(fullEeg);

channelNames = cell(1, totalChannels);
for i = 1:totalChannels
    channelNames{i} = ['ch' num2str(i, '%02d')];
end

plotColor = "black";
axisFontSize = 50;
channelNameFontSize = 16;
interpreter = 'latex';

set(groot,'defaultAxesTickLabelInterpreter',interpreter);
set(groot,'defaulttextinterpreter',interpreter);
set(groot,'defaultLegendInterpreter',interpreter);

hold off
plot(time,fullEeg,'Color', plotColor);
xlabel('Time (s)','FontSize',axisFontSize)
ylabel('Name of the channels','FontSize',axisFontSize)
xlim('tight')
set(gca, 'Ytick', [900:900:900*16],'Yticklabel',channelNames,'Fontsize',channelNameFontSize);
title('Seizure number '+string(seizure)+' from patient '+string(patient))
if numVaragin == 1
    limits=varargin{1};
    ylim([ limits(0)  limits(1)])
end
end