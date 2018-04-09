function [R, T] = getTransformParam(p_ref, p_targ)

o_mean = mean(p_ref);
t_mean = mean(p_targ);

o_norm = p_ref-o_mean;
t_norm = p_targ- t_mean;

[M,~] = size(p_ref);

H = zeros(3);
for i = 1:M
    H = H + o_norm(i,:)'*t_norm(i,:);
end

[U,~,V] = svd(H);
R=V*U';

T=0;
for i = 1:M
    T=T+(p_targ(i,:)'-R*p_ref(i,:)');
end
T=T/M;

end