function y = amnoise(modfreq,ph,dur,Fs,varargin)
% Create AM noise, with a raised-sine on/off ramp
% Inputs:
% - modfreq = modulation frequency (Hz). If modfreq contains two numbers
% then the envelope is created by filtering noise between those two
% frequencies using a brick filter
% - ph = cosine phase of the modulation (cycles) 
% - dur = duration of the sound (s)
% - Fs = sampling frequency (Hz)
% Outputs:
% - y = vector containing the AM noise signal
% Nate Zuk (2018)

ramptime = 15; % time to ramp the signal on and off (in ms)

% Parse varargin (using 'name',value pairing)
if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Create the initial signal
ns = randn(dur*Fs,1); % noise carrier
t = (0:dur*Fs-1)/Fs; % time array

% Create the modulation
if length(modfreq)==1,
    am = 0.5*(1+cos(2*pi*t*modfreq+2*pi*ph))'; % modulation
elseif length(modfreq)==2, % filter between those two frequencies for the envelope
    rndenv = randn(dur*Fs,1);
    RNDENV = fft(rndenv);
    f = (0:length(RNDENV)-1)/length(RNDENV)*Fs;
    idx = (f>=modfreq(1)&f<=modfreq(2))|(f<=Fs-modfreq(1)&f>=Fs-modfreq(2));
        % need to filter evenly on both sides of Fs/2 for real signals
    RNDENV(~idx) = 0; % remove those frequencies
    rndenv = real(ifft(RNDENV));
    rndenv = (rndenv-mean(rndenv))/range(rndenv)*2; % remove the mean and set to a range = 2
    am = 0.5*(-min(rndenv)+rndenv); % set to a range of 0 to 1
end
% Apply the modulation to the noise carrier
y = ns.*am;

% Apply the ramp
tramp = (0:ramptime/1000*Fs-1)/Fs/(ramptime/1000); % time relative to ramptime (1=ramptime)
ramp = 0.5*(1-cos(2*pi*tramp/2));
w = [ramp'; ones(length(y)-2*length(ramp),1); fliplr(ramp)'];
y = y.*w;