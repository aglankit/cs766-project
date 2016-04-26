function result_img = showCorrespondence(orig_img, warped_img, src_pts_nx2, dest_pts_nx2)

%% variables
n = size(src_pts_nx2, 1);
orig_img_height = size(orig_img, 1);
orig_img_width = size(orig_img, 2);
warped_img_height = size(warped_img, 1);
warped_img_width = size(warped_img, 2);

%% create the concatenated image
whole_img = zeros(max(orig_img_height, warped_img_height), orig_img_width+warped_img_width);
whole_img(1:orig_img_height, 1:orig_img_width) = orig_img;
whole_img(1:warped_img_height, orig_img_width+1: orig_img_width+warped_img_width) = warped_img;

fh = figure; imshow(whole_img); hold on;

%% draw lines connecting corresponding points
adj_dest_pts_nx2 = dest_pts_nx2;
adj_dest_pts_nx2(:,1) = adj_dest_pts_nx2(:,1) + orig_img_width;

X = zeros(2,n);
Y = zeros(2,n);

X(1,:) = src_pts_nx2(:,1)';
X(2,:) = adj_dest_pts_nx2(:,1)';
Y(1,:) = src_pts_nx2(:,2)';
Y(2,:) = adj_dest_pts_nx2(:,2)';

line(X, Y);

result_img = saveAnnotatedImg(fh);

end

function annotated_img = saveAnnotatedImg(fh)
figure(fh); % Shift the focus back to the figure fh

% The figure needs to be undocked
set(fh, 'WindowStyle', 'normal');

% The following two lines just to make the figure true size to the
% displayed image. The reason will become clear later.
img = getimage(fh);
truesize(fh, [size(img, 1), size(img, 2)]);

% getframe does a screen capture of the figure window, as a result, the
% displayed figure has to be in true size. 
frame = getframe(fh);
pause(0.5); 
% Because getframe tries to perform a screen capture. it somehow 
% has some platform depend issues. we should calling
% getframe twice in a row and adding a pause afterwards make getframe work
% as expected. This is just a walkaround. 
annotated_img = frame.cdata;
end