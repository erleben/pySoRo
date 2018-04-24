function d = distFunction(p, distMS, xs, ys, zs) 

[N,~] = size(p);
d = zeros(N,1);

for num = 1:N
    d(num) = interp3(xs,ys,zs,distMS,p(num,1),p(num,2),p(num,3));
end
end   