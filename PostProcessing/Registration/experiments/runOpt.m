kit = load('kit');
kit = kit.kit;
CP = load('CP_two_param_many.mat');
CP = CP.CP;
num = 32;
T = [CP.states{num}.x; CP.states{num}.y; CP.states{num}.z;];
X0 = kit.X0;

ub = [0,0];
lb = [-7000, -7000];

alpha = @(a) [a(1); a(2); a(1)^2; a(1)*a(2); a(1)^2];
%fun = @(x) mean(sqrt(sum(reshape(X0 + JK' * alpha(x) - T, length(T)/3,3).^2,2)));
fun = @(x) mean(sqrt((X0 + JK' * alpha(x) - T).^2));

fmincon(fun, [0,0], [], [], [], [], lb, ub)

%da1 = @(x) [1; 0; x(1); x(2); 0];
%da2 = @(x) [0; 1; 0;  x(1); x(2)];
%grad = @(x) sum(sum((JK.^2.*2.*da1(x).*alpha(x))' - 2*T.*JK'*da1(x)))/length(T)
