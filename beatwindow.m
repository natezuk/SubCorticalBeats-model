function wnd = beatwindow(tol,Fs)
% Create the gaussian window associated with beat tolerance
% Inputs:
%   - tol = tolerance, the width of the window (s)
%   - Fs = sampling frequency (Hz)
% Outputs:
%   - wnd = array of the window, with an area of 1
% Nate Zuk (2018)

dt = 1/Fs; % sampling period
wndsz = 2*floor(4*tol/dt)+1; % specify a window size that is 4 stds in either direction
wis = ceil(-wndsz/2):floor(wndsz/2);
wnd = normpdf(wis,0,tol/dt)'; % create gaussian window with desired tolerance
wnd = wnd/sum(wnd);
