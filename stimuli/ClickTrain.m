function [y,ct] = ClickTrain(cr,jit,subdev,stimdur,clickdur,ph,Fs,varargin)
% Nate Zuk (2018)
% Create a click train where some of the clicks are jittered in time
% Inputs:
% - cr = click rate (in beats/min)
% - jit = % jitter (100% means +/- 1/2 click period)
% - subdev = clicks that should *not* be jittered (0 = regular sequence, 
% 1 = every click is jittered, 2 = every other click is jittered, etc.)
% - stimdur = duration of click train (in s)
% - clickdur = duration of a click (in ms)
% - ph = phase of the clicks (-0.5 to 0.5, with 0 being center)
% - Fs = sampling frequency (in Hz)
% Outputs:
% - y = waveform of click train
% - ct = click times (in s)

plsshp = [];

% Parse varargin (useing 'name',value pairings)
if ~isempty(varargin),
    for n=2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Compute click times
ct = clickJitCalc(cr,jit,subdev,stimdur,ph);

if isempty(plsshp),
    % Compute the number of samples in a click
    evtind = round(clickdur/1000*Fs);

    % Make the pulse duration even so that there are an equal number of
    % condensation and rarefraction indexes
    if mod(evtind,2)>0, 
        evtind=floor(evtind/2)*2; 
        warning(['Changing pulse duration to ' num2str(evtind/Fs*1000) ' ms...']);
    end
    % Make the pulse
    plsshp = [ones(evtind/2,1); -ones(evtind/2,1)];
else
    evtind = length(plsshp); % use the number of indexes in the event provided
end

% Check if any clicks start outside of the stimulus duration, if so remove
% them
outofbounds = ct*Fs+length(plsshp)>stimdur*Fs;
ct(outofbounds) = [];

% Create waveform array and apply clicks
y = zeros(round(stimdur*Fs),1);
for c = 1:length(ct),
    ind = round(ct(c)*Fs);
    % Check if it overlaps with another click...
    if c>1,
        if ind-round(ct(c-1)*Fs)<=evtind+1,
            % ...if so, shift the index forward so it's non-overlapping
            ind = round(ct(c-1)*Fs)+evtind+1;
        end
    end
    idxs = ind:ind+evtind-1; % indexes for click
    y(idxs) = y(idxs)+plsshp; % create click
end