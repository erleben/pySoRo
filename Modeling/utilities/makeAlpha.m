function A_JK = makeAlpha(a, order, isPoly)

if nargin <3
    isPoly = false;
end


[dim, ~] = size(a);
A_JK =[];
ind = 1;
for o = 1:order
    exponentials = flipud(mixed_term(dim, o));
    [terms, ~] = size(exponentials);
    denom = factorial(o);
    for t = 1:terms
        C = multiNom(exponentials(t,:));
        %A_JK(ind,:)=C*prod(a'.^exponentials(t,:),2)/prod(denom.^exponentials(t,:),2);
        A_JK(ind,:)=C*prod(a'.^exponentials(t,:),2)/denom;
        ind = ind + 1;
    end
        
end

if isPoly
    A_JK = [ones(1,size(A_JK, 2)); A_JK];
end

end 