function [eeg_offset_off,eeg_offset_on,eeg_plotear,time__] = ampliar_amplitud(eeg,time,time__,factor)
% The aim of this function is to increase or decrease the amplitude of the signals
% INPUTS:
%     - eeg: Initial EEG without offsets
%     - time: Complete time vector
%     - time__: Time vector plotted currently
%     - factor: Factor to amplify or decrease the amplitude
% OUTPUTS:
%     - eeg_offset_off: Complete EEG with the change in amplitude without offset
%     - eeg_offset_on: Complete EEG with the change in amplitude with offset
%     - eeg_plotear: EEG with the change in amplitude to plot in the current window
    eeg_offset_off=eeg*factor; %The change in amplitude is applied
    eeg_offset_on=offset(eeg_offset_off); %The offset is added
    [eeg_plotear,time__]=actualizar_new(eeg_offset_on,time,time__,0,0); %The window is extracted
end

