% Calculate the synchronization tempo and vector strength for a recording of music
% Nate Zuk (2018)

% Stimulus parameters
Fs = 100000; % sampling frequency (Hz)
%pth = '~/BallroomData/';
cfs = 125*2.^(0:0.05:6);
%icunit = 'a';
%ictype = 'bandpass';
%tol = 0.04;

% Load waveform
disp(['wn=' wn]);
y = segwav(wn,Fs);

y = setdB(y,70); % set to 70 dB SPL

% Simulate brainstem-level activity
[h,isi,~,PSTH,~] = ANisihist(y,Fs,cfs,'icunit',icunit,'ictype',ictype);

% Compute the fourier transform of the summed spike activity (quantifies synchronization strength)
wnd = beatwindow(tol,Fs);
sP = sum(squeeze(PSTH),2);
smP = conv(sP,wnd,'same'); % smooth the PSTH using a gaussian temporal window
fftsmP = fft(smP);
vssmP = abs(fftsmP)/abs(fftsmP(1));
fftP = fft(sP); % compute vector strength based on original (non-smoothed) psth
vsP = abs(fftP)/abs(fftP(1));
f = (0:length(vsP)-1)/length(vsP)*Fs; % frequency array

% Get beat times based on FFT of summed neural activity
tctinds = f>0.5&f<10; % search within a range of possible tacti
vssmPtct = vssmP(tctinds); ftct = f(tctinds); % smoothed PSTH
mxind = find(vssmPtct==max(vssmPtct),1,'first');
fftmxsm = ftct(mxind);
vsPtct = vsP(tctinds); % non-smoothed vector strength
mxind = find(vsPtct==max(vsPtct),1,'first');
fftmx = ftct(mxind);

% Identify the phase of the beats
fftph = beatmatch(fftmx*60,sP,Fs,'tol',tol);

% Compute the beat salience based on the ISI histogram
rats = [1/16 1/12 1/9 1/8 1/6 1/4 1/3 1/2 2/3 3/4 1];
hrms = fftmx*rats;

% Compute the ISI ratios for multiples of the event period
isirat = NaN(length(hrms),1);
isicnt = NaN(length(hrms),1);
for ii = 1:length(hrms),
    [isirat(ii),isicnt(ii)] = isicount(h,isi,1/hrms(ii));
end

% Compute the VS for ratios of the event frequency
vsrat = NaN(length(hrms),1);
for ii = 1:length(hrms),
    fdiff = abs(f-hrms(ii));
    vsrat(ii) = vsP(find(fdiff==min(fdiff),1,'first'));
end

% Create a spike-count-gram for each beat
% [cntgram,bttimes] = beatspikecnt(squeeze(PSTH),Fs,1/fftmx,fftph);

% Only grab the frequency and vs values between 0.5 and 10 Hz
fseg = f(f>=0.5&f<=10);
vsseg = vsP(f>=0.5&f<=10);

[spth,name,~] = fileparts(fn); % only get the file name, no extension
save([spth '/' name '.mat'],'fftph','fftmx','fftmxsm','hrms','vsrat','isirat','isicnt','fseg','vsseg')
