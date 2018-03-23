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
i = 4;
T = U(:,i);
U(:,i)=[];
A(i) = [];

J = (A*A')\(U*A');
%sum(abs(T-J*(-5100)))
alpha_est = r
ound((J'*J)\J'*T)
 
B = [A, reshape((A'*A/2),1,length(A)^2)]; % 1*(S+S^2)
BB = repmat(B, numel(U), 1);              % NS * (S+S^2)

UU = reshape(U, numel(U), 1);             % NS*1

JH = (BB'*BB)\(UU'*BB)';
JJ = JH(1:length(A));
HH = reshape(JH(length(A)+1:end), length(A), length(A));

