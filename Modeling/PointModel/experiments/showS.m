ll = load('l1o1.mat');
ll = ll.res;

lh = load('l1o10.mat');
lh = lh.res;

hl = load('l10o1.mat');
hl = hl.res;

hh = load('l10o10.mat');
hh = hh.res;

figure;
hold on;
plot(sigmas,ll(:,1),'LineWidth',2,'LineStyle','-','Color','r');
plot(sigmas,lh(:,1),'LineWidth',2,'LineStyle','-','Color','g');
plot(sigmas,hl(:,1),'LineWidth',2,'LineStyle','--','Color','b');
plot(sigmas,hh(:,1),'LineWidth',2,'LineStyle','--');

legend('1 1st ordered model', '1 10th ordered models','10 1st ordered models','10 10th ordered models');
xlabel('\sigma','FontSize',15)
ylabel('Loss','FontSize',12);
