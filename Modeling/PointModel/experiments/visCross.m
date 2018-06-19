%res = load('res_hope.mat');
%res = load('res_same.mat');
%res = load('res_same_sun_bound.mat');
%res = load('res_same_bound30.mat');
%res = load('res_same_tree.mat','res');
res = load('res_5f_norm_long.mat');
cmax = 10;
cmin = 5;

res = res.res;
max_order = 5;
figure;
subplot(2,2,1);
Train = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Train(1:numel(res{d}(:,1)),d) = res{d}(:,2);
end
Tr = Train;
Tr(Train==0)=inf;
imagesc(Tr);
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
xticks(1:max_order);

colormap hot;
xlabel('order');
ylabel('local models')
title('Training');
%hcb = colorbar('FontSize',11,'YTick',log([round(cmin) :10,12:6: cmax]) ,'YTickLabel',[round(cmin) :10,12:6: cmax]);
hcb=colorbar;
caxis([cmin, cmax]);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss');

subplot(2,2,2);
Val = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Val(1:numel(res{d}(:,1)),d) = res{d}(:,3);
end
V = Val;
V(Val==0)=inf;
imagesc(V);
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
xticks(1:max_order);
hcb =colorbar;
caxis([cmin, cmax]);
colormap hot;
xlabel('order');
ylabel('local models')
title('Validation');
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss');

subplot(2,2,3);
Time = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Time(1:numel(res{d}(:,1)),d) = res{d}(:,4);
end

cmax = max(Time(:));
cmin = min(Time(:));
Ti = Time;
Ti(Ti==0)=inf;
imagesc(Ti);
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
xticks(1:max_order);

hcb = colorbar;
caxis([cmin cmax+0.5]);
colormap hot;
xlabel('order');
ylabel('local models')
title('Time');
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Time (s)');


subplot(2,2,4);
Time = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Time(1:numel(res{d}(:,1)),d) = res{d}(:,5);
end

cmax = max(Time(:));
cmin = min(Time(:));
Ti = Time;
Ti(Ti==0)=1000;
imagesc(Ti);
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
xticks(1:max_order);

hcb = colorbar;
caxis([cmin cmax+0.5]);
colormap hot;
xlabel('order');
ylabel('local models')
title('Time');
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','ExecutionTime (s)');

figure;
fst = sum(arrayfun(@(x)nchoosek(2+x-1,x),1));
for o = 1:max_order
    min_conf = sum(arrayfun(@(x)nchoosek(2+x-1,x),1:o));

    res{o}(:,6) = res{o}(:,1).*min_conf/fst;
end
   
Mem = zeros(length(res{1}(:,6)),max_order);
for d = 1:max_order
    Mem(1:numel(res{d}(:,1)),d) = res{d}(:,6);
end
   
cmax = max(Mem(:));
cmin = min(Mem(:));
MM = Mem;
MM(MM==0)=inf;
imagesc(MM);
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
xticks(1:max_order);

hcb = colorbar;
caxis([cmin cmax]);
colormap hot;
xlabel('order');
ylabel('local models')
title('Memory: relative to k = 1, o = 1');
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Memory (s)');
    