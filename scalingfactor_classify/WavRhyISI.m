% Load the frequency-normalized vector strengths for each Ballroom dance
% song and perform PCA and clustering to identify patterns
% Nate Zuk (2018)

addpath('~/EEGanly');

% Load the model responses
disp('Loading results...');
pth = '~/ANFres/WavRhy_res/ballroom_sm';
[res,~] = anbresload(pth,{'fftmx','hrms','isirat'});
FFTMX = res{1}; % fft-based maximum
HRMS = res{2}; % frequency vector
ISIRAT = res{3}; % vector strength array
% Get the wav file names for each results file
fls = what(pth);
mats = fls.mat;
wnms = cell(length(FFTMX),1);
for m = 1:length(mats)
    dashind = strfind(mats{m},'_'); % following 'WavSal'
    dotind = strfind(mats{m},'.'); % before extension
    wnms{m} = mats{m}(dashind(4)+1:dotind-1);
end

% Load the ground truth tempos
disp('Loading ground truth tempos...');
gtpth = '~/BallroomAnnotations/ballroomGroundTruth';
gtfls = dir(gtpth);
gtfls = gtfls(3:end); % ignore . and .. entries
gtnms = cell(length(gtfls),1);
gttempo = NaN(length(gtfls),1);
for ii = 1:length(gtfls)
    % Save the file name
    dotind = strfind(gtfls(ii).name,'.');
    gtnms{ii} = gtfls(ii).name(1:dotind-1);
    % Load the ground truth tempo stored in the file
    fid = fopen([gtpth '/' gtfls(ii).name],'r');
    gttempo(ii) = fscanf(fid,'%d');
    fclose(fid);
end

% Check if any results are missing by comparing the filenames containing
% the ground truth tempos to the filenames of the results
missed = setxor(gtnms,wnms);
if ~isempty(missed)
    error('Some files are missing from results, see "missed" array');
end

% Compute the ratio of the predicted tempo to ground truth
RT = FFTMX'*60./gttempo;
rtexmn = [1 2 3 4];
tol = 0.08;
rats = HRMS(:,1)/FFTMX(1);
idx = false(length(RT),length(rtexmn));
% mdsv = NaN(size(SV,1),length(rtexmn));
for r = 1:length(rtexmn),
    idx(:,r) = RT>=(rtexmn(r)-tol)&RT<=(rtexmn(r)+tol); % get song results at this particular ratio of the tempo
    V{r} = ISIRAT(:,idx(:,r));
%     mdsv = median(SV(:,idx(:,1)));
end

% Plot the distribution of isi ratios
cmap = colormap('jet');
[kw,svleg] = plotmedians(V,rats,cmap);
legend(svleg,'1x','2x','3x','4x');
xlabel('Normalized beat frequency');
ylabel('Beat salience');