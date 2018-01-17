function [ratio,isicnt] = isicount(h,isi,duration,varargin)
% Compute the sum of the isis within a range surround a particular
% duration and divide by the total number of isis
% Nate Zuk (2018)

tol = 0.01; % the 1/2 width of the window surrounding the specified duration (s)

if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Compute the ratio of isis in the window over the total isi count
inds = isi>=(duration-tol)&isi<=(duration+tol);
isicnt = sum(h(inds));
ratio = isicnt/sum(h);