function [H_normalized] = spectral_cotraining(K,numClust)
% co-trained spectral clustering algorithm (ICML, 2011)

% INPUTS:
% DATA: cell array of length 'num_views' of data matrices of size N x dim
% numClust: desired number of clusters
% SIGMA: array of width parameters for Gaussian kernel in each view
% TRUTH: ground truth clustering
% PROJEV: determines number of top eigenvectors of Laplacian onto which the projection
% is done in the algorithm (the paper considers projev=1 but it was later observed
% that considering more eigenvectors in the projection step helps),
% although the final k-mean clustering is run only on top-'numClust'
% eigenvectors of the graph Laplacian.
% NUMITER: number of iterations

% OUTPUTS:
% nmi_max: maximum nmi value obtained

num_views = size(K,3);
N = size(K,1);
V = zeros(N,numClust,num_views);
for i=1:num_views
    [V(:,:,i)] = baseline_spectral_onkernel(K(:,:,i),numClust);
end
X = V;
Y = K;
Y_norm = Y;
for iter = 1:20
    %fprintf ('iteration %d...\n', i);
    Sall = zeros(N);
    for j=1:num_views
        Sall = Sall + X(:,:,j)*X(:,:,j)';
    end
    for j=1:num_views
        Y(:,:,j) = K(:,:,j)*(Sall - X(:,:,j)*X(:,:,j)');
        Y(:,:,j) = (Y(:,:,j) + Y(:,:,j)')/2; % + 1*eye(N);
        Y_norm(:,:,j) = Y(:,:,j);
        [X(:,:,j)] = baseline_spectral_onkernel(Y_norm(:,:,j),numClust);
    end
end
H_normalized = zeros(N,numClust,num_views);
for j=1:num_views
    H_normalized(:,:,j) = X(:,:,j)./ repmat(sqrt(sum(X(:,:,j).^2, 2)), 1,numClust);
end