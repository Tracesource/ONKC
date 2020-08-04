function  [K] = renormalize(K)

mn = min(min(K));
mx = max(max(K));
if (mn < 0)
    K = (K - mn) / (mx-mn);
    K = (K+K')/2;
    K = K - mn;
end