function coeff = multiNom(orders)

n = sum(orders);
nom = factorial(n);
denom = 1;
for i = 1:length(orders)
    denom = denom*factorial(orders(i));
end

coeff = nom/denom;
end

