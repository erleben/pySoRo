% This scripts assumes you have a number of data sets avaliable that are
% caputred under the same conditions, (number of steps, step size,
% calibration and so on). One set is used for training a model and the
% others are used for testing. This is done for all orders specified.
% The hope is to reveal
%   -non-reproducable factors if any, such as
%       placiticity or random noise.
%   -difference in training and testing loss


order = 1;
train_err = zeros(8,1);
test_err = zeros(8,1);
ind = 1;

for i = [2,3,4,5,7,8,9,10]
    [te, tr] = exp_rep(order ,6 ,i, false, true, 3);
    train_err(ind) = tr;
    test_err(ind) = te;
    ind = ind + 1;
end

figure;
plot([2:9],test_err)
ylabel('Mean configuration error');
xlabel('Data set number');
legend('Predicted configuration error');



disp('test_err')
mean(test_err)

disp('train_err');
mean(train_err)