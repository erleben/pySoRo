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

[dim, ~ ] = size(makeAlpha(A(:,1),order, isPoly));
A_JK = zeros(dim, N);

for i = 1:N 
    A_JK(:,i) = makeAlpha(A(:,i),order, isPoly)';
end

% Compute Hessian
JK = (A_JK*A_JK')\(U*A_JK')';

if use_solver
    %options = optimoptions('fmincon', 'Algorithm','sqp');
    lossfun = @(p)@(a) sum(sum((JK'*makeAlpha(a', order, isPoly)' - p).^2,2));
    lossfun_select = @(p, I)@(a) sum(sum(((JK*I)'*makeAlpha(a', order, isPoly)' - p)^2,2));
    all_model = @(p) fmincon(lossfun(p-X0), mean(A,2), [],[],[],[], min(A, [], 2), max(A, [], 2))+Alphas(1,:)';
    some_model = @(p, I) fmincon(lossfun_select(p-X0, I), mean(A,2), [],[],[],[], min(A, [], 2), max(A, [], 2))+Alphas(1,:)';
    model = @(p) multiModel(p, all_model, some_model);
    select_model =@(p,I) multiModel(p, all_model, some_model, I);
    
else
    if isPoly
        fst = @(F) F(1:size(Alphas,2),:);
        model = @(p) clamp(fst((JK(2:end,:)*JK(2:end,:)')\JK(2:end,:)*(p-X0-JK(1,:)')) + Alphas(1,:)',Alphas);
        select_model = @(p, I) clamp(fst((JK(2:end,I)*JK(2:end,I)')\JK(2:end,I)*(p-(X0(I)-JK(1,I)')))+ Alphas(1,:)',Alphas);
    else
        fst = @(F) F(1:size(Alphas,2),:);
        model = @(p) fst(((JK*JK')\JK*(p-X0))) + Alphas(1,:)';
        select_model = @(p) fst(((JK*JK')\JK*(p-X0))) + Alphas(1,:)';
    end
end 
 


if nargout > 1
    fmodel = @(a) X0 + JK'*makeAlpha(a'-Alphas(1,:)',order, isPoly)';
end

if nargout > 3
    fmodel = @(a) X0 + JK'*makeAlpha(a'-Alphas(1,:)',order, isPoly);
    select_fmodel = @(a, I) X0(I) + JK(:,I)'*makeAlpha(a'-Alphas(1,:)',order, isPoly);
end
        
    function alphas = multiModel(pts, allM, someM, I)
        alphas = [];
        if nargin <4
            for ii = 1:size(pts,2)
                alphas=[alphas; allM(pts(:,ii))'];
            end
        else
            for ii = 1:size(pts,1)
                alphas=[alphas; someM(pts(:,ii),I)'];
            end
        end
        alphas = alphas';
    end
            
    function a = clamp(a1, A)
        a = max(a1', min(A,[],1));
        a = min(a, max(A,[],1))';
    end


end