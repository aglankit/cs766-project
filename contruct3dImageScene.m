function [res] = contruct3dImageScene()
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

imwrite(depthImage, 'depth90.png');
imwrite(colorImage, 'color90.png');

ptCloud = pcfromkinect(depthDevice,depthImage,colorImage,'depthCentric');
imwrite(ptCloud.Color, 'color90_mapped.png');

view(player,ptCloud);
%end
%ptCloud = pcfromkinect(depthDevice, depthImage);

release(colorDevice);
release(depthDevice);
res = 0;