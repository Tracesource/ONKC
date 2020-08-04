function [H_normalized,gamma,G,obj] = myoptimalNeighborhoodkernelclustering(K,M,cluster_count,rho,lambda)

nbkernel = size(K,3);
gamma0 = ones(nbkernel,1)/nbkernel;
KC  = mycombFun(K,gamma0);
H = mykernelkmeans(KC,cluster_count);
%% updata G
[G] = updateG(KC,rho,H);
flag = 1;
iter = 0;
while flag
    iter = iter + 1;
    %% update H with G
    H = mykernelkmeans(G,cluster_count);
    %% update kernel weights
    [gamma] = updataGamma(M,K,G,rho,lambda);
    %%%%%%%%%% update G
    K_gamma = mycombFun(K,gamma);
    [G] = updateG(K_gamma,rho,H);
    obj(iter) = calmyObj(H,K,gamma,G,M,rho,lambda);
    %% KC  = mycombFun(KA,gamma.^qnorm);
    if iter>2 && (abs((obj(iter-1)-obj(iter))/(obj(iter-1)))<1e-3 || iter>50)
        flag =0;
    end
end
H_normalized = H./ repmat(sqrt(sum(H.^2, 2)), 1,cluster_count);
