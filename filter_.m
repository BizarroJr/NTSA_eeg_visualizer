% Applies a notch filter to each channel of EEG data to attenuate a specific 
% frequency component, typically the power line interference at 50 Hz 
% (or 60 Hz in some regions).
% eeg - matrix with signals to be filtered
% fs - sampling frquency
function [eeg] = filter_(eeg,fs)
    fnyq=fs/2;
    fnotch=50;
    for j=1:length(eeg(:,1))
        [b,a]=iirnotch(fnotch/fnyq,fnotch/fnyq/20); %q factor of 20
        eeg(j,:)=filtfilt(b,a,eeg(j,:));
    end
end

