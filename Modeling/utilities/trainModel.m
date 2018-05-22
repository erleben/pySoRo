function [model, fmodel] = trainModel(P, Alphas, order, use_solver, isPoly, regParam)

if nargin < 4
    use_solver = true;
end

if nargin < 5
    isPoly = false;
end

if nargin < 6
    regParam = 0;
end

X0 = P(1,:)';
U = P'-X0;

if isPoly
    A0 = 0;
else
    A0 = Alphas(1,:)';
end


A = Alphas'-A0; 

A_JK = makeAlpha(A,order, isPoly);

% Compute Hessian
if regParam > 0
    Hat = eye(size(A_JK*A_JK'))*regParam;
    Hat(1)=~isPoly*regParam;
    JK = (A_JK*A_JK'+Hat)\(U*A_JK')';
else
    JK = (A_JK*A_JK')\(U*A_JK')';
end

if use_solver
    %options = optimoptions('fmincon', 'Algorithm','sqp');
    lossfun = @(p)@(a) sum(sum((JK'*makeAlpha(a', order, isPoly)' - p).^2,2));
    all_model = @(p) fmincon(lossfun(p-X0), mean(A,2), [],[],[],[], min(A, [], 2), max(A, [], 2))+A0;
else
    if isPoly
        fst = @(F) F(1:size(Alphas,2),:);
        model = @(p) clamp(fst((JK(2:end,:)*JK(2:end,:)')\JK(2:end,:)*(p-X0-JK(1,:)')), Alphas);
    else
        fst = @(F) F(1:size(Alphas,2),:);
        model = @(p) fst(((JK*JK')\JK*(p-X0))) + A0;
    end
end 

if nargout > 1
    fmodel = @(a) X0 + JK'*makeAlpha(a'-A0,order, isPoly);
end


    function a = clamp(a1, A)
        a = max(a1', min(A,[],1));
        a = min(a, max(A,[],1))';
    end


end