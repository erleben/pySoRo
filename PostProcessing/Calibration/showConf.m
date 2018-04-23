function showConf(P,to_draw)

c = 'rgbk';
figure;
for t = to_draw
    for i = 1:51:length(P)
        plot3(P(i:i+50,t*3-2),P(i:i+50,t*3-1),P(i:i+50,t*3),c(mod(i,length(c))+1));
        hold on;
    end
end

figure;
for t  = to_draw
    for i = 1:51
        plot3(P(i:51:end,t*3-2),P(i:51:end,t*3-1),P(i:51:end,t*3),c(mod(i,length(c))+1));
        hold on;
    end
end
end
