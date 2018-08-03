% Comparison of Taylor appriximation and polynomial regression of real
% data, repeated

tres = zeros(30,2);
pres = zeros(30,2);

for i = 1:30
    [tr, val] = exp_twoParam(1,70,false,false,true);
    tres(i,1)=tr;
    tres(i,2)=val;
    [tr, val] = exp_twoParam(1,70,false,true,true);
    pres(i,1)=tr;
    pres(i,2)=val;
end

plot(1:30,tres(:,2),'b',1:30,tres(:,1),'b--',1:30,pres(:,2),'r',1:30,pres(:,1),'r--');

legend('TA: validation loss','TA: training loss','PR: validation loss','PR: training loss')