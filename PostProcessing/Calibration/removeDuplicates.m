function removeDuplicates

Alphas  = csvread(strcat('alphamap.csv'));
P=load('experiments/ordered_twoP.csv');

[num_alph, num_pts] = size(P);

A = zeros(51,51,num_pts);

ind = 1;
for i = 1:51
    for j = 1:51
        A(i,j,:) = P(ind, :);
        ind = ind+1;
    end
end


end 