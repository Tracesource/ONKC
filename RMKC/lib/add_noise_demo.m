% 
% Random Block and Pixel Corruption demo
% 

load YALE_1024;

X = X(1:10,:); % for demo

% Random Block Corruption
im_height = 32;
im_width = 32;
nCorruptedImage = 10;
nBlockPerImage = 1;
blok_height = 8;
block_width = 8;
block_type = 1;
unrelated_image = [];

[XB, corruptedSmpIdx_block] = Random_Block_Corruption(X, im_height, im_width, ...
    nCorruptedImage, nBlockPerImage, blok_height, block_width, block_type, unrelated_image);

% Random Pixel Corruption
corruptedSmpIdx = (1:10);
nCorruptedPixel = 0.5;
XP = Random_Pixel_Corruption(X, corruptedSmpIdx, nCorruptedPixel);