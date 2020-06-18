function yscal = setdB(y,dBval)
% Scale the RMS of y to a particular dB SPL value
% Nate Zuk (2017)

scal = 10^(dBval/20)*2e-5; % scaling factor from V to dB SPL
yscal = y/rms(y)*scal; % convert the waveform to dB SPL