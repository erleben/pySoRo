function d = dbox( p, width, height, depth )
% DBOX -- Compute signed distance values of the specified points wrt the
% given box size. This function is used by the DistMesh meshing tool to
% generate a bar mesh.
%  
%  p   -  An array of points, each row is a point, first column is
%         x-coords, second is y-cords, and third is z-coords.
%
%  width   - The width of the box.
%  height  - The height of the box.
%  depth   - The depth of the box.
%
% Copyright 2011, Kenny Erleben

  half_width  = 0.5*width;
  half_height = 0.5*height;
  half_depth  = 0.5*depth;

  % Reflect into positive orctant 
  x = abs(p(:,1));
  y = abs(p(:,2));
  z = abs(p(:,3));
  
  x_int = max( half_width  -  x, 0 );
  y_int = max( half_height -  y, 0 );
  z_int = max( half_depth  -  z, 0 );
  d = - min( x_int, min( y_int, z_int ) );
  
  x_ext = max( x - half_width , 0 );
  y_ext = max( y - half_height, 0 );
  z_ext = max( z - half_depth , 0 );
  d_ext = sqrt(x_ext.^2 + y_ext.^2 +  z_ext.^2); 
  
  d(d_ext>0) =  d_ext(d_ext>0);
end
