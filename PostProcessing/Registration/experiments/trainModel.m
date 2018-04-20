function model = trainModel(P, Alphas, order, use_solver)

if nargin < 4
    use_solver = true;
end
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

A = Alphas'-Alphas(1,:)';
[~,N] = size(A);
%dim = max((((M^(order+1)-1)/(M-1))-1),order);
[dim,~] = size(makeAlpha(A(:,1),order)');

A_JK = zeros(dim, N);
for i = 1:N 
    A_JK(:,i) = makeAlpha(A(:,i),order)';
end

% Compute Hessian 
JK = (A_JK*A_JK')\(U*A_JK')';

if use_solver
    lossfun = @(p)@(a) norm(JK'*makeAlpha(a, order)' - p);
    model = @(p) fmincon(lossfun(p-X0), mean(A')', [],[],[],[],min(A')', max(A')')+Alphas(1,:)';
else
    fst = @(F) F(1:size(Alphas,2));
    model = @(p) fst(((JK*JK')\JK*(p-X0))) + Alphas(1,:)'; 
end

end