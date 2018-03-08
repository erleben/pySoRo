function [ traction_info, state ] = add_external_force(state, mesh, meshpointinds, attachmentpts, K, vertexForce)

if nargin < 6
    vertexForce = false;
end

%--- traction   -----------------------------------------------------------
tx = zeros(  size(mesh.x0) );
ty = zeros(  size(mesh.y0) );
tz = zeros(  size(mesh.z0) );
FF = [];

%--- Find the triangle surfaces where we want to apply the surface --------

trep  = triangulation(mesh.T, mesh.x0, mesh.y0, mesh.z0);
ff    = freeBoundary(trep);

for ind = 1:length(meshpointinds)
    pind = meshpointinds(ind);
    x = state.x(pind);
    y = state.y(pind);
    z = state.z(pind);
    p_mesh = [x,y,z];

    
    % This is the force vector to apply to the point
    F = K*(attachmentpts(ind,:)-p_mesh);
    
    
    if ~vertexForce
    
        %Find all surfaces connected to the point
        A = [];
        triinds = [];
        for sind = 1:length(ff)
            if ismember(pind, ff(sind, :))
                inds = setdiff(ff(sind, :), [pind]);
                %--- Get vertex coordinates -----------------------------------------------
                
                Pi = [ state.x(pind), state.y(pind), state.z(pind) ]';
                Pj = [ state.x(inds(1)), state.y(inds(1)), state.z(inds(1)) ]';
                Pk = [ state.x(inds(2)), state.y(inds(2)), state.z(inds(2)) ]';
                
                %--- Compute face areas ---------------------------------------------------
                Avec =  cross( (Pj - Pi), (Pk - Pi) )  ./ 2.0 ;
                A    =  [A, sum( Avec.*Avec, 1).^(0.5)];
                triinds = [triinds, sind];
            end
        end
        
        %--- We apply a constant traction onto all nodes on the surface -----------
        
        FF = [FF; ff(triinds,:)];
        W = A/sum(A);
        
        for b = 1:length(triinds)
            aind=ff(triinds(b),:);
            for ang = 1:3
                tx(aind(ang)) = tx(aind(ang)) + (F(1)*W(b)/3);
                ty(aind(ang)) = ty(aind(ang)) + (F(2)*W(b)/3);
                tz(aind(ang)) = tz(aind(ang)) + (F(3)*W(b)/3);
            end
        end
    else
        state.fx(pind) = F(1);
        state.fy(pind) = F(2);
        state.fz(pind) = F(3);
    end
  
end
%--- Bundle all info into one structure ----------------------------------
traction_info = struct(...
    'F', FF,...
    'tx', tx,...
    'ty', ty,...
    'tz', tz...
    );

end