function DepthImageObjectDetection(varargin)
% runHw4 is the "main" interface that lists a set of 
% functions corresponding to the problems that need to be solved.
%
% Note that this file also serves as the specifications for the functions 
% you are asked to implement. In some cases, your submissions will be autograded. 
% Thus, it is critical that you adhere to all the specified function signatures.
%
% Usage:
% DepthImageObjectDetection                       : list all the registered functions
% DepthImageObjectDetection('function_name')      : execute a specific test
% DepthImageObjectDetection('all')                : execute all the registered functions

% Settings to make sure images are displayed without borders
orig_imsetting = iptgetpref('ImshowBorder');
iptsetpref('ImshowBorder', 'tight');
temp1 = onCleanup(@()iptsetpref('ImshowBorder', orig_imsetting));

% read_and_use_homography_matrix -> Main Program
% generate_homography_matrix -> To build intial homography
% snap_images -> Get depth and color image from kinect
fun_handles = {@read_and_use_homography_matrix, @generate_homography_matrix, ...
               @detect_object, @snap_images};

% Call test harness
runTests(varargin, fun_handles);

function read_and_use_homography_matrix()
    % Read saved homography
    mat_struct = load('homography_2.mat');
    homography = mat_struct.homography_mat;

    % Current image
    orig_img = imfill(imread(strcat('calib_2/depth_62.png')));
    orig_img_c = imfill(imread(strcat('calib_2/color_62.png')));
    
    % Saved depth image from an earlier non-blinding time
    warped_img = imfill(imread(strcat('calib_2/depth_41.png')));
    warped_img_c = imfill(imread(strcat('calib_2/color_41.png')));

    orig_img_u = orig_img;
    warped_img_u = warped_img;
    
    % Normalize the depth image
    orig_img = convert_image_to_uint8(orig_img);
    warped_img = convert_image_to_uint8(warped_img);
    
    figure; imshow(orig_img);
    % Object for recovery (Hard-coded for now)
    rect_area = [235   86   96   88];
    xmin      = rect_area(1);
    ymin      = rect_area(2);
    width     = rect_area(3);
    height    = rect_area(4);

    test_pts_nx2 = [[xmin, ymin]; [xmin + width, ymin]; [xmin + width, ymin + height]; [xmin, ymin + height]];
    object_img = orig_img(ymin:ymin+height, xmin:xmin+width);
    
    % Calculate object distance given by coordinate test_pts_nx2 in the
    % depth image.
    obj_dist = calculate_object_distance(orig_img_u, rect_area);
    
    % Kinect depth-to-color mapping to get coordinates cooresponding 
    % to test_pts_nx2 in color image. Hardcoded for now but generated 
    % using the mapping code in csharpmapping. Communication between 
    % Matlab and C# code is remaining to be done.
    color_points_near = [203, 923; 443, 923; 443, 1221; 203, 1221];
    
    % Apply appropriate homography from the saved homographies on the o
    % object (Fixed for now between 16 & 14, Will be calculate on demand)
    dest_pts_nx2 = applyHomography(homography(:, :, 16, 14), test_pts_nx2);

    % Get the template image and the search window in the distant/saved 
    % depth image.
    [search_window, src_img] = get_template_search_image(orig_img, test_pts_nx2, warped_img, dest_pts_nx2);

    max_corr = 0;
    % Apply various scales on the template(src_img) to look for the object
    for i = 1.0:-0.1:0.7
        disp(i)
        temp_src_img = imresize(src_img, i);
        
        % Search for the template in the search window.
        [temp_rect, temp_corr] = search_template_in_window(warped_img, dest_pts_nx2, search_window, temp_src_img);
        if temp_corr > max_corr
            max_corr = temp_corr;
            rect = temp_rect;
        end
        disp(max_corr);
    end

    % rect is the detected object in the saved far image.
    % color_points_far is the depth-to-color mapping corresponding to 
    % rect in the far/saved depth image. Currently hard-coded by running
    % the c# code and getting the values. Integration with c# code in 
    % csharpmapping/.. is required to be done.
    color_points_far = [356, 940; 550, 940; 550, 1148; 356, 1148];
    
    % Apply final homography to convert the object detected in far/saved
    % image to the estimated shape in the current color image.
    color_homography = computeHomography(color_points_far(:, :), color_points_near(:, :));
    color_obj_far = warped_img_c(color_points_far(1, 1):color_points_far(3, 1), color_points_far(1, 2):color_points_far(3, 2), :);
    tform = projective2d(color_homography');
    color_obj_near = imwarp(color_obj_far, tform);
    
    % Final generated color image
    out_img = zeros(size(orig_img_c));
    out_img(color_points_near(1,1):color_points_near(1,1) + size(color_obj_near, 1) - 1, ...
            color_points_near(1,2):color_points_near(1,2) + size(color_obj_near, 2) - 1, 1) = color_obj_near(:,:,1);
    out_img(color_points_near(1,1):color_points_near(1,1) + size(color_obj_near, 1) - 1, ...
            color_points_near(1,2):color_points_near(1,2) + size(color_obj_near, 2) - 1, 2) = color_obj_near(:,:,2);
    out_img(color_points_near(1,1):color_points_near(1,1) + size(color_obj_near, 1) - 1, ...
            color_points_near(1,2):color_points_near(1,2) + size(color_obj_near, 2) - 1, 3) = color_obj_near(:,:,3);
    out_img = uint8(out_img);
    imwrite(out_img, 'regenerated_img.png'); 
    
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
    
