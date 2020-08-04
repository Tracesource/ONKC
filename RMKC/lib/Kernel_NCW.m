function [K] = Kernel_NCW(K)
w = sum(K, 2).^-0.5;
K = bsxfun(@times, K, w);
K = bsxfun(@times, K, w');