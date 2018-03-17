function [tracked_new, untracked_new] = order_markers(tracked_prev, new)

%common_prev = prev_markers.common;
%common = markers;
max_distance  = 0.02;


dist_mat = pdist2(tracked_prev(:,2:end), new);

tracked_new = [];
linked_prev = [];
linked_new = [];

while true
    [i,j]=find(dist_mat==min(dist_mat(:)));
    
    if (dist_mat(i(1),j(1)) > max_distance) || isnan(dist_mat(i(1),j(1)))
        break
    end
      
    tracked_new = [tracked_new; i(1), new(j(1),:)];
    dist_mat(i(1),:) = inf;
    dist_mat(:,j(1)) = inf;
    linked_prev = [linked_prev; i(1)]; 
    linked_new = [linked_new; j(1)];
end

[~, ord] = sort(tracked_new(:,1)); 
tracked_new = tracked_new(ord,:);

untracked_prev = tracked_prev(setdiff(1:size(tracked_prev,1),linked_prev),:); 
untracked_new = new(setdiff(1:size(new,1),linked_new),:);
end 