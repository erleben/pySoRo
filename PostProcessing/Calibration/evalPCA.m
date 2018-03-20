%Test the PCA

mm = [];
for k = 1:10 
[mdist, varper] = findModes(k);
mm = [mm, mdist];
end

subplot(1,2,1);
plot(mm);
title('Mean precisionloss pr marker');
xlabel('number of modes');
ylabel('meter');

subplot(1,2,2);
plot(varper(1:10))
title('Variability explained by the model');
xlabel('number of modes');
ylabel('fraction of variability');