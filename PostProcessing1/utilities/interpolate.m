function p_new = interpolate(p, ps_prev, ps_new)

sigma = min(sqrt(sum((p-ps_prev).^2,2)));
gauss = @(x,p, sigma) exp(-(0.5*(sum((x-p).^2,2))/sigma^2));
G=gauss(ps_prev, p, sigma);

U = ps_new-ps_prev;

w = (G/sum(G));
u = (U'*w)';
p_new = p+u;

end