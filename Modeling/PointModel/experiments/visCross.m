% Visualize the results from the crossvalidation
%res = load('res_6f_norm_long.mat');
%res = load('res_5f_qp.mat');
%res = load('res_5f_allqp.mat');
res = load('res_5f_allreg.mat')
cmax = 18;
cmin = 4;
sz  =16;
tsz = 20;
ssz = 14;
res = res.res;
max_order = 5;
figure;

Train = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Train(1:numel(res{d}(:,1)),d) = res{d}(:,2);
end
Tr = Train;
Tr(Train==0)=inf;
imagesc(Tr);
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);

colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
%title('Training loss','FontSize',tsz);
%hcb = colorbar('FontSize',11,'YTick',log([round(cmin) :10,12:6: cmax]) ,'YTickLabel',[round(cmin) :10,12:6: cmax]);
hcb=colorbar;
caxis([cmin, cmax]);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss','FontSize',ssz);

figure;
Val = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Val(1:numel(res{d}(:,1)),d) = res{d}(:,3);
end
V = Val;
V(Val==0)=inf;
imagesc(V);
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);
hcb =colorbar;
caxis([cmin, cmax]);
colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
%title('Validation loss','FontSize',tsz);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss','FontSize',ssz);

figure;
Time = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Time(1:numel(res{d}(:,1)),d) = res{d}(:,4);
end

cmax = max(Time(:));
cmin = min(Time(:));
Ti = Time;
Ti(Ti==0)=inf;
imagesc(Ti);
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);

hcb = colorbar;
caxis([0, 1.8]);
colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
%title('Training time','FontSize',tsz)
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Time (s)','FontSize',ssz);

figure
Time = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Time(1:numel(res{d}(:,1)),d) = res{d}(:,5);
end

cmax = max(Time(:));
cmin = min(Time(:));
Ti = Time;
Ti(Ti==0)=1000;
imagesc(Ti);
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);

hcb = colorbar;
caxis([cmin cmax+0.5]);
colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
%title('Execution time','FontSize',tsz);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Time (s)','FontSize',ssz);

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
yticks(1:3:length(res{1}));
yticklabels(int2str(res{1}(1:3:end,1)));
xticks(1:max_order);

hcb = colorbar;
caxis([1,500]);
colormap hot;
xlabel('order','FontSize',sz);
ylabel('local models','FontSize',sz)
%title('Memory: coefficients learned relative to l = 1, o = 1', 'FontSize',tsz);
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String', 'l * |W|_k','FontSize',ssz);
    