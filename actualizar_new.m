function [eeg_out,time_out] = actualizar_new(eeg,time,time_,offset_1,offset_2)
    ultimo_tiempo=time_(length(time_));
    ult=0;

    for i=1:length(time)
        if time(i)==ultimo_tiempo
            ult=i;
        end
    end
    range=[ult+offset_1-length(time_)+1,ult+offset_2-1];
    if range(1)<1
        range=[1, length(time_)];
    end
    if range(2)>length(eeg(1,:))
        range=[length(eeg(1,:))-length(time_),length(eeg(1,:))];
    end
    eeg_out=eeg(:,range(1):range(2));
    time_out=time(range(1):range(2));

end

