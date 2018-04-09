function model = trainModel(P, Alphas)

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

A = Alphas(:,3)';
A_JK = [A; 0.5*(A.^2)];

% Compute Hessian
JK = (A_JK*A_JK')\(U*A_JK')';
model = @(p) round((JK*JK')\JK*(p-X0));
end