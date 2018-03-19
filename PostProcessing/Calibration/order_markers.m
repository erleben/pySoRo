function [tracked_new, estimated] = order_markers(tracked_prev, new)

max_distance  = 0.02; 

dist_mat = pdist2(tracked_prev(:,2:end), new);
inds = tracked_prev(:,1);
tracked_new = nan(size(tracked_prev));
tracked_new(:,1) = tracked_prev(:,1);
linked_prev = [];
linked_new = [];
estimated = [];
 
while true
    [i,j]=find(dist_mat==min(dist_mat(:)));
    
    if (dist_mat(i(1),j(1)) > max_distance) || isnan(dist_mat(i(1),j(1)))
        break
    end
      
    tracked_new(inds(i(1)),2:end) =  new(j(1),:);
    dist_mat(i(1),:) = inf;
    dist_mat(:,j(1)) = inf;
    linked_prev = [linked_prev; i(1)]; 
    linked_new = [linked_new; j(1)];
end
 

untracked_prev = tracked_prev(setdiff(1:size(tracked_prev,1),linked_prev),:); 
untracked_new = new(setdiff(1:size(new,1),linked_new),:);

tracked_in_prev = tracked_prev(~isnan(tracked_new(:,2)),1);
tracked_in_new = tracked_prev(~isnan(tracked_new(:,2)),1);
tracked_in_both = intersect(tracked_in_new,tracked_in_prev);

ps_prev = tracked_prev(tracked_in_both,2:end);
ps_new = tracked_new(tracked_in_both,2:end);

for i = 1:size(untracked_prev,1)
    ind = untracked_prev(i,1);
    p = untracked_prev(i,2:end);
    new_est = (p/ps_prev)*(ps_new);
    tracked_new(ind,:) = [ind, new_est];
    estimated = [ind,estimated]
end 

num_tracked = tracked_new(end,1); 
num_untracked = size(untracked_new,1);
tracked_new = [tracked_new; [(num_tracked+1:num_tracked+num_untracked)',untracked_new]];
end