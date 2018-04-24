function  drawForce(state, mesh, pc, type)

if nargin < 4
    type = 1;
end

trep  = triangulation(mesh.T, mesh.x0, mesh.y0, mesh.z0);
ff    = freeBoundary(trep);
isedge = unique(ff);
x = state.x(isedge);
y = state.y(isedge);
z = state.z(isedge);

if type == 1
    info_x = state.fx(isedge);
    info_y = state.fy(isedge);
    info_z = state.fz(isedge);
    quiver3(x,y,z,info_x,info_y,info_z);
    hold on;
elseif type == 2
    info_x = state.vx(isedge);
    info_y = state.vy(isedge);
    info_z = state.vz(isedge);
    quiver3(x,y,z,info_x,info_y,info_z);
    hold on;
else
    info_x = state.fx(isedge);
    info_y = state.fy(isedge);
    info_z = state.fz(isedge);
    quiver3(x,y,z,info_x,info_y,info_z,'r');
    hold on;

    info_x = state.vx(isedge);
    info_y = state.vy(isedge);
    info_z = state.vz(isedge);
    quiver3(x,y,z,info_x,info_y,info_z,'b');

end


tetramesh(mesh.T,[state.x, state.y, state.z])


if nargin > 2
    pcshow(pc, 'MarkerSize', 200)
end
view([0 90]);
end