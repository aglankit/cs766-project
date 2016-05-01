function far_obj_rect = search_object_in_far_image(near_obj_rect)
        mat_struct = load('homography_2.mat');
    homography = mat_struct.homography_mat;

    % temporarily using fixed image
    orig_img = imfill(imread(strcat('temp40.png')));
    warped_img = imfill(imread(strcat('temp90.png')));
    
    orig_img = convert_image_to_uint8(orig_img);
    warped_img = convert_image_to_uint8(warped_img);
    
    % Select Object (Manual for now)
    figure; imshow(orig_img);
    
    rect_area = round(getrect);
    %rect_area = [65  156  99  136];
    xmin      = rect_area(1);
    ymin      = rect_area(2);
    width     = rect_area(3);
    height    = rect_area(4);
    disp(rect_area);

    test_pts_nx2 = [[xmin, ymin]; [xmin + width, ymin]; [xmin + width, ymin + height]; [xmin, ymin + height]];
    object_img = orig_img(ymin:ymin+height, xmin:xmin+width);
    obj_dist = calculate_object_distance(orig_img, rect_area);
        
    figure; imshow(object_img);
    
    % Apply homography (Fixed for now, need to calculate on demand)
    dest_pts_nx2 = applyHomography(homography(:, :, 14, 11), test_pts_nx2);

    % Search the object in a distant image
    [search_window, src_img] = get_template_search_image(orig_img, test_pts_nx2, warped_img, dest_pts_nx2);

    % Confirm if transformation is working;
    tform = projective2d(homography(:, :, 14, 11)');
    src_img = imwarp(src_img, tform);
    figure; imshow(src_img);

    max_corr = 0;
    for i = 0.6:-0.1:0.6
        temp_src_img = imresize(src_img, i);
        [temp_rect, temp_corr] = search_template_in_window(search_window, temp_src_img);
        if temp_corr > max_corr
            max_corr = temp_corr;
            rect = temp_rect;
        end
        disp(max_corr);
    end
    
    w_height = dest_pts_nx2(3, 2) - dest_pts_nx2(1, 2);
    w_width = dest_pts_nx2(3, 1) - dest_pts_nx2(1, 1);
    rect(1, 1) = rect(1, 1) + dest_pts_nx2(1, 1) - w_width/2;
    rect(1, 2) = rect(1, 2) + dest_pts_nx2(1, 2) - w_height/2;
    rect = round(rect);
    figure; imshow(drawBox(warped_img, rect, 255, 3));
    
function obj_dist = calculate_object_distance(img, object_area)
    xmin = object_area(1);
    ymin = object_area(2);
    width = object_area(3);
    height = object_area(4);

    object_img = img(ymin:ymin+height, xmin:xmin+width);
    object_img(isnan(object_img)) = 0;
    [row, col, vals] = find(object_img);
    obj_dist = mode(vals);
    
function img = convert_image_to_uint8(orig_img)
    max_color = double(max(max(orig_img)));
    img = zeros(size(orig_img));
    img = uint8(round(255 * double(orig_img)/max_color));