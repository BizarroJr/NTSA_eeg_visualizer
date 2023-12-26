
function visualizeEEG(fs,EEG,window_size,step,amplifier)
    
% ********** INPUTS **********
    
    %fs: sampling frequency
    %EEG: matrix with EEG channels in each column
    %window_size: time size of the window to visualize
    %step: time step to move forward in time through the EEG signals.
    
 % ****************************

    % Num of channels to display
    num_channels = size(EEG,2);
   
    % Time vector
    timeSeries = (1:length(EEG(:,1)))/(fs);

    % Initial contitions
    start_time = 1;
    end_time = window_size*fs;
    time_window = start_time:end_time;
    m = (max(max(abs(EEG))))/2;
    offsets = (ones(length(time_window),1)*(1:num_channels) - 1)*m;
    figure("Name",'Visualization tool','WindowState','maximized')

    % First plot
    subplot('Position',[0.05 0.05 0.94 0.95])
    plot(timeSeries(time_window), EEG(time_window,1:num_channels) + offsets(:,1:num_channels),'black');

    % Location of the yticks
    yticks(offsets(1,1:num_channels))

    % Names of the channels
    yticklabels(1:num_channels)
    ylim([min(min(EEG(:,1:num_channels))) max(offsets(1,1:num_channels))-min(min(EEG(:,1:num_channels)))])        
   
    a = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a,'fontsize',8)
    xlabel('Time [s]')
    ylabel('Amplitude of each channel activity [a.u.]')

    interval = step*fs;
    button=0;
    while (true) 
        
        [~,~,button] = ginput(1);
        % Press right arrow
        
        if (button == 29 && end_time < length(EEG(:,1))-interval)
            start_time = start_time + interval;
            end_time = end_time + interval;
            time_window = start_time:end_time;
            clf
            subplot('Position',[0.05 0.05 0.94 0.95])
            plot(timeSeries(time_window), amplifier*EEG(time_window,1:num_channels) + offsets(:,1:num_channels),'black');
            ylim([min(min(EEG(:,1:num_channels))) max(offsets(1,1:num_channels))-min(min(EEG(:,1:num_channels)))])
            %Location of the y ticks
            yticks(offsets(1,1:num_channels))
            %Y ticks 
            yticklabels(1:num_channels)
            a = get(gca,'YTickLabel');
            set(gca,'YTickLabel',a,'fontsize',8)
            xlabel('Time [s]')
            ylabel('Amplitude of each channel activity [a.u.]')
            
        %Press left arrow
        elseif (button == 28 && start_time ~= 1)
            start_time = start_time - interval;
            end_time = end_time - interval;
            time_window = start_time:end_time;
            clf
            subplot('Position',[0.05 0.05 0.94 0.95])
            plot(timeSeries(time_window), amplifier*EEG(time_window,1:num_channels) + offsets(:,1:num_channels),'black');
            ylim([min(min(EEG(:,1:num_channels))) max(offsets(1,1:num_channels))-min(min(EEG(:,1:num_channels)))])
            %Location of the Y ticks
            yticks(offsets(1,1:num_channels))
            %Y ticks 
            yticklabels(1:num_channels)
            a = get(gca,'YTickLabel');
            set(gca,'YTickLabel',a,'fontsize',8)
            xlabel('Time [s]')
            ylabel('Amplitude of each channel activity [a.u.]')
        
        elseif (button == 43) 
           amplifier=amplifier+1;
           clf
           subplot('Position',[0.05 0.05 0.94 0.95])
           plot(timeSeries(time_window), amplifier*EEG(time_window,1:num_channels) + offsets(:,1:num_channels),'black');
           ylim([min(min(EEG(:,1:num_channels))) max(offsets(1,1:num_channels))-min(min(EEG(:,1:num_channels)))])
           %Location of the Y ticks
           yticks(offsets(1,1:num_channels))
           %Y ticks 
           yticklabels(1:num_channels)
           a = get(gca,'YTickLabel');
           set(gca,'YTickLabel',a,'fontsize',8)
           xlabel('Time [s]')
           ylabel('Amplitude of each channel activity [a.u.]')
        
        elseif (button == 45) 
           if  amplifier>=1
               amplifier=amplifier-1;
               clf
               subplot('Position',[0.05 0.05 0.94 0.95])
               plot(timeSeries(time_window), amplifier*EEG(time_window,1:num_channels) + offsets(:,1:num_channels),'black');
               ylim([min(min(EEG(:,1:num_channels))) max(offsets(1,1:num_channels))-min(min(EEG(:,1:num_channels)))])
               %Location of the Y ticks
               yticks(offsets(1,1:num_channels))
               %Y ticks 
               yticklabels(1:num_channels)
               a = get(gca,'YTickLabel');
               set(gca,'YTickLabel',a,'fontsize',8)
               xlabel('Time [s]')
               ylabel('Amplitude of each channel activity [a.u.]')
           end 

        elseif (button == 27)
            close all
            break
        end

    end

end

