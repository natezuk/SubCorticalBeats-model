% Use linear discriminant analysis to classify scaling factor based on
% PCA-rotated beat salience
% Run SetupLinDiscrISI.m first
% Nate Zuk (2018)

% cls = [1 2 3 4]; % possible classes
cls = [1 2 3 4];
% npcas = 5; % number of pca components to use
idx = false(length(TTRT),length(cls));
for ii = 1:length(TTRT), idx(ii,:) = abs(TTRT(ii)-cls)==min(abs(TTRT(ii)-cls)); end
% npcas = 25;
% nrows = 13;

ntrain = ceil(length(TTRT)*3/4);
ntst = length(TTRT)-ntrain;

% nrmMX = (MX*60-315)/315;
% [cf,sc,~,~,vexp] = pca(TOTISI);
% [cf,sc,~,~,vexp] = pca([nrmMX TOTISI]);
% instat = sc(:,1:npcas);
% if ~npcas, 
%     instat = MX;
% else
%     instat = [MX sc(:,1:npcas)];
% end
% instat = MX;
instat = [MX TOTISI];
insmpl = MX; % inputs including just the tempo

nrep = 1000;
totcorr = NaN(nrep,1);
totsmpl = NaN(nrep,1);
diffcorr = NaN(nrep,1);
tempocorr = NaN(nrep,1);
temposmpl = NaN(nrep,1);
tempoimprv = NaN(nrep,1);
mu = NaN(length(cls),nrep);
corr = NaN(length(cls),length(cls),nrep);
corrsmp = NaN(length(cls),length(cls),nrep);
for n = 1:nrep,
    if mod(n,10)==0, disp(['n=' num2str(n)]); end
    rint = randperm(size(instat,1)); % identify training songs
    trnlbl = NaN(ntrain,1); % get the scalings for the training songs
    for ii = 1:ntrain,
        trnlbl(ii) = find(idx(rint(ii),:),1,'first');
    end
    
    % Create the linear discriminant model
    mdl = fitcdiscr(instat(rint(1:ntrain),:),trnlbl);
%     mdl = fitcecoc(instat(rint(1:ntrain),:),trnlbl);

    % Testing
    tstlbl = predict(mdl,instat(rint(ntrain+1:end),:));
    
    % Relabel as 1 and 0 in an idx-like matrix
    res = false(ntst,length(cls));
    for ii = 1:ntst, res(ii,tstlbl(ii)) = true; end
    
    % Compute the % of correct responses
    tstidx = idx(rint(ntrain+1:end),:);
    totcorr(n) = sum(sum(res.*tstidx))/ntst*100;
    for c = 1:length(cls),
        for d = 1:length(cls),
            corr(c,d,n) = sum(res(:,c).*tstidx(:,d))./sum(tstidx(:,d))*100;
%             corr(c,d,n) = sum(res(:,c).*tstidx(:,d));
        end
    end
    
    % Determine if the tempo is correct (within 8% of ground truth)
    tstmx = MX(rint(ntrain+1:end))*60;
    PRD = NaN(ntst,1);
    for jj = 1:ntst,
        PRD(jj) = tstmx(jj)/(res(jj,:)*cls');
    end
    gttst = GT(rint(ntrain+1:end));
    tempocorridx = abs((PRD-gttst)./gttst)<=0.08;
    tempocorr(n) = sum(tempocorridx)/ntst*100;
    % Separately compute the % of correct responses for the two datasets
    tststim = rint(ntrain+1:end);
    ballroomidx = tststim<=698;
    ballcorr(n) = sum(tempocorridx(ballroomidx))/sum(ballroomidx)*100;
    nball(n) = sum(ballroomidx); % number of ballroom stimuli used for testing
    songidx = tststim>698;
    songcorr(n) = sum(tempocorridx(songidx))/sum(songidx)*100;
    nsong(n) = sum(songidx);
    
    % Test the simpler model with just peak tempo...
    
    % Create the linear discriminant model
    mdlsmpl = fitcdiscr(insmpl(rint(1:ntrain)),trnlbl);
%     mdlsmpl = fitcecoc(insmpl(rint(1:ntrain)),trnlbl,'CodingName','ordinal');
    mu(:,n) = mdlsmpl.Mu;

    % Testing
    tstlbl = predict(mdlsmpl,insmpl(rint(ntrain+1:end)));
    
    % Relabel as 1 and 0 in an idx-like matrix
    res = false(ntst,length(cls));
    for ii = 1:ntst, res(ii,tstlbl(ii)) = true; end
    
    % Compute the % of correct responses
    tstidx = idx(rint(ntrain+1:end),:);
    totsmpl(n) = sum(sum(res.*tstidx))/ntst*100;
    diffcorr(n) = totcorr(n)-totsmpl(n);
    for c = 1:length(cls),
        for d = 1:length(cls),
            corrsmp(c,d,n) = sum(res(:,c).*tstidx(:,d))./sum(tstidx(:,d))*100;
%             corrsmp(c,d,n) = sum(res(:,c).*tstidx(:,d));
        end
    end
    
    % Determine if the tempo is correct (within 8% of ground truth)
    tstmx = MX(rint(ntrain+1:end))*60;
    PRD = NaN(ntst,1);
    for jj = 1:ntst,
        PRD(jj) = tstmx(jj)/(res(jj,:)*cls');
    end
    gttst = GT(rint(ntrain+1:end));
    temposmpl(n) = sum(abs((PRD-gttst)./gttst)<=0.08)/ntst*100;
    tempoimprv(n) = tempocorr(n)-temposmpl(n);
end

pdiff = sum(diffcorr<=0)/nrep;
pimprv = sum(tempoimprv<=0)/nrep;

disp(['Percentage of correct responses using only event frequency is ' num2str(mean(totsmpl)) ' +/- ' num2str(std(totsmpl))]);
disp(['Tempo prediction accuracy after scaling is ' num2str(mean(temposmpl)) ' +/- ' num2str(std(temposmpl))]);
disp(['Percentage of correct responses is ' num2str(mean(totcorr)) ' +/- ' num2str(std(totcorr))]);
disp(['Tempo prediction accuracy after scaling is ' num2str(mean(tempocorr)) ' +/- ' num2str(std(tempocorr))]);
disp(['Amount of improvement with isi ratios: ' num2str(mean(diffcorr)) ' +/- ' num2str(std(diffcorr)) ...
    ', p = ' num2str(pdiff)]);
disp(['Amount of improvement in tempo prediction: ' num2str(mean(tempoimprv)) ' +/- ' num2str(std(tempoimprv)) ...
    ', p = ' num2str(pimprv)]);
disp(['Ballroom performance: ' num2str(mean(ballcorr)) ' +/- ' num2str(std(ballcorr))]);
disp(['Songs performance: ' num2str(mean(songcorr)) ' +/- ' num2str(std(songcorr))]);

% Plot the confusion matrix for each
figure
subplot(2,1,1)
colormap('hot');
imagesc(mean(corrsmp,3),[0 100]);
cb = colorbar; axis('square');
cb.Label.String = '% responses';
set(gca,'XTick',1:4,'YTick',1:4);
xlabel('Target scaling factor');
ylabel('Output scaling factor');
title('Predicted tempo only');

subplot(2,1,2)
colormap('hot');
imagesc(mean(corr,3),[0 100]);
cb = colorbar; axis('square');
cb.Label.String = '% responses';
set(gca,'XTick',1:4,'YTick',1:4);
xlabel('Target scaling factor');
ylabel('Output scaling factor');
title('Predicted tempo + Rhythm');