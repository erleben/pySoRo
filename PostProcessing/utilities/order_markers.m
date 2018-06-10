function [tracked_new, estimated] = order_markers(tracked_prev, new, add_new)

max_distance  = 0.01; 
 
dist_mat = pdist2(tracked_prev, new);
inds = (1:length(tracked_prev(:,1)))';
tracked_new = nan(size(tracked_prev));

linked_prev = [];
linked_new = [];
estimated = [];
 
while true
    [i,j]=find(dist_mat==min(dist_mat(:)));
    
    if (dist_mat(i(1),j(1)) > max_distance) || isnan(dist_mat(i(1),j(1)))
        break
    end
      
    tracked_new(inds(i(1)),:) =  new(j(1),:);
    dist_mat(i(1),:) = inf;
    dist_mat(:,j(1)) = inf;
    linked_prev = [linked_prev; i(1)]; 
    linked_new = [linked_new; j(1)];
end
 
un_inds = setdiff(1:size(tracked_prev,1),linked_prev);
untracked_prev = tracked_prev(setdiff(1:size(tracked_prev,1),linked_prev),:); 
untracked_new = new(setdiff(1:size(new,1),linked_new),:);

tracked_in_prev = inds(~isnan(tracked_new(:,2)),1);
tracked_in_new = inds(~isnan(tracked_new(:,2)),1);
tracked_in_both = intersect(tracked_in_new,tracked_in_prev);

ps_prev = tracked_prev(tracked_in_both,:);
ps_new = tracked_new(tracked_in_both,:);

for i = 1:size(untracked_prev,1)
    ind = un_inds(i);
    p = untracked_prev(i,:);
    %new_est = (p/ps_prev)*(ps_new);
    new_est = interpolate(p, ps_prev, ps_new);
    tracked_new(ind,:) = new_est;
end 
estimated = un_inds;
if add_new
    tracked_new = [tracked_new; untracked_new];
end
end