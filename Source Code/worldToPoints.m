function imagepoint = worldToPoints(cameraParams, R, t, worldpoint)
P = cameraMatrix(cameraParams, R, t);
p = [worldpoint(1,1), worldpoint(1,2), 0, 1] * P;
imagepoint(1,1) = p(1) / p(3);
imagepoint(1,2) = p(2) / p(3);