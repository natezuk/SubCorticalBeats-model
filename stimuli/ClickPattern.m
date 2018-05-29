function y = ClickPattern(cr,pattern,stimdur,clickdur,ph,Fs,varargin)
% Nate Zuk (2017)
% Create a click train where some of the clicks are jittered in time
% Inputs:
% - cr = click rate (in beats/min)
% - pattern = a series of ones and zeros that define whether or not a
% clicks is present at the time associated with the click rate (1 = click
% present, 0 = click absent)
% - stimdur = duration of click train (in s)
% - clickdur = duration of a click (in ms)
% - ph = phase of the clicks (-0.5 to 0.5, with 0 being center)
% - Fs = sampling frequency (in Hz)
% Outputs:
% - y = waveform of click train

plsshp = [];

if ~isempty(varargin),
    for n=2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Compute click times
ct = clickPatternCalc(cr,pattern,stimdur,ph);

if isempty(plsshp), % if no particular pulse shape has been specified...
    %...use clicks
    % Compute the number of samples in a click
    clkind = round(clickdur/1000*Fs);

    % Make the pulse duration even so that there are an equal number of
    % condensation and rarefraction indexes
    if mod(clkind,2)>0, 
        clkind=floor(clkind/2)*2; 
        warning(['Changing pulse duration to ' num2str(clkind/Fs*1000) ' ms...']);
    end
    % Make a square wave pulse
    plsshp = [ones(clkind/2,1); -ones(clkind/2,1)];
else
    clkind = length(plsshp);
end

% Remove click times that would cut off the pulse shape
ct(ct>stimdur*Fs-clkind) = [];

% Create waveform array and apply clicks
y = zeros(round(stimdur*Fs),1);
for c = 1:length(ct),
    ind = round(ct(c)*Fs);
    % Check if it overlaps with another click...
    if c>1,
        if ind-round(ct(c-1)*Fs)<=clkind+1,
            % ...if so, shift the index forward so it's non-overlapping
            ind = round(ct(c-1)*Fs)+clkind+1;
        end
    end
    idxs = ind:ind+clkind-1; % indexes for click
    y(idxs) = y(idxs)+plsshp; % create click
end