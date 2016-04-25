function contruct3dImageScene()
colorDevice = imaq.VideoDevice('kinect',1);
depthDevice = imaq.VideoDevice('kinect',2);

% Initialize the camera.
step(colorDevice);
step(depthDevice);

% Load one frame from the device.
colorImage = step(colorDevice);
depthImage = step(depthDevice);

% Extract the point cloud.
ptCloud = pcfromkinect(depthDevice,depthImage,colorImage,'depthCentric');

% Initialize a point cloud player to visualize 3-D point cloud data. The axis is set appropriately to visualize the point cloud from Kinect.
player = pcplayer(ptCloud.XLimits,ptCloud.YLimits,ptCloud.ZLimits,...
	'VerticalAxis','y','VerticalAxisDir','down');

xlabel(player.Axes,'X (m)');
ylabel(player.Axes,'Y (m)');
zlabel(player.Axes,'Z (m)');

%Acquire and view 500 frames of live Kinect point cloud data.

%for i = 1:500    
colorImage = step(colorDevice);  
depthImage = step(depthDevice);

% depth_img = uint8(round((255 * double(depthImage)/max(max(depthImage)))));
% figure; imshow(depth_img);
% n = 4;
% [xt, yt] = ginput(n);
% disp([xt, yt]);
imwrite(depthImage, 'depth2_mat.png');

ptCloud = pcfromkinect(depthDevice,depthImage,colorImage,'depthCentric');
imwrite(ptCloud.Color, 'color2_mat.png');

view(player,ptCloud);
%end
ptCloud = pcfromkinect(depthDevice, depthImage);
disp(ptCloud);

release(colorDevice);
release(depthDevice);