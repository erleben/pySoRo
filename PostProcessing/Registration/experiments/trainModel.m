function model = trainModel(P, Alphas, order)

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
fst = @(F) F(1:size(Alphas,2));
%otp = @(J) J(:,1:18:end);
model = @(p) fst(((JK*JK')\JK*(p-X0))) + Alphas(1,:)'; 
%model = @(p) fst(((otp(JK)*otp(JK)')\otp(JK))*(p(1:18:end)-X0(1:18:end)) + Alphas(1,3)); 

end