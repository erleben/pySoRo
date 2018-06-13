function [model, fmodel] = trainModel(P, Alphas, order, use_solver, isPoly)

if nargin < 4
    use_solver = true;
end

if nargin < 5
    isPoly = false;
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
JK = (A_JK*A_JK')\(U*A_JK')';

 
if isPoly
    fst = @(F) F(1:size(Alphas,2),:);
    model = @(p) clamp(fst((JK(2:end,:)*JK(2:end,:)')\JK(2:end,:)*(p-X0-JK(1,:)')), Alphas);
else
    fst = @(F) F(1:size(Alphas,2),:);
    model = @(p) fst(((JK*JK')\JK*(p-X0))) + A0;
end

if use_solver
    %options = optimoptions('fmincon', 'Algorithm','sqp');
    lossfun = @(p)@(a) sum(sum((JK'*makeAlpha(a, order, isPoly) - p).^2,2));
    model = @(p) all_model(p, X0, A, A0, lossfun, model);
end

if nargout > 1
    fmodel = @(a) X0 + JK'*makeAlpha(a'-A0,order, isPoly);
end


    function a = clamp(a1, A)
        a = max(a1', min(A,[],1));
        a = min(a, max(A,[],1))';
        %a = a1;
    end

    function pred = all_model(p, X0, A, A0, lossfun, model)
        pred = zeros(size(A,1),size(p,2));
        start_p = model(p)-A0;
        parfor i = 1:size(p,2)
            pred(:,i) = fmincon(lossfun(p(:,i)-X0), start_p(:,i), [],[],[],[], min(A, [], 2), max(A, [], 2))+A0;
        end        
    end
end