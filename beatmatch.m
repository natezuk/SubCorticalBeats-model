function [ph,beats,nrmcnt] = beatmatch(tempo,PSTH,Fs,varargin)
% Compute the most appropriate phase for beats based on the specified tempo
% and the neural activity in PSTH.  The phase is computed by adding the
% neural activity across PSTH and finding the phase of gaussian windows
% that maximizes the density of spikes within the sieve relative to the
% total number of spikes
% Nate Zuk (2018)

phstep = 0.01; % steps between ph values (cycles)
tol = 0.04; % width of the sieve window (s)

if ~isempty(varargin),
    for n=2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Sum together the spike trains
pdim = size(PSTH);
sP = PSTH;
for ii = length(pdim):-1:2,
    sP = sum(sP,ii);
end

% Create the gaussian window for the beat sieve
dt = 1/Fs; % sampling period
wndsz = 2*floor(4*tol/dt)+1; % specify a window size that is 4 stds in either direction
wis = ceil(-wndsz/2):floor(wndsz/2);
wnd = normpdf(wis,0,tol/dt)'; % create gaussian window with desired tolerance

% Find the appropriate window times for this tempo with 0 phase
% Extend the tracker so that there are an integer
ncycles = ceil(pdim(1)/(60/tempo*Fs));
initbeats = round((0:ncycles)*60/tempo*Fs+1); % initial beat times, by index
bttrack = zeros(ceil(ncycles*60/tempo*Fs),1);
for t = 1:length(initbeats),
    % Place a window for each beat
    center = initbeats(t); % index of window center
    inds = wis+center;
    idchk = inds>0&inds<=pdim(1); % only use indexes within the PSTH duration
    bttrack(inds(idchk)) = wnd(idchk); % place the window
end

% Normalize bttrack so the max value is 1
bttrack = bttrack/max(bttrack);

% Find the best phase
phset = 0:phstep:1;
nrmcnt = NaN(length(phset),1);
indshft = round(phset*60/tempo*Fs); % convert phase to index
parfor n = 1:length(indshft),
    trk = circshift(bttrack,indshft(n));
    fltP = sP.*trk(1:length(sP));
    nrmcnt(n) = sum(fltP)/sum(sP);
end
ph = phset(find(nrmcnt==max(nrmcnt),1,'first')); % best phase
disp(['Phase = ' num2str(ph)]);

if nargout>1,
% Calculate the beat times for the best phase
beats = (initbeats-1)/Fs+ph*60/tempo;
beats = beats(beats<=pdim(1)/Fs); % only take beat times within the stimulus duration
end
