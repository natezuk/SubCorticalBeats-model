function ct = clickPatternCalc(cr,pattern,dur,ph)
% Nate Zuk (2017)
% Computes a set of click times that obey a particular pattern. 
% Inputs:
% - cr = click rate (in beats per min)
% - pattern = a series of ones and zeros that define whether or not a
% clicks is present at the time associated with the click rate (1 = click
% present, 0 = click absent)
% - dur = overall duration of clicks train (in s)
% - ph = phase of the clicks (between -0.5 and 0.5, with 0 being at the
% center)
%
% Outputs:
% - ct = array of click times (in s)

if size(pattern,1)==1, pattern = pattern'; end

% Compute times for isochronous clicks, with the first click occurring
% around 1 click period and the last click occurring one period less than
% dur
f = cr/60;
ct = (1/f:1/f:dur-1/f)'+ph/f;

% Define which clicks are on or off based on the pattern
nrep = ceil(length(ct)/length(pattern));
con = repmat(pattern,nrep,1);
con = con(1:length(ct));

% Reset click times based on pattern
ct = ct(logical(con));
