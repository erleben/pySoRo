function [ A ] = fem_assemble_global_matrix(mesh, Ae)
% Copyright 2011, Kenny Erleben

% Get number of elements and vertices
E = length(mesh.T(:,1));
V = length(mesh.x0);

% Coordinate offsets used when mapping local coordiantes
% to global variable indices.
yoffset = V;
zoffset = 2*V;

% Clear all previously assembled values
A  = repmat(zeros(3,3),V,V);

% Now do assembly process
for e=1:E
 
  % Get tetrahedron global indices
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

  % Get local blocks 
  tmp  = Ae(:,(12*(e-1)+1):(12*e));

  % Now we can add the element matrices to the global matrices
  for r=1:12        
    for c=1:12
      A( gidx(r), gidx(c)) = A( gidx(r), gidx(c)) + tmp( r, c );
    end
  end
end

end