function bcon = merge_boundary_conditions(bcon1, bcon2)

N1 = length(bcon1.idx);
N2 = length(bcon2.idx);

idx1 = reshape(bcon1.idx, N1/3, 3);
idx2 = reshape(bcon2.idx, N2/3, 3);

values1 = reshape(bcon1.values, N1/3, 3);
values2 = reshape(bcon2.values, N2/3, 3);

idx = reshape([idx1; idx2], N1+N2, 1);
values = reshape([values1; values2], N1+N2, 1);

bcon = {};
bcon.idx = idx;
bcon.values = values;

end