function A_JK = mixed_term(n,s)

A_JK = [];
if n == 1
    A_JK = s;
else
    
for i = 0:s
   L=mixed_term(n-1,s-i);
   A_JK = [A_JK;[repmat(i,size(L,1),1), L ]];
end   
end 
end