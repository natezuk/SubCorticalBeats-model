function ct = clickJitCalc(cr,jit,subdev,dur,ph)
% Nate Zuk (2018)
% Computes a set of click times with jittered clicks. Clicks are jittered
% by a uniform random distribution
% Inputs:
% - cr = click rate (in BPM)
% - jit = % jitter, with 100% being an offset of at most +/- 0.5 click
% period
% - subdev = defines which click is *not* jittered (0 = no clicks, 1 = every
% click, 2 = every other click, 3 = every 3rd click, etc.)
% - dur = overall duration of clicks train (in s)
% - ph = phase of the clicks (between -0.5 and 0.5, with 0 being at the
% center)
% Outputs:
% - ct = array of click times (in s)

% Compute times for isochronous clicks, with the first click occurring
% around 1 click period and the last click occurring one period less than
% dur
f = cr/60;
ct = (1/f:1/f:dur-1/f)'+ph/f;

% Pick clicks to jitter
noJit = 1:subdev:length(ct);
jInd = setxor(1:length(ct),noJit);

% Jitter times
jAmt = (jit/100)*(rand(length(jInd),1)-0.5)*1/f;
for ii = 1:length(jInd),
    ct(jInd(ii)) = ct(jInd(ii))+jAmt(ii);
end