% Script to do meshing that will generate the raw mesh data and save it in
% a mat-file.
%
% Copyright 2011, Kenny Erleben
clear all;
close all;
clc;

rand('state',111); % Always the same results


%--- Table of minimum edge lengths used for mesh generation ---------------
L = [ 0.80, 0.75, 0.65, 0.5, 0.45, 0.4, 0.35, 0.3 ];


%--- Setup a loop and generate meshes of increasing resolution ------------
for i=1:length(L)
  
  min_edge_length = L(i);
  
  display(strcat( 'Generating mesh with min edge length =', num2str(min_edge_length) ) );

  
  fd = inline('dbox(p,0.09,0.065,0.04)','p');
  [p, T] = distmeshnd(fd,@huniform,min_edge_length/100,[-6/100,-3/100,-3/100;6/100,3/100,3/100],[]);

  X = p ( : , 1 ) ;
  Y = p ( : , 2 ) ;
  Z = p ( : , 3 ) ;

  clear fd p;
  
  filename = strcat('bar_T', num2str( length(T)), '_V', num2str( length(X)) , '.mat'  );
  save( filename );
  
  clear filename;
  clear X Y Z T;

end