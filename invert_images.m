function invert_images()
    invert_image('inter_2', 'inter', ['color_far.png']);
    invert_image('inter_2', 'inter', ['img-final.png']);
    invert_image('inter_2', 'inter', ['init_img.png']);
    invert_image('inter_2', 'inter', ['regenerated_img.png']);
    
    for i = [0:71]
        invert_image('inter_2', 'inter', ['img-' int2str(i) '.png']);
    end

    for i = [41:65]
        invert_image('calib_2', 'calib', ['color_' int2str(i) '.png']);
        invert_image('calib_2', 'calib', ['depth_' int2str(i) '.png']);
    end

function invert_image(src_dir, dst_dir, filename)
    img = imread([src_dir '/' filename]);
    img = flipdim(img, 2);
    imwrite(img, [dst_dir '/' filename]);
    