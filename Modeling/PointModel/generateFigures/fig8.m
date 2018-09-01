res = load('data_files/allreg5f.mat');  % Uncomment for the "minimum devaion method"
%res = load('data_files/allqp5f1.mat'); % Uncomment for the "regression
%tree method


% Max and min color bar, fontsize ++
cmax = 18;
cmin = 4;
sz  =16;
tsz = 20;
ssz = 14;
res = res.res;
max_order = 5;


% Training loss
figure;
Train = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Train(1:numel(res{d}(:,1)),d) = res{d}(:,2);
end

Train(Train==0)=inf;
imagesc(Train);
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);

colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
title('Training loss','FontSize',tsz);
hcb=colorbar;
caxis([cmin, cmax]);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss (steps)','FontSize',ssz);
set(gcf,'color','w');
% Validation loss
figure;
Val = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Val(1:numel(res{d}(:,1)),d) = res{d}(:,3);
end

Val(Val==0)=inf;
imagesc(Val);
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);
hcb =colorbar;
caxis([cmin, cmax]);
colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
title('Validation loss','FontSize',tsz);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss (steps)','FontSize',ssz);
set(gcf,'color','w');

%Exectution time
figure;
Time = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Time(1:numel(res{d}(:,1)),d) = res{d}(:,5);
end

cmax = max(Time(:));
cmin = min(Time(:));

Time(Time==0)=inf;
imagesc(Time);
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);

hcb = colorbar;
caxis([cmin cmax+0.5]);
colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
title('Execution time','FontSize',tsz);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Time (s)','FontSize',ssz);
set(gcf,'color','w');

