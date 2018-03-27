P = csvread('../../Calibration/datapoints.csv');
[num_states, num_pts] = size(P);

pts = zeros(num_pts,num_states);


for i = 1:num_states
    X = reshape(P(i,1:3:end),num_pts/3,1);
    Y = reshape(P(i,2:3:end),num_pts/3,1);
    Z = reshape(P(i,3:3:end),num_pts/3,1);
    pts(:,i) = [X;Y;Z];
end

X0 = pts(:,1);
pts(:,1) = [];
U = pts-X0;

i=4;
T = U(:,i);
A = 1:4;
U(:,i)=[];
A(i)=[];

J = (A*A')\(U*A')';
alpha_est = (J*J')\J*T
err_j = sqrt(sum((T- J'*alpha_est).^2))

