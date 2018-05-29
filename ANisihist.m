function [h,isi,MR,PSTH] = ANisihist(y,Fs,cfs,varargin)
% Computes the summed all-order ISI histogram for the spike activity of
% high-spont auditory nerve fibers between the two frequencies in cfrange. The
% auditory nerve fibers have human-like tuning (see Shera et al, 2001)
% Inputs:
%   - y = monaural input (Pascals)
%   - Fs = sampling frequency (Hz)
%   - cfs = the characteristic frequencies (CF, in Hz) of each AN fiber included in the simulation, either a range of CFs (2 elements) or specific CFs for each fiber
% Optional inputs (use 'name',value):
%   - internoise = magnitude of internal noise (sp/s)
%   - icunit = IC unit to use ('a','b','c','d', or 'e'; 'none' for just AN processing)
%   - ictype = type of IC unit ('bandpass' or 'notch')
%   - nanf = number of CFs to include if a CF range was specified in CFs.  The CFs in the range are logarithmically spaced
%   - nrep = number of times to repeat the stimulus.  Specifically for the AN model.  The outputs are averaged across repetitions (note: the program is currently set with 1/Fs samples between repetitions) 
% Outputs:
%   - h = summed ISI histogram (in # spikes)
%   - isi = interspike intervals for the ISI histogram (in s)
%   - MR = firing rate, each column is for a different unit (in sp/s)
%   - PSTH = psth of the different units
% Nate Zuk (2018)

isilast = floor(length(y)/Fs); % last isi to calculate (s)
internoise = 0; % firing rate of internal noise (added spontaneous rate, sp/s)
icunit = 'a'; % ic unit to use
ictype = 'bandpass'; % either 'bandpass' or 'notch'
nanf = 30; % # of ANFs
nrep = 1; % number of repetitions of the stimulus

% Parse varargin (optional variables are specified with 'name',value)
if ~isempty(varargin),
    for n=2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

if ~iscell(icunit), icunit = {icunit}; end % turn into cell array
if ~iscell(ictype), ictype = {ictype}; end
if length(icunit)~=length(ictype),
    error('icunit and ictype must be the same length');
end

if length(cfrange)==2,
    cfs = logspace(log10(cfrange(1)),log10(cfrange(2)),nanf); % compute the CFs of the fibers
else
    cfs = cfrange; % for a single CF or list of CFs
end
if size(y,2)==1, y = y'; end % flip y if it's a column vector

h = zeros(floor(isilast*Fs),1);

antm = tic;
MR = [];
VR = [];
PSTH = NaN(length(y),length(icunit),length(cfs));
poissdev = NaN(length(icunit),length(cfs));
parfor c = 1:length(cfs),
    disp(['CF = ' num2str(cfs(c)) ' Hz response...']);
    % run IHC model, no stimulus repetitions, human, normal IHC and OHC
    % function
    vihc = model_IHC(y,cfs(c),nrep,1/Fs,length(y)/Fs+1/Fs,1,1,2);
    % run AN synapse model, high spont, variable noise, approx. power law
    % implementation
    [mr,~,anp] = model_Synapse(vihc,cfs(c),nrep,1/Fs,3,1,0);
    % Filter the signal with a modulation filter bank, and compute ISI
    % histogram after each filter    
    if strcmp(icunit{1},'none'), % just use ANF stage
        P = anp';
    else
        P = NaN(length(y)+1,length(icunit));
        IC = NaN(length(y)+1,length(icunit));
        disp('Computing psth for each modulation filter...');
        for b = 1:length(icunit),
	    % IC stage
            extnd = round(0.02*Fs);
            mrext = [ones(1,extnd)*mr(1) mr]; % add zeros before rate response in order
                % to account for the initial artifact in the SFIE response
            if strcmp(ictype{b},'bandpass'),
                ic = SFIE_BE_BS(mrext,icunit{b},Fs,sfiestats);
                ic = ic(extnd+1:end-300); % remove artifact and extra zeros because of IC inhibition delay
            elseif strcmp(ictype{b},'notch'),
                [~,ic] = SFIE_BE_BS(mrext,icunit{b},Fs,sfiestats);
                ic = ic(extnd+1:end-370); % there are additional zeros at the end if it's a notch neuron
            elseif strcmp(ictype{b},'none'), % no IC stage
                ic = mr;
            end
            % Add noise (non-zero spontaneous rate)
            ic = ic + internoise;
            % Compute psth at firing rate
            psth = poissrnd(ic/Fs);
            % Compute ISI histogram
            P(:,b) = psth';
            IC(:,b) = ic';
        end
    end
    MR = [MR ic'];
    PSTH(:,:,c) = P(1:length(y),:);
end
disp('Now computing total ISI histogram by autocorrelation of sum of spikes...');
sP = sum(sum(PSTH,3),2);
[h,lags] = xcorr(sP);
h = h(lags>=0);
isi = lags(lags>=0)'/Fs;

disp(['Completed @ ' num2str(toc(antm)) ' s']);
