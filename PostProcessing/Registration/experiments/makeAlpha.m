function A_JK = makeAlpha(a, order)

    [M,~] = size(a);
    dim = ((M^(order+1)-1)/(M-1))-1;
    if isnan(dim)
        dim = order;
    end
    A_JK = zeros(1, dim);
    l = 1;
    ind = 1;
    for i = 1:order
        l = reshape(a*l', M^i, 1);
        A_JK(ind:ind+M^i-1) = l/factorial(i);
        
        ind = ind + M^i;
    end
        
end