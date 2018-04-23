function [P,A] = reduceData(P,A)

j = 3;
P =P(:,j:j+2); 

for i = fliplr(1:length(A))
    if sum(A(i,:),2)<200
        A(i,:) = [];
        P(i,:) = [];
    end
end
end