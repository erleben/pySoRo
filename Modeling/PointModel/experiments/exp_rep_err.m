% This scripts assumes you have a number of data sets avaliable that are
% caputred under the same conditions, (number of steps, step size, 
% calibration and so on). One set is used for training a model and the
% others are used for testing. This is done for all orders specified.
% The hope is to reveal 
%   -non-reproducable factors if any, such as
%       placiticity or random noise. 
%   -difference in training and testing loss


orders = 4;

train_err = zeros(8,orders);
test_err = zeros(8,orders);

for ord = 1:orders
    ind = 1;
    for i = [2,3,4,5,6,7,8,9,10]
        [te, tr] = exp_rep(ord,2,i, false);
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
