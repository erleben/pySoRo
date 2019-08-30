function d = point_to_line_distance(pt, v1, v2, v3)
      a = v1 - v2;
      b = pt - v2;
      d = norm(cross(a,b)) / norm(a);
end


