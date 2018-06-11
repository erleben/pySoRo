    function path = get_path(a_0, s_goal, obstacle_c, obstacle_r, p_model, pf_model, rf_model, A)
        num_samples = 1000;
        connectivity = 10;
        
        a_goal = p_model(s_goal');
        
        sample=round(rand(num_samples, 2).*(A.max-A.min)+A.min);
        sample = [a_0; a_goal; sample];
        
        SSR = rf_model(sample);
        SSP = pf_model(sample);
        num_p = size(SSR,2)/3;
        
        no_collision = true(num_samples+2,1);
        
        for i = 1:num_p
            no_collision =no_collision.*logical(sqrt(sum((SSR(:,3*i-2:3*i)-obstacle_c).^2,2))>obstacle_r);
        end
        
        no_collision(1:2) = true;
        no_collision = logical(no_collision);
        
        sample = sample(no_collision,:);
        
        
        % Create a weighted graph where each node is a configration. Connected to
        % the closest configurations. The weight is the distance between them.
        dist_mat = pdist2(sample,sample);
        [~, di] = mink(dist_mat, connectivity);
        for i = 1:size(dist_mat,1)
            dist_mat(i, di(:,i)) = -dist_mat(i,di(:,i));
        end
        dist_mat(dist_mat>0) = 0;
        dist_mat = -dist_mat;
        
        G=digraph(dist_mat);
        path_idx = shortestpath(G,1,2);
        path = round(sample(path_idx,:));
        
    end