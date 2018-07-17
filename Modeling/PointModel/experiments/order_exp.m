% Makes a heatmap of the minimum number of required data points as a
% function of #parameters and order

make = zeros(20,20);
min_conf = zeros(20,20);

for a_size = 1:20
    for order = 1:20
        min_conf(a_size,order) = sum(arrayfun(@(x)nchoosek(a_size+x-1,x),1:order));
        make(a_size,order) = 2^(a_size+order-1);
    end
end

c= 1:11;
c= 10.^c;

imagesc(log(min_conf));
hold on;
[i,j]=contour(log(min_conf),10);
j.LineColor = 'k';

hcb = colorbar('FontSize',11,'YTick',log(c),'YTickLabel',c);

xlabel('order','FontSize',13)
ylabel('p','FontSize',13)

colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String', 'K^{-1}','FontSize',12);
    