back_name = 'data/618204002727color_back.tif';
fore_name = 'data/618204002727color_fore.tif';

[isBall, radius, centroid]= getBallProps(back_name,fore_name, 1);

pc = pcread('data/618204002727fore.ply');
tex_name = 'data/618204002727texture_back.tif';
getBallDepth(isBall, pc, tex_name);