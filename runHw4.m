function runHw4(varargin)
% runHw4 is the "main" interface that lists a set of 
% functions corresponding to the problems that need to be solved.
%
% Note that this file also serves as the specifications for the functions 
% you are asked to implement. In some cases, your submissions will be autograded. 
% Thus, it is critical that you adhere to all the specified function signatures.
%
% Usage:
% runHw4                       : list all the registered functions
% runHw4('function_name')      : execute a specific test
% runHw4('all')                : execute all the registered functions

% Settings to make sure images are displayed without borders
orig_imsetting = iptgetpref('ImshowBorder');
iptsetpref('ImshowBorder', 'tight');
temp1 = onCleanup(@()iptsetpref('ImshowBorder', orig_imsetting));

% FYI challenge1e takes ~4minutes and challenge1f takes ~15mins
% challenge1f uses IMG_* images
fun_handles = {@generate_homography_matrix, @read_and_use_homography_matrix, @generate_points, ...
               @detect_object, @get_homography, @use_kinect_camera, @get_object_in_color};

% Call test harness
runTests(varargin, fun_handles);

function read_and_use_homography_matrix()
    mat_struct = load('homography_2.mat');
    homography = mat_struct.homography_mat;

    % temporarily using fixed image
    %orig_img = imfill(imread(strcat('temp40.png')));
    %warped_img = imfill(imread(strcat('temp90.png')));
    orig_img = imfill(imread(strcat('calib/depth_52.png')));
    warped_img = imfill(imread(strcat('calib/depth_41.png')));
    orig_img_c = imfill(imread(strcat('calib/color_52.png')));
    warped_img_c = imfill(imread(strcat('calib/color_41.png')));

    orig_img_u = orig_img;
    warped_img_u = warped_img;
    
    orig_img = convert_image_to_uint8(orig_img);
    warped_img = convert_image_to_uint8(warped_img);
    
    % Select Object (Manual for now)
    figure; imshow(orig_img);
    %rect_area = getrect;
    rect_area = [223   86   96   88];
    xmin      = rect_area(1);
    ymin      = rect_area(2);
    width     = rect_area(3);
    height    = rect_area(4);

    init_img = drawBox(orig_img, rect_area, 255, 3);
    figure; imshow(init_img);
    imwrite(init_img, 'init_img.png');
    disp(rect_area);
    
    test_pts_nx2 = [[xmin, ymin]; [xmin + width, ymin]; [xmin + width, ymin + height]; [xmin, ymin + height]];
    object_img = orig_img(ymin:ymin+height, xmin:xmin+width);
    obj_dist = calculate_object_distance(orig_img_u, rect_area);
    disp(obj_dist);
    figure; imshow(object_img);
    color_points_near = [203, 923; 443, 923; 443, 1221; 203, 1221];
    
    figure; imshow(orig_img_c);
    hold on; plot(color_points_near(:,2), color_points_near(:,1), 'ws', 'MarkerFaceColor', [1 1 1]);
    
    % Apply homography (Fixed for now, need to calculate on demand)
    dest_pts_nx2 = applyHomography(homography(:, :, 16, 14), test_pts_nx2);

    % Search the object in a distant image
    [search_window, src_img] = get_template_search_image(orig_img, test_pts_nx2, warped_img, dest_pts_nx2);

    max_corr = 0;
    for i = 0.7:-0.1:0.7
        disp(i)
        temp_src_img = imresize(src_img, i);
        [temp_rect, temp_corr] = search_template_in_window(warped_img, dest_pts_nx2, search_window, temp_src_img);
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
    obj_dist = calculate_object_distance(warped_img_u, rect);
    
    % y, x format
    color_points_far = [356, 943; 550, 943; 550, 1151; 356, 1151];
    imwrite(drawBox_color(warped_img_c, [color_points_far(1, 2), color_points_far(1, 1), ...
            color_points_far(3, 2) - color_points_far(1, 2), color_points_far(3, 1) - color_points_far(1, 1)], [255, 0, 0], 3), 'inter/color_far.png');
    
    figure; imshow(warped_img_c);
    hold on; plot(color_points_far(:,2), color_points_far(:,1), 'ws', 'MarkerFaceColor', [1 1 1]);
    %imshow(mapped_color_img(rect(1,2):rect(1,2)+rect(1,4), rect(1,1):rect(1,1)+rect(1,3)));
    
    color_homography = computeHomography(color_points_far(:, :), color_points_near(:, :));
    color_obj_far = warped_img_c(color_points_far(1, 1):color_points_far(3, 1), color_points_far(1, 2):color_points_far(3, 2), :);
    figure; imshow(color_obj_far);
    
    tform = projective2d(color_homography');
    color_obj_near = imwarp(color_obj_far, tform);
    figure; imshow(color_obj_near);
    
    out_img = zeros(size(orig_img_c));
    
    out_img(color_points_near(1,2):color_points_near(1,2)+ size(color_points_near, 1), color_points_near(1,1):color_points_near(1,1) + size(color_points_near, 2), :) = color_obj_near(:,:,:);
    figure; imshow(out_img); 
    
function use_kinect_camera()
    contruct3dImageScene(); 
    colorImage = imread('color90.png');
    depthImage = imread('depth90.png');
    depthImage = flipdim(depthImage ,2);

    max_color = double(max(max(depthImage)));
    depth_img = zeros(size(depthImage));
    depth_img = uint8(round(255 * double(depthImage)/max_color));

    figure; imshow(depth_img);

    rect_area = getrect;
    rect_area = round(rect_area);

    xmin = rect_area(1);
    ymin = rect_area(2);
    width = rect_area(3);
    height = rect_area(4);

    img = colorImage(ymin:ymin+height, xmin:xmin+width, :);
    figure; imshow(img);
    
    obj_dist = calculate_object_distance(depthImage, rect_area);
    disp(obj_dist);

function get_object_in_color()
    %contruct3dImageScene();
    colorImage = imread('color40_mapped.png');
    depthImage = imread('depth40.png');
    depthImage = flipdim(depthImage ,2);

    max_color = double(max(max(depthImage)));
    depth_img = zeros(size(depthImage));
    depth_img = uint8(round(255 * double(depthImage)/max_color));

    figure; imshow(depth_img);

    rect_area = getrect;
    rect_area = round(rect_area);

    xmin = rect_area(1);
    ymin = rect_area(2);
    width = rect_area(3);
    height = rect_area(4);

    img = colorImage(ymin:ymin+height, xmin:xmin+width, :);
    figure; imshow(img);
    
    obj_dist = calculate_object_distance(depthImage, rect_area);
    disp(obj_dist);
    
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
    
