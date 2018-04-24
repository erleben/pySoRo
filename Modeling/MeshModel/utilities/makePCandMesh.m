ICP_merged=pcmerge(PC_to, pctransform(from_transformed_PC,tf),0.001);
ICP_merged=pointCloud(ICP_merged.Location);
PS=pcdownsample(ICP_merged, 'gridAverage', 0.008);
PS=pcdenoise(PS,'Threshold', 0.25);

%Find dimesnosions of bar
S=pcfitcylinder(PS, 0.01);
r = 1.3;
PTS = [mesh.x0, mesh.y0, mesh.z0];
not_base_ind = PTS(:,3)>-1.9;
PTS_N = (PTS./(max(PTS)-min(PTS))).*[S.Height, r*S.Radius, r*S.Radius];


TR = triangulation(mesh.T, double(PTS));
ff    = freeBoundary(TR);
surf_p  = unique(reshape(ff, length(ff)*3, 1));
free=zeros(size(mesh.x0));
free(surf_p) = 1;


%Loc = PTS_N(logical(O.*not_base_ind),:);
Loc = PTS_N(logical(free),:);

mesh_pc = pointCloud(Loc);

figure;
pcshow(mesh_pc);
 
tform = pcregrigid(PS, mesh_pc);
 
TTT=pctransform(PS, tform);

pcshow(TTT);
hold on;
%pcshow(mesh_pc)

tetramesh(mesh.T,PTS_N)

method = fem_method();
params  = create_params('soft');
profile = true;


%TTT=pcdownsample(TTT, 'random', 0.7);
goal_pos = double(TTT.Location);
meshh = mesh;
PTS_N=double(PTS_N);
meshh.x0 = PTS_N(:,1);
meshh.y0 = PTS_N(:,2);
meshh.z0 = PTS_N(:,3);