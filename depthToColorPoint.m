function [X, Y, depth] = depthToColorPoint()
colorDevice = imaq.VideoDevice('kinect',1);
depthDevice = imaq.VideoDevice('kinect',2);

% Initialize the camera.
step(colorDevice);
step(depthDevice);
% Initialize the camera.
colorData = step(colorDevice) ;
depthData = step(depthDevice);
% release(colorDevice);
% release(depthDevice);
imwrite(depthData, 'depth-ac.png');
imwrite(colorData, 'color-ac.png');
%image(depthData);
%image(colorData);
% save 'depth.mat' depthData;
% save 'color.mat' colorData;
%disp(depthData);
% clc;
orig_depth = imread('depth-ac.png');
%d = imread('depth-ac.png');
% % imshow(orig_depth);
[d,R] = Kinect_DepthNormalization(orig_depth);
% figure; 
% imagesc(orig_depth); 
% figure; 
% imagesc(d); 
% figure; 
% imshowpair(orig_depth,d,'montage');
% disp(size(d));
% display the image:
figure(88);
clf;
h = imagesc(d);
axis image

% Get a value from the screen:
[X, Y] = ginput(4);
% X = [296;313;297;317];
% Y = [271; 276; 292; 285];
X=round(X);
Y=round(Y);
dataval=round([X,Y]);
%disp(dataval);
depth = zeros(size(X));
count = 1;
for i=1:4
    disp(X(i));
    disp(Y(i));
    depth(count) = d(X(i), Y(i));
    count = count + 1;
end
%msgbox(['You want pixel: ' num2str(round([x,y]))]);
end

