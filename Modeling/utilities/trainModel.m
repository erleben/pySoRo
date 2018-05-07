function [model, fmodel] = trainModel(P, Alphas, order, use_solver, isPoly)

if nargin < 4
    use_solver = true;
end

if nargin < 5
    isPoly = false;
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

[dim,~] = size(makeAlpha(A(:,1),order, isPoly)');
A_JK = zeros(dim, N);

for i = 1:N
    A_JK(:,i) = makeAlpha(A(:,i),order, isPoly)';
end

% Compute Hessian
JK = (A_JK*A_JK')\(U*A_JK')';

if use_solver
    %options = optimoptions('fmincon', 'Algorithm','sqp');
    lossfun = @(p)@(a) norm(JK'*makeAlpha(a, order, isPoly)' - p)^2;
    model = @(p) fmincon(lossfun(p-X0), mean(A')', [],[],[],[], min(A')', max(A')')+Alphas(1,:)';
else
    if isPoly
        fst = @(F) F(1:size(Alphas,2));
        model = @(p) fst(((JK(2:end,:)*JK(2:end,:)')\JK(2:end,:)*(p-X0-JK(1,:)'))) + Alphas(1,:)';
    else
        fst = @(F) F(1:size(Alphas,2));
        model = @(p) fst(((JK*JK')\JK*(p-X0))) + Alphas(1,:)';
    end
end

if nargout > 0
    fmodel = @(a) X0 + JK'*makeAlpha(a'-Alphas(1,:)',order, isPoly)';
end

end