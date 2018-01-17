function y = brickfilter(x,frange,Fs)
% Filter the signal x with a brick filter
% Inputs:
% - x = input signal
% - frange = two values for the [lower upper] frequencies of the passband
% for the filter (Hz)
% - Fs = sampling frequency (Hz)
% Nate Zuk (2018)

X = fft(x);
f = (0:length(X)-1)/length(X)*Fs; % frequency array
useinds = (f>=frange(1)&f<=frange(2))|(f>=Fs-frange(2)&f<=Fs-frange(1));
    % identify indexes to uses in the filter, symmetrical for real signals
X(~useinds)=0; % set amplitudes of all other frequencies to zero
y = real(ifft(X));