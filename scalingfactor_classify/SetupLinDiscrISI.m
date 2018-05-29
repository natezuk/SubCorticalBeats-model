% Setup stimulation results for the Ballroom dataset (WavRhyISI) and the
% Songs dataset (SongsRhyISI) so they can be analyzed with LinDiscrISI
% Nate Zuk (2018)

clear all

addpath(genpath('~/ANFbeats/'));

WavRhyISI;

TTRT = RT;
MX = FFTMX';
TOTISI = ISIRAT';
GT = gttempo;

SongsRhyISI;

TTRT = [TTRT; RT];
MX = [MX; FFTMX'];
TOTISI = [TOTISI; ISIRAT'];
GT = [GT; gttempo];
