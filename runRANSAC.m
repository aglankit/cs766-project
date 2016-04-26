function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)
num_points = size(Xs, 1);
s = 4;
inliers = 0;

for iter = 1:ransac_n
index_list = randperm(num_points, s);
H_3x3 = computeHomography(Xs(index_list, :), Xd(index_list, :));
pred_Xd = applyHomography(H_3x3, Xs);

step1 = pred_Xd - Xd;
step2 = step1 .* step1;
step2(:, 1) = step2(:,1) + step2(:,2);
step3 = sqrt(step2(:, 1));
result = find(step3 < eps);

if (size(result, 1) > inliers)
    inliers = size(result, 1);
    inliers_id = result';
    H = H_3x3;
end

end

