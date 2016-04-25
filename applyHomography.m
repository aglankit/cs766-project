function dest_pts_nx2 = applyHomography(H_3x3, src_pts_nx2)
num_points = size(src_pts_nx2, 1);
inp_mat = [src_pts_nx2, ones(num_points,1)]';
temp = (H_3x3 * inp_mat);
temp(1,:) = temp(1,:)./temp(3,:);
temp(2,:) = temp(2,:)./temp(3,:);
dest_pts_nx2 = (temp(1:2, :))';
