%function stitched_img = stitchImg(img1, img2, img3)
function stitched_img = stitchImg(varargin)
img1 = varargin{1};
img2 = varargin{2};
img3 = varargin{3};

[inliers_id, H_3x3] = getHomography(img2, img1);
shift = get_img_shifts(img2, H_3x3);
dest_canvas_width_height = build_canvas_dim(img2, img1, shift);

H_3x3 = [1, 0, shift(1, 1); 0, 1, shift(1, 3); 0, 0, 1] * H_3x3;
[masks, proj_imgs] = backwardWarpImg(img2, inv(H_3x3), ...
    dest_canvas_width_height);

H_3x3 = [1, 0, shift(1, 1); 0, 1, shift(1, 3); 0, 0, 1];
[maskd, proj_imgd] = backwardWarpImg(img1, inv(H_3x3), ...
    dest_canvas_width_height);

out_img = blendImagePair(proj_imgs, masks, proj_imgd, maskd, 'blend');

[inliers_id, H_3x3] = getHomography(img3, out_img);
shift = get_img_shifts(img3, H_3x3);
dest_canvas_width_height = build_canvas_dim(img3, out_img, shift);

H_3x3 = [1, 0, -shift(1, 1); 0, 1, shift(1, 3); 0, 0, 1] * H_3x3;
[masks, proj_imgs] = backwardWarpImg(img3, inv(H_3x3), ...
    dest_canvas_width_height);

H_3x3 = [1, 0, -shift(1, 1); 0, 1, shift(1, 3); 0, 0, 1];
[maskd, proj_imgd] = backwardWarpImg(out_img, inv(H_3x3), ...
    dest_canvas_width_height);

stitched_img = blendImagePair(proj_imgs, masks, proj_imgd, maskd, 'blend');

figure; imshow(stitched_img);

function dest_canvas_width_height = build_canvas_dim(imgs, imgd, shift)
width = max(max(size(imgs, 2), size(imgd, 2)), min(size(imgs, 2), size(imgd, 2)) + shift(1, 1) + shift(1, 2));
%height = max(size(imgs, 1), size(imgd, 1));
height = max(max(size(imgs, 1), size(imgd, 1)), min(size(imgs, 1), size(imgd, 1)) + shift(1, 3) + shift(1, 4));
%dest_canvas_width_height = [width + shift(1, 1) + shift(1, 2), height + shift(1, 3) + shift(1, 4)];
dest_canvas_width_height = [width, height];
    
function [inliers_id, H_3x3] = getHomography(imgs, imgd)
[xs, xd] = genSIFTMatches(imgs, imgd);
% Use RANSAC to reject outliers
ransac_n = 5000; % Max number of iteractions
ransac_eps = 10; % Acceptable alignment error 
[inliers_id, H_3x3] = runRANSAC(xs, xd, ransac_n, ransac_eps);

function shift = get_img_shifts(imgs, H_3x3)
imgs_width = size(imgs, 2);
imgs_height = size(imgs, 1);
boundaries = [1, 1; imgs_width, 1; imgs_width, imgs_height; 1, imgs_height];
new_boundaries = round(applyHomography(H_3x3, boundaries));

shift_left = 0;
shift_right = 0;
shift_top = 0;
shift_bottom = 0;

if (min(new_boundaries(:, 1)) < 1)
    shift_left = abs(min(new_boundaries(:, 1)));
end
if (min(new_boundaries(:, 2)) < 1)
    shift_top = abs(min(new_boundaries(:, 2)));
end
if (max(new_boundaries(:, 1)) > imgs_width)
    shift_right = max(new_boundaries(:, 1)) - imgs_width;
end
if (max(new_boundaries(:, 2)) > imgs_height)
    shift_bottom = max(new_boundaries(:, 2)) - imgs_height;
end

shift = [shift_left, shift_right, shift_top, shift_bottom];
