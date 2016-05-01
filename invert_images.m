function invert_images()
    %for i = [0:71]
    invert_image('inter_2', 'inter', ['color_far.png']);
    invert_image('inter_2', 'inter', ['img-final.png']);
    invert_image('inter_2', 'inter', ['init_img.png']);
    %end


function invert_image(src_dir, dst_dir, filename)
    img = imread([src_dir '/' filename]);
    img = flipdim(img, 2);
    imwrite(img, [dst_dir '/' filename]);
    