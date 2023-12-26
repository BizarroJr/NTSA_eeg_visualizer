function [eeg_offset_off,eeg_offset_on,eeg_plotear] = ampliar_amplitud(eeg,time,time__,factor)
%     eeg_ampliado=eeg*factor;
    eeg_offset_off=eeg*factor;
    eeg_offset_on=offset(eeg_offset_off);
    [eeg_plotear,time__]=actualizar_new(eeg_offset_on,time,time__,-1,0);
end

