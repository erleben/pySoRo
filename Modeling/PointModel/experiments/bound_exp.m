val = zeros(20,1);
tv = zeros(20,1);
for a = 1:1
    ind = 1;
    for i = 1:20
        [t,v] = exp_twoParam2(i,2,i>1,1,1);
        val(ind) =val(ind)+ v;
        tv(ind) =tv(ind)+ t;
        ind  =ind +1;
    end
end

mean(val)