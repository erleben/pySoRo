%CP = load('CP_single_param.mat');
CP = load('CP_two_param_many.mat');
CP = CP.CP;

num_states = length(CP.alphas);
mesh = CP.mesh;
tot_num_pts = length(CP.mesh.x0);

sample = 1:tot_num_pts;
X0 = [mesh.x0(sample); mesh.y0(sample); mesh.z0(sample)];
U = zeros(length(X0), num_states);
%num_states  = 30
A = CP.alphas(:,1:num_states);
for i = 1:num_states
    X = [CP.states{i}.x(sample); CP.states{i}.y(sample); CP.states{i}.z(sample)];
    U(:,i) = X - X0;
end

%U = U+(rand(size(U))/3)-1/6;
%Keep observation i for testing
i = 9;
T = U(:,i);
U(:,i)=[];
AA = A(:,i);
A(:,i) = [];
A_JK = [A; 0.5*(A(1,:).^2) ;  0.5*(A(1,:).*A(2,:)); 0.5*(A(2,:).^2)];


%Comupte Jacobian
J = (A*A')\(U*A')';
alpha_est = round((J*J')\J*T);
est_err = reshape((T- J'*alpha_est),numel(T)/3,3);
err_j = mean(sqrt(sum(est_err.^2,2)));
disp('First order');
disp('alpha_test:');
disp(AA);
disp('alpha_est:');
disp(alpha_est);
disp('mse:')
disp(err_j);

% Compute Hessian
JK = (A_JK*A_JK')\(U*A_JK')';
alpha_est = round((JK*JK')\JK*T);
%so =  reshape(alpha_est(1:2)*alpha_est(1:2)',4,1)/2;
%so(3)=[];
%alpha_est = [alpha_est(1:2);so];
est_err = reshape((T- JK'*alpha_est),numel(T)/3,3);
err_jk = mean(sqrt(sum(est_err.^2,2)));
disp('Second order');
disp('alpha_test:');
disp(AA);
disp('alpha_est:');
disp(alpha_est);
disp('mse:')
disp(err_jk);

kit = {};
kit.X0 = X0;
kit.JK = JK;
kit.T = mesh.T;
save('kit','kit');