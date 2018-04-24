% This script trains a model in the data, after adding gaussian noise to
% it.
% The hope is to reveal 
%   -A relationship between noise and training error 
%   -difference in training and testing loss

E = [];
order  =4;

for r = 1:10
    ind = 1;
    for sigma = fliplr(2:0.2:6)
        E(r,ind)=exp_noise(order,1,1,10^(-sigma), false);
        ind = ind + 1;
    end
end
semilogx(10.^(-fliplr(2:0.2:6)),mean(E))