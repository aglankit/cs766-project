function [search_window, src_img] = get_template_search_image(orig_img, test_pts_nx2, warped_img, dest_pts_nx2)
% Take out the small window for search
w_height = dest_pts_nx2(3, 2) - dest_pts_nx2(1, 2);
w_width = dest_pts_nx2(3, 1) - dest_pts_nx2(1, 1);
ymin = max(1, dest_pts_nx2(1, 2) - w_height/2);
ymax = min(size(warped_img, 1), dest_pts_nx2(3, 2) + w_height/2);
xmin = max(1, dest_pts_nx2(1, 1) - w_width/2);
xmax = min(size(warped_img, 2), dest_pts_nx2(3, 1) + w_width/2);
search_window = imfill(warped_img(ymin:ymax, xmin:xmax));

% Take out the input image
w_height = test_pts_nx2(3, 2) - test_pts_nx2(1, 2);
w_width = test_pts_nx2(3, 1) - test_pts_nx2(1, 1);
ymin = max(1, test_pts_nx2(1, 2));
ymax = min(size(orig_img, 1), test_pts_nx2(3, 2));
xmin = max(1, test_pts_nx2(1, 1));
xmax = min(size(orig_img, 2), test_pts_nx2(3, 1));
src_img = imfill(orig_img(ymin:ymax, xmin:xmax));
disp(size(src_img));