function out_img = blendImagePair(wrapped_imgs, masks, wrapped_imgd, maskd, mode)

if (strcmp(mode, 'overlay'))
mask_comb = ~maskd;
% Superimpose the image
result = im2double(wrapped_imgs) .* cat(3, mask_comb, mask_comb, mask_comb) ...
         + im2double(wrapped_imgd);

elseif (strcmp(mode, 'blend'))
mask_s = ~masks;
mask_d = ~maskd;
weight_s = bwdist(mask_s);
weight_s_3 = cat(3, weight_s, weight_s, weight_s);
weight_d = bwdist(mask_d);
weight_d_3 = cat(3, weight_d, weight_d, weight_d);
result = ((weight_s_3 .* im2double(wrapped_imgs)) + (weight_d_3 .* im2double(wrapped_imgd))) ./ (weight_s_3 + weight_d_3);

else
result = wrapped_imgs;
end

out_img = result;
