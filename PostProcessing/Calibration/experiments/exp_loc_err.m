
res = zeros(size(exp_local(1,1,1)));
cnt = 0;
for i = 1:10
    for j = setdiff(1:10,i)
        res = res + exp_local(2,i,j);
        cnt = cnt + 1;
    end
end

res = res/cnt;
plot(res(:,1),res(:,2)-res(:,1))
hold on;
plot(res(:,1),res(:,4)-res(:,1))
legend('Global test', 'Local test');

global_err = mean(abs(res(:,2)-res(:,1)))
local_err = mean(abs(res(:,4)-res(:,1)))