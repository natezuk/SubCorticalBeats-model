function pls = povelessenspulse(carr,plsdur,rftime,Fs)
% Create a square wave pulse like in Povel & Essens (1985) and Henry & Grahn (2017)
% Inputs:
%   - carr = carrier frequency (Hz)
%   - dur = pulse duration (ms)
%   - rftime = rise time (ms)
%   - Fs = sampling frequency (Hz)
% Outputs:
%   - pls = signal containing the pulse train
% Nate Zuk (2018)

% Create the pulse
t = 0:1/Fs:(plsdur/1000-1/Fs);
pls = sin(2*pi*carr*t)';

% Apply rise-fall time
rf = rftime/1000;
fr = 1/(rf*2);
tr = (0:rf*Fs-1)/Fs;
ramp = -0.5*cos(2*pi*fr*tr)+0.5;
rlen = length(ramp); % number of indexes in the ramp
w = [ramp ones(1,length(pls)-2*rlen) fliplr(ramp)]';
pls = pls.*w;