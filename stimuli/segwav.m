function y = segwav(fn,desFs,trange)
% Load a sound file, grab only a particular time range of the sound file,
% and resample the sound file to a desired sampling frequency
% Inputs:
%   - fn = filename (include the extension)
%   - desFs = desired sampling frequency (Hz)
%   - trange = range of time to grab from the sound file (s)
%       (no values: grab entire file, 1 value: grab up to that time, 2
%       values: grab within that time range)
% Outputs: 
%   - y = the sound file waveform at the desired sampling frequency (averaged across channels)
% Nate Zuk (2018)

% Load the wav file
[s,Fs] = audioread(fn);

% Turn the waveform into one channel by averaging across channels
s = mean(s,2);

% Grab the desired time range
t = (0:length(s)-1)/Fs;
disp(['Sound file is ' num2str(length(s)/Fs) ' s long']);
if nargin==3,
    if t(end)<trange(end),
        error('Time range extends beyond wavefile duration');
    end
    if length(trange)==1,
        tind = t<=trange(1);
    elseif length(trange)==2,
        tind = t>=trange(1)&t<=trange(2);
    else
        warning('Trange must contain 1 or 2 values. Using only the 1st 2 values...');
        tind = t>=trange(1)&t<=trange(2);
    end
    s = s(tind); % only grab waveform samples within the time range
end

dur = length(s)/Fs; % duration of sound file before resampling, 
    % will be used to get appropriate sound duration after resampling

% Add the last sampling point a second time in order to avoid
% interpolation artifacts
s = [s; s(end)];

% Resample the waveform
disp('Now resampling waveform...');
rstm = tic;
y = resample(s,desFs,Fs);
disp(['Completed resampling @ ' num2str(toc(rstm)) ' s']);
% Remove the last samples which were added during the interpolation process
desend = round(dur*desFs);
y = y(1:desend);