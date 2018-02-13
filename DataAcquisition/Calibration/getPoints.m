back_name = 'data/618204002727color_back.tif';
fore_name = 'data/618204002727color_fore.tif';

balls = getBallProps(back_name,fore_name);

pc = pcread('data/618204002727fore.ply');
tex_name = 'data/618204002727texture_back.tif';
spheremodels=getSpheres(balls, pc, tex_name, true);