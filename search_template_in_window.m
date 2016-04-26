function [rect, max_corr] = search_template_in_window(search_window, src_img)
    [hog_w, visualization_w] = extractHOGFeatures(search_window, 'CellSize', [8 8]);
    [hog_s, visualization_s] = extractHOGFeatures(src_img, 'CellSize', [8 8]);

    max_corr = 0.0;
    rect = zeros(1,4);
    i_max = size(search_window, 1) - size(src_img, 1);
    j_max = size(search_window, 2) - size(src_img, 2);

    for i = 1:4:i_max
        for j = 1:4:j_max
            xmin = j;
            ymin = i;
            width = size(src_img, 2);
            height = size(src_img, 1);
            [hog_w, visualization_s] = extractHOGFeatures(search_window(ymin:ymin+height-1, xmin:xmin+width-1), 'CellSize', [8 8]);
            temp_corr = abs(corr2(hog_w, hog_s));
            if (temp_corr > max_corr)
                max_corr = temp_corr;
                rect(1, 1) = xmin;
                rect(1, 2) = ymin;
                rect(1, 3) = width;
                rect(1, 4) = height;
            end
        end
    end