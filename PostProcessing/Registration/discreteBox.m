min_len = 0.01;
w = 0.09;
l = 0.065;
h = 0.04;
fd = inline(sprintf('dbox(p,%d,%d,%d)', w,h,l),'p');




[p, T] = distmeshnd(fd,@huniform, min_len,[-w,-l,-h;w,l,h]*1.2,[]);