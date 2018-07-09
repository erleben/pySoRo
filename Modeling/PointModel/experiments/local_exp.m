for A = [1,2,6,10]

L = 40;
O = 10;
make = zeros(L,O);
min_conf = zeros(L,O);

for local = 1:L
    for order = 1:O
        min_conf(local,order) = local*sum(arrayfun(@(x)nchoosek(A+x-1,x),1:order));
    end
end

c= 0:0.5:11;
c= round(10.^c);

%[~, hc] = contour(min_conf,11, 'LineWidth',2,'ShowText','on');
%set(hc,'LevelList', c);
figure;
imagesc(log(min_conf));
hold on;
[i,j]=contour(log(min_conf),10);
j.LineColor = 'k';

hcb = colorbar('FontSize',11,'YTick',log(c),'YTickLabel',c);

xlabel('order','FontSize',13)
ylabel('local models','FontSize',13)

colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String', 'K_{min}','FontSize',12);
    
end