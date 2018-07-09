function [X, s, m] = normalize(X,s,m)
if nargin == 1
    m = mean(X);
    s = std(X-m);
end
X = (X-m)./s;
end