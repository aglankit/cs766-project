function H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2)
num_points = size(src_pts_nx2, 1);

A = [];

for i = 1:num_points
    xs = src_pts_nx2(i, 1);
    xd = dest_pts_nx2(i, 1);
    ys = src_pts_nx2(i, 2);
    yd = dest_pts_nx2(i, 2);

    A = [A; [xs, ys, 1, 0, 0, 0, -xd*xs, -xd*ys, -xd]; [0, 0, 0, xs, ys, 1, -yd*xs, -yd*ys, -yd]];
end

E = eig(A'*A);
[M,I] = min(E);

[V,D] = eig(A'*A);

H = V(:, I)';

H_3x3 = [H(1:3); H(4:6); H(7:9)];