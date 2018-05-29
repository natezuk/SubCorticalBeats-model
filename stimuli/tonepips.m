function [y,piptms] = tonepips(tempo,carrfreq,pipdur,ph,dur,Fs)
% Produces a waveform consisting of raised-sine tone pips.
% Inputs:
% - tempo = tempo of the tone pips (BPM)
% - carrfreq = tone frequency (Hz)
%     if carrfreq is two numbers, use carrier noise filtered between those
%     two frequencies; if carrfreq is empty, then use broadband, unfiltered noise
% - pipdur = duration of each tone pip (s)
% - ph = phase of tone pips, relative to tempo (cycles)
% - dur = duration of stimulus (s)
% - Fs = sampling frequency (Hz)
% Outputs:
% - y = wavefrom
% - piptms = times for each of the tone pips (in s)
% Nate Zuk (2018)

t = (0:dur*Fs-1)/Fs; % time array for stimulus
phcarr = rand(1)-0.5; % randomly select the phase of the carrier
if length(carrfreq)==1,
    carr = cos(2*pi*t*carrfreq+phcarr*2*pi); % carrier waveform
elseif length(carrfreq)==2, % if the carrier frequency is a range, use a noise carrier brick filtered in that range
    ns = randn(1,dur*Fs);
    carr = brickfilter(ns,carrfreq,Fs);
elseif isempty(carrfreq), % if empty, use broadband noise
    carr = randn(1,dur*Fs);
end

tpip = (0:pipdur*Fs-1)/(pipdur*Fs); % time array for duration of pip (max 1 cycle)
wnd = 0.5*(1-cos(2*pi*tpip)); % modulation for each pip
[am,piptms] = ClickTrain(tempo,0,0,dur,[],ph,Fs,'plsshp',wnd'); % create modulation signal for tone pips

y = am.*carr';