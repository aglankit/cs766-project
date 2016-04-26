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
               @detect_object, @get_homography, @use_kinect_camera};

% Call test harness
runTests(varargin, fun_handles);

function read_and_use_homography_matrix()
    mat_struct = load('homography_2.mat');
    homography = mat_struct.homography_mat;

    % temporarily using fixed image
    orig_img = imread(strcat('temp40.png'));
    warped_img = imread(strcat('temp90.png'));

    % Select Object (Manual for now)
    figure; imshow(orig_img);
    
    %rect_area = getrect;
    rect_area = [51  152  118  150];
    xmin      = rect_area(1);
    ymin      = rect_area(2);
    width     = rect_area(3);
    height    = rect_area(4);

    test_pts_nx2 = [[xmin, ymin]; [xmin + width, ymin]; [xmin + width, ymin + height]; [xmin, ymin + height]];
    object_img = orig_img(ymin:ymin+height, xmin:xmin+width);
    obj_dist = calculate_object_distance(orig_img, rect_area);
        
    figure; imshow(object_img);
    
    % Apply homography (Fixed for now, need to calculate on demand)
    dest_pts_nx2 = applyHomography(homography(:, :, 14, 11), test_pts_nx2);

    % Search the object in a distant image
    [search_window, src_img] = get_template_search_image(orig_img, test_pts_nx2, warped_img, dest_pts_nx2);

    max_corr = 0;
    for i = 0.9:-0.1:0.1
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
    figure; imshow(drawBox(warped_img, rect, 255, 3));
    
function use_kinect_camera()
    contruct3dImageScene(); 
    colorImage = imread('color2_mat.png');
    depthImage = imread('depth2_mat.png');
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
    colorImage = imread('color2_mat.png');
    depthImage = imread('depth2_mat.png');
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
    %obj_dist = mode(object_img(:));
    obj_dist = mode(vals);