function runHw4(varargin)
% runHw4 is the "main" interface that lists a set of 
% functions corresponding to the problems that need to be solved.
%
% Note that this file also serves as the specifications for the functions 
% you are asked to implement. In some cases, your submissions will be autograded. 
% Thus, it is critical that you adhere to all the specified function signatures.
%
% Before your submssion, make sure you can run runHw4('all') 
% without any error.
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
fun_handles = {@generate_homography_matrix, @read_and_use_homography_matrix, @generate_points, @detect_object, @get_homography, @use_kinect_camera, @use_kinect_camera_temp};

% Call test harness
runTests(varargin, fun_handles);


function read_and_use_homography_matrix()
    mat_struct = load('homography_2.mat');
    homography = mat_struct.homography_mat;

    orig_img = imread(strcat('temp40.png'));
    warped_img = imread(strcat('temp90.png'));

    figure; imshow(orig_img);
    rect_area = getrect;
    xmin = rect_area(1);
    ymin = rect_area(2);
    width = rect_area(3);
    height = rect_area(4);

    test_pts_nx2 = [[xmin, ymin]; [xmin + width, ymin]; [xmin + width, ymin + height]; [xmin, ymin + height]];
    
    object_img = orig_img(ymin:ymin+height, xmin:xmin+width);
    object_distance_now = mode(object_img(:));
    
    figure; imshow(object_img);
    disp(object_distance_now);
    
    % Apply homography
    dest_pts_nx2 = applyHomography(homography(:, :, 14, 11), test_pts_nx2);

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

    debug = 0;
    if debug == 1
        plot_image_hog_correspondence();       
        figure; imshow(drawBox(search_window, rect, 255, 3));
    end

function use_kinect_camera()
    contruct3dImageScene();
    depthImage = imread('depth2_mat.png');
    colorImage = imread('color2_mat.png');

    max_color = double(max(max(depthImage)));

    depth_img = zeros(size(depthImage));
    depth_img = uint8(round(255 * double(depthImage)/max_color));
    depth_img = flipdim(depth_img ,2);

    figure; imshow(depth_img);

    rect_area = getrect;
    rect_area = round(rect_area);

    xmin = rect_area(1);
    ymin = rect_area(2);
    width = rect_area(3);
    height = rect_area(4);

    img = colorImage(ymin:ymin+height, xmin:xmin+width, :);

    figure; imshow(img);
    temp_image(:,:,1) = uint8(colorImage(xmin, ymin, 1));
    temp_image(:,:,2) = uint8(colorImage(xmin, ymin, 2));
    temp_image(:,:,3) = uint8(colorImage(xmin, ymin, 3));

    disp(colorImage(xmin, ymin, 1));
    figure; imshow(temp_image);
    
function plot_image_hog_correspondence()
    figure;
    subplot(2,2,1);
    imshow(src_img);
    subplot(2,2,2);
    plot(visualization_s);
    subplot(2,2,3);
    imshow(search_window);
    subplot(2,2,4);
    plot(visualization_w);