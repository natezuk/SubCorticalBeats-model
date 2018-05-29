% Calculate the synchronization tempo and vector strength for a click train
% Nate Zuk (2018)

% Initial variables
Fs = 100000; % sampling frequency (Hz)
    % program crashes for sampling rate 44.1 kHz
% dur = 10; % duration of click train (s)
clkdur = 1; % duration of clicks (ms)
% Specify the CF range for the AN fibers and the number of fibers
cfs = 125*2.^(0:0.05:6);
%icunit = 'a';
%ictype = 'notch';
% Randomly select a phase for the clicks
rng('shuffle');
ph = rand(1)-0.5;

tempos = 30:30:600; % list of tempos to check, in BPM

sv = NaN(length(tempos),1); % to store isi densities
vstempo = NaN(length(tempos),1);
spmn = NaN(length(tempos),1);
for t = 1:length(tempos)
    % Create the stimulus
    disp(['Starting BeatSal: tempo = ' num2str(tempos(t)) ' BPM...'])
    y = ClickTrain(tempos(t),0,0,dur,clkdur,ph,Fs);

    % Convert y to dB SPL
    pamag = 70; % dB
    py = setdB(y,pamag);

    % Compute the summed ISI histogram
    [h,isi,~,PSTH] = ANisihist(py,Fs,cfs,'icunit',icunit,'ictype',ictype);
    
    % Compute the FFT of the ISI histogram
    wnd = beatwindow(tol,Fs);
    PSTH = sum(squeeze(PSTH),2);
    PSTH = conv(PSTH,wnd,'same'); % smooth the PSTH with the 40 ms window
    fftP = fft(PSTH);
    vsP = abs(fftP)/abs(fftP(1));
    spmn(t) = abs(fftP(1))/length(fftP);
    % Store only the vector strength at the tempo
    f = (0:length(fftP)-1)/length(fftP)*Fs;
    tempoind = find(abs(f-tempos(t)/60)==min(abs(f-tempos(t)/60)),1,'first');
    vstempo(t) = vsP(tempoind);
end

save(fn,'sv','tempos','dur','clkdur','ph','vstempo','spmn');
