function [model, fmodel, select_model, select_fmodel] = trainModel(P, Alphas, order, use_solver, isPoly)

if nargin < 4
    use_solver = true;
end

if nargin < 5
    isPoly = false;
end

X0 = P(1,:)';
U = P'-X0;

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
    model = @(p) fmincon(lossfun(p-X0), mean(A,2), [],[],[],[], min(A,2), max(A,2))+Alphas(1,:)';
    select_model = @(p, I) fmincon(lossfun(p-X0), mean(A,2), [],[],[],[], min(A,2), max(A,2))+Alphas(1,:)';
else
    if isPoly 
        fst = @(F) F(1:size(Alphas,2),:);
        model = @(p) fst((JK(2:end,:)*JK(2:end,:)')\JK(2:end,:)*(p-X0-JK(1,:)')) + Alphas(1,:)';
        select_model = @(p, I) fst((((JK(2:end,:)*JK(2:end,:)')\JK(2:end,:))*I))*(p-I'*(X0-JK(1,:)')) + Alphas(1,:)';
    else
        fst = @(F) F(1:size(Alphas,2));
        model = @(p) fst(((JK*JK')\JK*(p-X0))) + Alphas(1,:)';
        select_model = @(p) fst(((JK*JK')\JK*(p-X0))) + Alphas(1,:)';
    end
end

if nargout > 1
    fmodel = @(a) X0 + JK'*makeAlpha(a'-Alphas(1,:)',order, isPoly)';
end

if nargout > 3
    fmodel = @(a) X0 + JK'*makeAlpha(a'-Alphas(1,:)',order, isPoly)';
    select_fmodel = @(a, I) I'*X0 + (JK*I)'*makeAlpha(a'-Alphas(1,:)',order, isPoly)';
end



end