function [Xc, corruptedSmpIdx, prefix_noise] = add_noise(X, options_noise, im_height, im_width)
if ~exist('options_noise', 'var')
    options_noise = [];
end

noise_type = 1;
if isfield(options_noise, 'noise_type');
    noise_type = options_noise.noise_type;
end

nCorruptedImage = 30;
if noise_type > 0 && isfield(options_noise, 'nCorruptedImage')
    nCorruptedImage = options_noise.nCorruptedImage;
end

switch noise_type
    case 0 % without corruption
        Xc = X;
        nCorruptedImage = 0;
        corruptedSmpIdx = [];
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n'];
    case 1 % Random Block Corruption
        % (1) add random block
        % (2) add random dot [0, pix_max]        
        nBlockPerImage = 1;
        blok_height = 8; % 1
        block_width = 8; % 1
        if im_height == 64
            blok_height = 16; % 1
            block_width = 16; % 1
        end
        
        block_type = 3; % [(1)all black (0), (2)all white (255 or 1) , (3)blank-white, (4)unrelated_image]
        % (5) rand +
        if isfield(options_noise, 'block_type');
            block_type = options_noise.block_type;
        end
        unrelated_image = [];
        if block_type == 4;
            monkeyFace = load('mandrill');
            unrelated_image = monkeyFace.X;
        end        
        [Xc, corruptedSmpIdx] = Random_Block_Corruption(X, im_height, im_width, ...
            nCorruptedImage, nBlockPerImage, blok_height, block_width, block_type, unrelated_image);        
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n_', ...
            num2str(blok_height) num2str(blok_height) 'block_size_' num2str(block_type) 'block_type'];
    case 2 % Random Pixel Corruption
        % (1) add random dot [0, pix_max] uniformly        
        r = randperm(nSmp);
        corruptedSmpIdx = r(1:nCorruptedImage);
        nCorruptedPixel = 0.5;
        if isfield(options_noise, 'nCorruptedPixel')
            nCorruptedPixel = options_noise.nCorruptedPixel;
        end             
        Xc = Random_Pixel_Corruption(X, corruptedSmpIdx, nCorruptedPixel);        
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n_', ...
            num2str(nCorruptedPixel) 'Pixel'];
    case 3 % outliers non_normalization        
        data_type = 1;
        if isfield(options_noise, 'data_type')
            data_type = options_noise.data_type;
        end         
        [Xc, corruptedSmpIdx] = outliers_nonnormalized(X, nCorruptedImage, data_type);        
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n'];
    case 4 % outlier drift        
        alpha = 10;
        if isfield(options_noise, 'alpha')
            alpha = options_noise.alpha;
        end        
        [Xc, corruptedSmpIdx] = outliers_drift(X, nCorruptedImage, alpha);
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n_',...
            num2str(alpha) 'alpha'];
    case 5 % sunglass occlusion        
        [Xc, corruptedSmpIdx] = sunglass_occlusion(X, nCorruptedImage, im_height, im_width);
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n'];
    case 6
        [Xc, corruptedSmpIdx] = contiguous_occlusion(X, nCorruptedImage, im_height, im_width);
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n'];
    case 7
        [Xc, corruptedSmpIdx] = contiguous_occlusion_white(X, nCorruptedImage, im_height, im_width);
        prefix_noise = [num2str(noise_type) 'noise_' num2str(nCorruptedImage) 'n'];
end

end


function [X_corrupted, corruptedSmpIdx] = Random_Block_Corruption(X, im_height, im_width, ...
    nCorruptedImage, nBlockPerImage, block_height, block_width, block_type, unrelated_image)
% Random block corruption 
% Input
%         X: nSmp * nDim, raw image in gray
%         im_height, raw image height
%         im_width, raw image width
%         nCorruptedImage: number of corrupted image, or ratio (0-1)
%         nBlockPerImage: number of corrputed block on each corrupted image
%         block_height, 
%         block_width
%         block_type: [(1)all black (0), (2)all white (255 or 1) , (3)blank-white, (4)unrelated_image]
%         unrelated_image: insert monkey face in human face
% Output
%         X_corrupted, nSmp * nDim
%         corruptedSmpIdx, nCorruptedImage * 1
% 
% [1]. Robust Classification using Structured Sparse Representation, CVPR,
% 2011
% [2]. Maximum Correntropy Criterion for Robust Face Recognition, PAMI, 2011
% 

[nSmp, nDim] = size(X);
assert(im_height * im_width == nDim);
assert(nCorruptedImage <= nSmp);

if nCorruptedImage <= 1 % ratio 2 number 
    nCorruptedImage = ceil(nSmp * nCorruptedImage);
end 
corruptedSmpIdx = randperm(nSmp);
corruptedSmpIdx = corruptedSmpIdx(1: nCorruptedImage);

pix_min = min(0, min(min(X)));
pix_max = max(1, max(max(X)));

for iImage = 1:nCorruptedImage
    
    imIdx = corruptedSmpIdx(iImage);
    
    
    for iBlock = 1:nBlockPerImage
        rowIdx = randi(im_height - block_height + 1);
        colIdx = randi(im_width - block_width + 1);
        
        % get random block
        switch block_type
            case 1 % black block
                block = pix_min * ones(block_height, block_width);
            case 2 % white block
                block = pix_max * ones(block_height, block_width);
            case 3 % white-black block
                block = zeros(block_height, block_width);
                r = rand(block_height, block_width);
                block(r < .5) = pix_min;
                block(r >= .5) = pix_max;
            case 4 % un-related image
                if ~isequal(size(unrelated_image), [block_height, block_width])
                    unrelated_image = imresize(unrelated_image, [block_height, block_width]);
                    unrelated_image = pix_max * unrelated_image/max(max(unrelated_image));
                    block = unrelated_image;
                else
                    block = unrelated_image;
                end
            case 5
                block = pix_max * rand(block_height, block_width);
            otherwise
                error('Not implemented');
        end        
        x = reshape(X(imIdx,:), im_height, im_width);
        x(rowIdx:rowIdx + block_height-1, colIdx:colIdx + block_width-1) = block;
        X(imIdx,:) = x(:);
    end
end

X_corrupted = X;

end


function X_corrupted = Random_Pixel_Corruption(X, corruptedSmpIdx, nCorruptedPixel)
% Random_Pixel_Corruption: randomly selected pixels with random pixel value which
% follows a uniform distribution over [0, 255]. The percentage of corruption is from 10% to 80%.
% 
% Input
%         X: nSmp * nDim, raw image in gray
%         corruptedSmpIdx: 1: nSmp (by fault)
%         corruptedSmpIdx: ratio (0-1) or number 
% Output
%         X_corrupted, nSmp * nDim
% 
% 
% [1]. Random Pixel Corruption
% [1]. Two-Stage Sparse Representation for Robust Recognition on
% Large-Scale Database, Ran He, AAAI, 2010
% ************************************************

[nSmp, nDim] = size(X);

pix_min = min(0, min(min(X)));
pix_max = max(1, max(max(X)));

if isempty(corruptedSmpIdx)
    corruptedSmpIdx = 1:nSmp;
end

if nCorruptedPixel <=1
    nCorruptedPixel = ceil(nDim * nCorruptedPixel);
end


for iSmp = 1:length(corruptedSmpIdx);
    smpIdx = corruptedSmpIdx(iSmp);
    rIdx = randperm(nDim);
    corrPixelIdx = rIdx(1:nCorruptedPixel);
    corrVal = randi([pix_min, pix_max], 1,nCorruptedPixel);
    X(smpIdx, corrPixelIdx) = corrVal;
end

X_corrupted = X;

end


function [Xo, outlier_idx] = outliers_nonnormalized(X, outlier_ratio, data_type)
% *********************************************************************
% In computer vision, one assumes that outliers are significantly far away from the rest of the data points [4]. 
% Here, we used nonnormalized samples as outliers, e.g., the outlier’s norm is significantly larger than 1. 
% We ran-domly selected 2% of samples in the training set as outliers and the remaining 98% of samples as inliers. 
% To eliminate statistical deviations, all experimental results were reported over 20 random trials. 
% 
% [1]. Robust Principal Component Analysis Based on Maximum Correntropy
% Criterion, Ran He, TIP, 2011
% 
% *********************************************************************

% X: nSmp * nDim
% 

[nSmp, ~] = size(X);

if ~exist('data_type', 'var')
    data_type = 1; % image
end

if outlier_ratio <= 1
    outlier_ratio = ceil(nSmp * outlier_ratio);
end

switch data_type
    case 1 % image
        r = randperm(nSmp);
        outlier_idx = r(1:outlier_ratio);
        inlier_idx = setdiff(1:nSmp, outlier_idx);
        Xo = zeros(size(X));
        iMax = max(max(X(:,inlier_idx)));
        Xo(:, inlier_idx) = Xo(:, inlier_idx)/iMax;
        Xo(:,outlier_idx) = X(:, outlier_idx);
    case 2 % doc
        
    otherwise
        error('Not implemented');
end
end


function [Xc, outlier_idx] = outliers_drift(X, outlier_ratio, alpha)
% *********************************************************************
% The outliers were generated by x = a * x_org, 
% where x_org is a normalized data and 
% a is used to control the magnitude of outliers.
% case 1
%     fixed the data mean (weights of data are equal)
%     
% 
% [1]. Robust Principal Component Analysis Based on Maximum Correntropy
% Criterion, Ran He, TIP, 2011
% 
% *********************************************************************

[nSmp, ~] = size(X);

if outlier_ratio <= 1
    outlier_ratio = ceil(nSmp * outlier_ratio);
end

if ~exist('alpha', 'var')
    alpha = 1;
end

r = randperm(nSmp);
outlier_idx = r(1:outlier_ratio);
inlier_idx = setdiff(1:nSmp, outlier_idx);

Xc = zeros(size(X));
Xc(inlier_idx, :) = X(inlier_idx,:);
Xc(outlier_idx,:) = alpha * X(outlier_idx,:);

end


function [X_corrupted, corruptedSmpIdx] = sunglass_occlusion(X, nCorruptedImage, im_height, im_width)

[nSmp, nDim] = size(X);
assert(im_height * im_width == nDim);
assert(nCorruptedImage <= nSmp);

if nCorruptedImage <= 1 % ratio 2 number
    nCorruptedImage = ceil(nSmp * nCorruptedImage);
end
corruptedSmpIdx = randperm(nSmp);
corruptedSmpIdx = corruptedSmpIdx(1: nCorruptedImage);

pix_min = min(0, min(min(X)));
% pix_max = max(1, max(max(X)));

sunglass_idx_pix = sunglass_region(im_height, im_width);
for iImage = 1:nCorruptedImage
    
    imIdx = corruptedSmpIdx(iImage);
    X(imIdx, sunglass_idx_pix) = pix_min;
end
X_corrupted = X;

end


function [X_corrupted, corruptedSmpIdx] = contiguous_occlusion(X, nCorruptedImage, im_height, im_width)

[nSmp, nDim] = size(X);
assert(im_height * im_width == nDim);
assert(nCorruptedImage <= nSmp);

if nCorruptedImage <= 1 % ratio 2 number
    nCorruptedImage = ceil(nSmp * nCorruptedImage);
end
corruptedSmpIdx = randperm(nSmp);
corruptedSmpIdx = corruptedSmpIdx(1: nCorruptedImage);

pix_min = min(0, min(min(X)));
% pix_max = max(1, max(max(X)));

sunglass_idx_pix = sunglass_region(im_height, im_width);
mouth_idx_pix = mouth_region(im_height, im_width);
for iImage = 1:nCorruptedImage
    
    imIdx = corruptedSmpIdx(iImage);
    if rand > 0.5
        X(imIdx, sunglass_idx_pix) = pix_min;
    else
        X(imIdx, mouth_idx_pix) = pix_min;
    end
end
X_corrupted = X;

end

function [X_corrupted, corruptedSmpIdx] = contiguous_occlusion_white(X, nCorruptedImage, im_height, im_width)

[nSmp, nDim] = size(X);
assert(im_height * im_width == nDim);
assert(nCorruptedImage <= nSmp);

if nCorruptedImage <= 1 % ratio 2 number
    nCorruptedImage = ceil(nSmp * nCorruptedImage);
end
corruptedSmpIdx = randperm(nSmp);
corruptedSmpIdx = corruptedSmpIdx(1: nCorruptedImage);

% pix_min = min(0, min(min(X)));
pix_max = max(1, max(max(X)));

sunglass_idx_pix = sunglass_region(im_height, im_width);
mouth_idx_pix = mouth_region(im_height, im_width);
for iImage = 1:nCorruptedImage
    
    imIdx = corruptedSmpIdx(iImage);
    if rand > 0.5
        X(imIdx, sunglass_idx_pix) = pix_max;
    else
        X(imIdx, mouth_idx_pix) = pix_max;
    end
end
X_corrupted = X;

end

function idx_pix = sunglass_region(im_height, im_width)


if im_height == 32 && im_width == 32
    r_s = 4;
    r_e = 10;
    c_s = 3;
    c_e = im_width - c_s;
    
elseif im_height == 64 && im_width == 64
    r_s = 4;
    r_e = 20;
    c_s = 5;
    c_e = im_width - c_s;
end
idx_pix = bsxfun(@plus, max(0, (c_s:c_e)' - 1) * im_width, r_s : r_e);

idx_pix = idx_pix(:);

end

function idx_pix = mouth_region(im_height, im_width)


if im_height == 32 && im_width == 32
    r_s = 18;
    r_e = 28;
    c_s = 3;
    c_e = im_width - c_s;
    
elseif im_height == 64 && im_width == 64
    r_s = 40;
    r_e = 55;
    c_s = 5;
    c_e = im_width - c_s;
end
idx_pix = bsxfun(@plus, max(0, (c_s:c_e)' - 1) * im_width, r_s : r_e);

idx_pix = idx_pix(:);

end