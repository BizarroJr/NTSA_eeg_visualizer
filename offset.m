function [eeg_offset] = offset(eeg)
% This function adds an offset to plot crearly the different channels
% INPUT:
%     - eeg: Original EEG
% OUTPUT:
%     - eeg_offset: Original EEG with added offsets
    eeg_offset=zeros(size(eeg));
    [M,N]=size(eeg);
    for j=1:M
         eeg_offset(j,:)=eeg(j,:)+j*900;
    end
end

