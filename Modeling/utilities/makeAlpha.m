function A_JK = makeAlpha(a, order, isPoly)

if nargin <3
    isPoly = false;
end


[dim, k] = size(a);
num_mon = sum(arrayfun(@(x)nchoosek(dim+x-1,x),1:order));
A_JK = zeros(num_mon, k);
ind = 1;
for o = 1:order
    exponentials = flipud(mixed_term(dim, o));
    [terms, ~] = size(exponentials);
    coeff = 1./prod(factorial(exponentials'));
    for t = 1:terms
        C = coeff(t);
        A_JK(ind,:)=C*prod(a'.^exponentials(t,:),2);
        ind = ind + 1;
    end
    
end

if isPoly
    A_JK = [ones(1,size(A_JK, 2)); A_JK];
end

end