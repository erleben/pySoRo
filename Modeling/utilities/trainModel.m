function [model, fmodel] = trainModel(P, Alphas, order, use_solver, isPoly, doNormalize)

if nargin < 4
    use_solver = true;
end

if nargin < 5
    isPoly = true;
end

if nargin < 7
    doNormalize = true;
end


if doNormalize
    [P, p_std, p_mean] = normalize(P);
    [Alphas, a_std, a_mean] = normalize(Alphas);
end


lb = min(Alphas,[],1);
ub = max(Alphas, [], 1);

Plb = min(P,[],1);
Pub = max(P, [], 1);

X0 = P(1,:)';
U = P'-X0;

if isPoly
    A0 = zeros(size(Alphas,2),1);
else
    A0 = Alphas(1,:)';
end

A = Alphas'-A0;

A_JK = makeAlpha(A,order, isPoly);
JK = lsqminnorm(A_JK',U');

fst = @(F) F(1:size(Alphas,2),:);
if isPoly
    W = pinv(JK(2:end,:)');
    b = X0 + JK(1,:)';
else
    W = pinv(JK');
    b = X0;
end

% Naive first order appriximation
model = @(p) clamp(fst(W*(p'-b)), lb, ub);

if use_solver
    lossfun = @(p)@(a) sum(sum((JK'*makeAlpha(a, order, isPoly) - p).^2,2));
    start_guess = model;
    model = @(p) all_model(p, X0, lb, ub, A0, lossfun, start_guess);
end

if nargout > 1
    fmodel = @(a) clamp((X0 + JK'*makeAlpha(a'-A0,order, isPoly)),Plb,Pub);
    if doNormalize
        fmodel = @(a) denormalize(fmodel(normalize(a, a_std, a_mean)), p_std', p_mean');
    end
end

if doNormalize
    model = @(p) denormalize(model(normalize(p,p_std, p_mean)), a_std', a_mean');
end

    function a = clamp(a1, lb, ub)
        a = max(a1', lb);
        a = min(a, ub)';
    end

    function pred = all_model(p, X0, lb, ub, A0, lossfun, model)
        options=optimoptions('fmincon','Display','off','Algorithm','sqp');
        %options=optimoptions('fmincon','Display','off','Algorithm','interior-point');
        pred = zeros(size(A0,1),size(p,1));
        start_p = model(p)-A0;
        for i = 1:size(p,1)
            x = fmincon(lossfun(p(i,:)'-X0), start_p(:,i), [],[],[],[], lb'-A0, ub'-A0,[], options);
            pred(:,i) = x+A0;
        end
    end

    function X = denormalize(X, s, m)
        X = X.*s + m;
    end

    function [X, s, m] = normalize(X,s,m)
        if nargin == 1
            m = mean(X);
            s = std(X-m);
        end
        s(s==0)=1;
        X = (X-m)./s;
    end
end