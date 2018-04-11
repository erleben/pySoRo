orders = 4;

train_err = zeros(8,orders);
test_err = zeros(8,orders);

for ord = 1:orders
    ind = 1;
    for i = [2,3,4,5,6,7,8,9,10]
        [te, tr] = exp_rep(ord,1,i);
        train_err(ind,ord) = tr;
        test_err(ind,ord) = te;
        ind = ind + 1;
    end
end

figure;
plot(test_err(:,1:min(orders,4)))
ylabel('Mean alpha error');
xlabel('time');
legend('Order 1', 'Order 2', 'Order 3', 'Order 4');

figure;
plot(mean(train_err));
hold on;
plot(mean(test_err))
xlabel('order');
ylabel('Mean alpha error');
legend('Train error','Test error');
