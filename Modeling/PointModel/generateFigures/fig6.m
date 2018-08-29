% Naive path
path_finding(1000, 3000, 5000, false);

% Avoid collision
path_finding(1000, 30, 0, false);

% Penalize close collisions
path_finding(1000, 30, 5000, false);

% Impotance sampling
path_finding(1000, 30, 5000, true);