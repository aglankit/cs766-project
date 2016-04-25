function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H,...
    dest_canvas_width_height)

img_width = dest_canvas_width_height(1,1);
img_height = dest_canvas_width_height(1,2);
src_img_width = size(src_img, 2);
src_img_height = size(src_img, 1);

target_img = zeros(img_height, img_width, 3);
mask = zeros(img_height, img_width);
img_points = [];

block1 = ones(img_height, 1);
temp = 1:img_height;
block2 = temp';

for x = 0:img_width-1
    img_points = [img_points; block1 + x, block2];
end

pixel = round(applyHomography(resultToSrc_H, img_points));

img_points_x = pixel(:, 1);
img_points_y = pixel(:, 2);

set1 = find(img_points_x > 1 & img_points_x < src_img_width);
set2 = find(img_points_y > 1 & img_points_y < src_img_height);

mask_index = intersect(set1, set2);
mask(mask_index) = 1;

for y = 1:img_height
    for x = 1:img_width
        i = sub2ind(size(mask), y, x);
        if (mask(y,x) == 1)
            target_img(y,x,:) = src_img(pixel(i,2), pixel(i,1),:);
        end
    end
end

result_img = target_img;