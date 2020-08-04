function [label, center] = L21KKM_single(K, center, label )
n = size(K,1);
k = size(center, 2);
last = 0;
it=0;
aa = full(diag(K));
maxit = 10;
while any(label ~= last) && it<maxit
    last = label;
    
    bb = sum((K * center) .* center);
    ab = K * center;
    D = bsxfun(@plus, -2*ab, bb);
    
    [val,label] = min(D,[],2); % assign samples to the nearest centers
    val = aa + val;
    ll = unique(label);
    if length(ll) < k
        %disp([num2str(k-length(ll)),' clusters dropped at iter ',num2str(it)]);
        missCluster = 1:k;
        missCluster(ll) = [];
        missNum = length(missCluster);
        
        [~,idx] = sort(val,1,'descend');
        label(idx(1:missNum)) = missCluster;
    end
    
    minDist = max(val, eps);
    idx = minDist < 1e-10;
    sw = .5 ./ sqrt(minDist);
    if sum(~idx) > 0
        sw(idx) = mean(sw(~idx));% without this setting, the weight of data point close to cluster center will be infinity!
    end
    sw = sw/max(sw);
    
    center = full(sparse(1:n,label,sw,n,k,n)); % indicator matrix
    center = bsxfun(@rdivide, center, max(sum(center), 1e-10)); % weighted indicator
    it=it+1;
end