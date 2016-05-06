function generate_homography_matrix()
    % Choose n corresponding points (use ginput)
    % 1->105; 18->20
    % size of box: 10.5x7
    % All dim in inches
    
    % Generate the saved homography matrix. The user is required to pick
    % the object in the displayed images and the function will build all
    % the homography combinations.
    
    images = 18;
    n = 4;
    point_mat = zeros(n, 2, images);

    figure;
    for i = 1:images
        img = imread(strcat('img_dir/', int2str(i), '-d.png'));
        imshow(img);
        rect_area = getrect;
        xmin = rect_area(1);
        ymin = rect_area(2);
        width = rect_area(3);
        height = rect_area(4);
        point_mat(:, :, i) =[[xmin, ymin]; [xmin + width, ymin]; [xmin + width, ymin + height]; [xmin, ymin + height]];
    end

    homography_mat = zeros(3, 3, images, images);

    for i = 1:images
        for j = 1:images
            homography_mat(:, :, i, j) = computeHomography(point_mat(:, :, i), point_mat(:, :, j));
        end
    end

    save('points_2.mat', 'point_mat');
    save('homography_2.mat', 'homography_mat');
