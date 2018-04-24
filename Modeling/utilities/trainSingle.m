function model = trainSingle(P, Alphas, order)


[num_states, num_pts] = size(P);
pts = zeros(num_pts,num_states);

for i = 1:num_states
    X = P(i,1:3:end)';
    Y = P(i,2:3:end)';
    Z = P(i,3:3:end)';
    pts(:,i) = [X;Y;Z];
end

X0 = pts(:,1);
U = pts-X0;



A = Alphas(:,3)'-Alphas(1,3)';
[M,N] = size(A);
dim = max((((M^(order+1)-1)/(M-1))-1),order);

A_JK = zeros(dim, N);
for i = 1:N 
    A_JK(:,i) = makeAlpha(A(:,i),order)';
end

% Compute Hessian 
JK = (A_JK*A_JK')\(U*A_JK')';

alpha = @(a) makeAlpha(a,order);
%fun = @(x) @(a) norm(x(11:18:end) - (JK'*alpha(a)')-X0(11:18:end))^2;
fun = @(x) @(a) norm(x - (JK'*alpha(a)')-X0)^2;

ub = max(A); 
lb = min(A);
model = @(x) fmincon(fun(x), 150, [], [], [], [], lb, ub);

end