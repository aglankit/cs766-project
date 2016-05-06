function [rect, max_corr] = search_template_in_window(warped_img, dest_pts_nx2, search_window, src_img)
    [hog_w, visualization_w] = extractHOGFeatures(search_window, 'CellSize', [8 8]);
    [hog_s, visualization_s] = extractHOGFeatures(src_img, 'CellSize', [8 8]);
    
    % Expand the search window to account for lateral movement of car and
    % errors.
    w_height = dest_pts_nx2(3, 2) - dest_pts_nx2(1, 2);
    w_width = dest_pts_nx2(3, 1) - dest_pts_nx2(1, 1);
    w_ymin = max(1, dest_pts_nx2(1, 2) - w_height/2);
    w_ymax = min(size(warped_img, 1), dest_pts_nx2(3, 2) + w_height/2);
    w_xmin = max(1, dest_pts_nx2(1, 1) - w_width/2);
    w_xmax = min(size(warped_img, 2), dest_pts_nx2(3, 1) + w_width/2);

    % Search
    max_corr = 0.0;
    rect = zeros(1,4);
    i_max = size(search_window, 1) - size(src_img, 1);
    j_max = size(search_window, 2) - size(src_img, 2);
    iter = 0;
    for i = 4:8:i_max-4
        for j = 4:8:j_max-4
            xmin = j;
            ymin = i;
            width = size(src_img, 2);
            height = size(src_img, 1);
            [hog_w, visualization_s] = extractHOGFeatures(search_window(ymin:ymin+height-1, xmin:xmin+width-1), 'CellSize', [8 8]);
            temp_corr = abs(1 - pdist2(hog_w, hog_s, 'cosine'));

            if (temp_corr > max_corr)
                max_corr = temp_corr;
                rect(1, 1) = xmin;
                rect(1, 2) = ymin;
                rect(1, 3) = width;
                rect(1, 4) = height;
            end
            iter = iter + 1;
        end
    end
    