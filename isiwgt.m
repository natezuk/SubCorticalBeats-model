function wh = isiwgt(h,isi,tau)
% Weight ISI histogram, based on the model for intensity discrimination in Durlach & Braida, 1969
% and reused for long-term memory in Cowan, 1984

% w = (isi+tau).^-0.5;
% w = w-min(w);
w = exp(-isi/tau);
wh = h.*w/max(w);