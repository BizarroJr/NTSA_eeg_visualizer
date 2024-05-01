function filtered_signal = DV_BandPassFilter(signal, fs, type)
    % DV_BandPassFilter: Apply Butterworth bandpass filter to a signal
    %
    % Inputs:
    %   signal: Input signal
    %   fs: Sampling frequency (Hz)
    %   f_low: Lower cutoff frequency of the filter (Hz)
    %   f_high: Higher cutoff frequency of the filter (Hz)
    %   order: Filter order (default is 4)
    %
    % Output:
    %   filtered_signal: Filtered output signal

    % if nargin < 5
    %     order = 4; % Default filter order
    % end

    % % Normalize the cutoff frequencies with respect to the Nyquist frequency
    % f_nyquist = fs / 2;
    % Wn = [f_low/f_nyquist, f_high/f_nyquist];
    % 
    % [b, a] = butter(order, Wn, 'bandpass');
    % 
    % % Apply the filter to the input signal
    % % filtered_signal = filter(b, a, signal); %Without zero-phase filtering
    % filtered_signal = filtfilt(b, a, signal);
    
    if type == 2 % LPF
        freqLF = [4 30];
        orderLF = round(3*(fs/freqLF(1))); % filter order for LF

        fir1CoefLF = fir1(orderLF,[freqLF(1),freqLF(2)]./(fs/2)); % filter coeff. for LF
        filtered_signal = filtfilt(fir1CoefLF,1,signal);
    elseif type == 3 % HPF
        freqHFO = [80 150];
        orderHFO = round(3*(fs/freqHFO(1))); % filter order for HFO

        fir1CoefHFO = fir1(orderHFO,[freqHFO(1),freqHFO(2)]./(fs/2)); % filter coeff. for HFO
        filtered_signal = filtfilt(fir1CoefHFO,1,signal);
    elseif type == 1 % No filter
        filtered_signal = signal;
    end
end
