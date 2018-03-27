CP = load('CP_single_param.mat');
%CP = load('CP_two_param.mat');
%CP = load('CP_two_param.mat');

CP = CP.CP;

num_states = length(CP.alphas);
tot_num_pts = length(CP.mesh.x0);

sample = 1:21:tot_num_pts;
X0 = [mesh.x0(sample); mesh.y0(sample); mesh.z0(sample)];
U = zeros(length(X0), num_states);
A = CP.alphas;
for i = 1:num_states
    X = [CP.states{i}.x(sample); CP.states{i}.y(sample); CP.states{i}.z(sample)];
    U(:,i) = X - X0;
end


%Keep observation i for testing
i = 5;
T = U(:,i);
U(:,i)=[]; 
AA = A(:,i);
A(:,i) = [];

%Comupte Jacobian

J = (A*A')\(U*A')';
alpha_est = round((J*J')\J*T);
err_j = sqrt(sum((T- J'*alpha_est).^2));
disp('First order');
disp('alpha_test:');
disp(AA);
disp('alpha_est:');
disp(alpha_est);
disp('mse:')
disp(err_j);
 
% Include hessian

A = [A; 0.5*A(1,:).^2];
JK = (A*A')\(U*A')';
alpha_est = round((JK*JK')\JK*T);
err_jk = sqrt(sum((T- JK'*alpha_est).^2));
disp('Second order');
disp('alpha_test:');
disp(AA);
disp('alpha_est:');
disp(alpha_est);
disp('mse:')
disp(err_jk);

