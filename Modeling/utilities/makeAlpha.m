function A_JK = makeAlpha(a, order)

%     [M,~] = size(a);
%     dim = ((M^(order+1)-1)/(M-1))-1;
%     if isnan(dim)
%         dim = order;
%     end
%     A = zeros(1, dim);
%     l = 1;
%     ind = 1;
%     for i = 1:order
%         l = reshape(a*l', M^i, 1);
%         A(ind:ind+M^i-1) = l/factorial(i);
%         
%         ind = ind + M^i;
%     end
%     
%     % Remove duplicate mixed terms
%     binom = [];
%     for n = 1:order
%       for k = 0:n
%         binom = horzcat(binom, nchoosek(n, k));
%       end
%     end
% 
%     ind = 1;
%     A_JK = zeros(1,length(binom));
%     for i = 1:length(binom)
%         A_JK(i)=sum(A(ind:ind+binom(i)-1));
%         ind = ind + binom(i);
%     end

[dim, ~] = size(a);
A_JK =[];
ind = 1;
for o = 1:order
    exponentials = flipud(mixed_term(dim, o));
    [terms, ~] = size(exponentials);
    for t = 1:terms
        C = multiNom(exponentials(t,:));
        A_JK(ind)=C*prod(a'.^exponentials(t,:))/factorial(o);
        ind = ind +1;
    end
        
end
end