% This scripts assumes you have a number of data sets avaliable that are
% caputred under the same conditions, (number of steps, step size, 
% calibration and so on). One set is used for training a model and the
% others are used for testing. This is done for all orders specified.
% The hope is to reveal 
%   -non-reproducable factors if any, such as
%       placiticity or random noise. 
%   -difference in training and testing loss


orders = 2;
interv = 1;
num_o = round(orders/interv);
train_err = zeros(8,num_o);
test_err = zeros(8,num_o);

ind_o = 1;
for ord = 1:interv:orders
    ind = 1;
    for i = [3,4,5,6,7,8,9,10]
        [te, tr] = exp_rep(ord,2,i, false);
        train_err(ind,ind_o) = tr;
        test_err(ind,ind_o) = te;
        ind = ind + 1;
    end
    ind_o = ind_o + 1;
end

figure;
plot(test_err(:,1:min(num_o,10)))
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

disp('test_err')
mean(test_err)

disp('train_err');
mean(train_err)
