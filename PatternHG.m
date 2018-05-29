% Calculate the vector strength resulting from the ANFbeats model using
% stimuli from Henry et al (2017).
% Calculating for the 5 patterns from Nozaradan et al (2012) for now.
% Nate Zuk (2018)

% Initial variables
Fs = 100000; % sampling frequency (Hz)
    % program crashes for sampling rate 44.1 kHz
dur = 9.8; % duration of click train (s)
clkdur = 1; % duration of clicks (ms)
%icunit = 'a';
%tol = 0.04;
% Specify the CF range for the AN fibers and the number of fibers
cfs = 125*2.^(0:0.05:6);

chktempos = [0.25 0.5 1]; % ratios of tempo to check VS

%tempo = 300; % (BPM)
henrygrahnpatternlist; % load list of Povel & Essens patterns
pattern = patterns{patnum};

rng('shuffle')
ph = rand(1)-0.5; % randomly pick phase of clicks
% ph = 0; % no phase shift in the rhythm (that can affect perceived beat strength)

% Randomly shift the pattern
% shft = randi([0 length(pattern)]);
shft = 0; % don't shift the pattern of the rhythm (that can affect perceived beat strength)
pt = circshift(pattern,shft);

% Create the stimulus
%pls = nozaradanpulse(1000,50,10,Fs)';
pls = povelessenspulse(990,plsdur*1000,10,Fs); % setup as in Henry & Grahn
% pls = randn(plsdur*Fs,1); % use repeating broadband noise for the pulse
y = ClickPattern(tempo,pt,dur,clkdur,ph,Fs,'plsshp',pls);

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
spmn = abs(fftP(1))/length(fftP);
% Store only the vector strength at the tempo
f = (0:length(fftP)-1)/length(fftP)*Fs;
tempoind = find(abs(f-tempo/60)==min(abs(f-tempo/60)),1,'first');
vstempo = vsP(tempoind);
% Find the maximum vector strength between 30 and 600 BPM
fseg = f(f>=0.5&f<=10);
vsseg = vsP(f>=0.5&f<=10);
mxvs = vsseg(vsseg==max(vsseg));
mxf = fseg(vsseg==max(vsseg));
% Find the VS at fractions of the tempo
vschk = NaN(length(chktempos),1);
for ii = 1:length(chktempos),
    tempoind = find(abs(f-tempo/60*chktempos(ii))==min(abs(f-tempo/60*chktempos(ii))),1,'first');
    vschk(ii) = vsP(tempoind);
end

% Compute the phase of the frequency with the maximum vector strength
fftmx = fftP(f==mxf);
predph = angle(fftmx)/(2*pi); % predicted phase of the beat (in cycles)

save(fn,'pattern','tempo','ph','shft','vstempo','mxvs','mxf','predph','vschk','chktempos','fseg','vsseg')
