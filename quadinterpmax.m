function [pk,xval] = quadinterpmax(x,y)
% Compute the peak of a function using quadratic interpolation.
% If the maximum is at the minimum or maximum x, then that value of y is
% returned.  If there are multiple peaks, then the first one
% is returned.
% Inputs:
% - x = independent variables
% - y = dependent variables
% Outputs:
% - pk = y value at the peak
% - xval = x value at the peak
% Nate Zuk (2018)

if size(x,1)==1, x = x'; end
if size(y,1)==1, y = y'; end
if length(x)~=length(y), error('x and y must be the same length'); end

pkind = find(y==max(y));

if pkind==1 || pkind==length(x), % if the peak is at either end of the y array
    pk = max(y); % just grab the end value
    xval = x(pkind);
else % otherwise, quadratic interpolation
    itrpinds = pkind-1:pkind+1;
    X = [ones(3,1) x(itrpinds) x(itrpinds).^2];
    b = X \ y(itrpinds);
    xval = -b(2)/(2*b(3));
    pk = b(1)+b(2)*xval+b(3)*xval^2;
end