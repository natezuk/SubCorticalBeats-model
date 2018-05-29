% Calculate the beat salience for a particular tempo or polyrhythm
% Nate Zuk (2018)

% Initial variables
Fs = 100000; % sampling frequency (Hz)
    % program crashes for sampling rate 44.1 kHz
dur = 10; % duration of click train (s)
wnddur = 100; % duration sinusoidal window (ms)
% Specify the CF range for the AN fibers and the number of fibers
cfs = 125*2.^(0:0.05:6);
%tol = 0.04;

rng('shuffle');
temporange = [60 240]; % raised the upper limit of tempos
%carr1range = [125 4000]; % range of possible carrier frequencies (Hz)
tempo1 = rand(1)*diff(temporange)+temporange(1); % modulation frequency of tone 1(BPM)
tempo2 = rand(1)*diff(temporange)+temporange(1); % MF of tone 2
%carr1 = rand(1)*diff(carr1range)+carr1range(1); % low frequency carrier (Hz)
%carr2range = [carr1*2 min(carr1*8,8000)]; % higher frequency carrier
   % at least one octave and and most 3 octaves above carr1
%carr2 = rand(1)*diff(carr2range)+carr2range(1);
carr1logrange = [0 5]; % octave multipliers of 125 Hz to choose for low freq carrier (Hz)
carr1exp = rand(1)*diff(carr1logrange);
carr2exp = rand(1)*diff([carr1exp+1 6])+carr1exp+1; % up to 8 kHz (NZ, 1/5/2018)
carr1 = 125*2.^(carr1exp);
carr2 = 125*2.^(carr2exp);
ph1 = rand(1)-0.5; % phase of modulation 1
ph2 = rand(1)-0.5; % phase of modulation 2

% Create the stimulus
y1 = tonepips(tempo1,carr1,wnddur/1000,ph1,dur,Fs);
y2 = tonepips(tempo2,carr2,wnddur/1000,ph2,dur,Fs);
y = y1+y2;

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
spnm = abs(fftP(1))/length(fftP);
% Store the maximum vector strength between 30 and 300 BPM
f = (0:length(vsP)-1)/length(vsP)*Fs;
idx = f>=0.5&f<=5;
fseg = f(idx);
vsseg = vsP(idx);
mx = max(vsseg);
fmx = fseg(find(vsseg==max(vsseg),1,'first'));

save(fn,'mx','fmx','spnm','tempo1','tempo2','carr1','carr2','ph1','ph2');
