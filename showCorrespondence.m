function result_img = ...
    showCorrespondence(orig_img, warped_img, src_pts_nx2, dest_pts_nx2)
comb_img = [orig_img, warped_img];
offset_col = size(orig_img, 2);
dest_pts_nx2(:,1) = dest_pts_nx2(:, 1) + offset_col;

fh1 = figure(); imshow(comb_img);

hold on;
for i = 1:size(src_pts_nx2, 1)
    line([src_pts_nx2(i, 1); dest_pts_nx2(i, 1)], ...
         [src_pts_nx2(i, 2); dest_pts_nx2(i, 2)], ...
         'LineWidth',1, 'Color', [0, 1, 0]);
end

annotated_img = saveAnnotatedImg(fh1);
result_img = annotated_img;
