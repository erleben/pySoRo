function [ h ] = fem_assemble_global_vector(mesh, he)
% Copyright 2011, Kenny Erleben

% Get number of elements and vertices
E = length(mesh.T(:,1));
V = length(mesh.x0);

% Coordinate offsets used when mapping local coordiantes
% to global variable indices.
yoffset = V;
zoffset = 2*V;

% Clear all previously assembled values
h  = repmat(zeros(V,1),3,1);

% Now do assembly process
for e=1:E
 
  % Get global tetrahedron indices
  i = mesh.T(e,1);
  j = mesh.T(e,2);
  k = mesh.T(e,3);
  m = mesh.T(e,4);
    
  % Local vertex coordinate ordering is,
  %
  %  [ i_x i_y i_z j_x j_y j_z k_x k_y k_z m_x m_y m_z ]  . 
  %
  % Coordinates of node with local index $a$ maps to global variable
  % indices as follows
  %
  %     global(a_x) =  a_x
  %     global(a_y) =  yoffset + a_y
  %     global(a_z) =  zoffset + a_z
  %
  % where yoffset = |V| and zoffset= 2|V|.
  %
  gidx = [ 
    i, yoffset + i, zoffset + i, ...
    j, yoffset + j, zoffset + j, ...
    k, yoffset + k, zoffset + k, ...
    m, yoffset + m, zoffset + m
  ];

  % Retrieve local vectors
  tmp  = he(:,e);
  
  % Now we can add the element matrices to the global matrices
  for r=1:12
        
    h( gidx(r) ) = h( gidx(r) ) + tmp(r);
        
  end
end

end