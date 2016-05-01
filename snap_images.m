function result = snap_images(suffix)

    colorDevice = imaq.VideoDevice('kinect',1);
    depthDevice = imaq.VideoDevice('kinect',2);

    % Initialize the camera.
    step(colorDevice);
    step(depthDevice);

    % Load one frame from the device.
    colorImage = step(colorDevice);
    depthImage = step(depthDevice);

    imwrite(depthImage, ['calib/depth_' num2str(suffix) '.png']);
    imwrite(colorImage, ['calib/color_' num2str(suffix) '.png']);

    release(colorDevice);
    release(depthDevice);
    result = 0;