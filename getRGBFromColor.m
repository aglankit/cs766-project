function [res] = getRGBFromColor (color_x, color_y)
% color_x = '1116.72265625;1219.98779296875;1144.70959472656;1243.068359375';
% color_y = '726.319763183594;740.575378417969;786.748718261719;766.429565429688';
x = str2num(color_x);
y = str2num(color_y);

color = imread('color-ac.png');
f = figure, imshow(color);
hold on;
for i=1:4
    plot(round(x(i)),round(y(i)),'Marker','o','Color','r','MarkerSize',20)
end
print(f, '-r80', '-dtiff', 'image2.tiff');
res = 0;
end

