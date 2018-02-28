function drawForce(state, mesh)


figure;
isedge = logical((mesh.x0>4.9));

x = state.x(isedge);
y = state.y(isedge);
z = state.z(isedge);

fx = state.fx(isedge);
fy = state.fy(isedge);
fz = state.fz(isedge);

quiver3(x,y,z,fx,fy,fz);
hold on;
tetramesh(mesh.T,[state.x, state.y, state.z])
view([0 90]);
end