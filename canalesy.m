function [eegnuevo,channel1,channel2] = canalesy(eeg,indice1,indice2,coordinatesy)
channel1=1;
if indice1>indice2
    a=indice1;
    b=indice2;
    indice2=a;
    indice1=b;
    
end
for i=2:length(coordinatesy)
    if coordinatesy(i-1)<=indice1 & coordinatesy(i)>=indice1
        
        if i==2
            channel1=1
        end
       
        if i~=2
            channel1=i
        end
    end
    if coordinatesy(i-1)<=indice2 & coordinatesy(i)>=indice2
        channel2=i-1
    end
end
if channel1>channel2
    channel2=channel1;
end
eegnuevo=eeg(channel1:channel2,:);

end

