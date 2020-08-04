function [P] = RMSC(T, lambda)
%% OBJECTIVE
 %min ||P||_* + lambda*\sum ||E_i||_1,1
 % s.t P_i=P+E_i, Pe=e, P>=0 where e is the constant one vector.
 %
 % equal to ==>
 %
 % min ||Q||_* + lambda*\sum ||E_i||_1,1
 % s.t P_i=P+E_i, Pe=e, P>=0, P=Q
 
 %% RELATED PAPERS
 % [1] Robust Multi-View Clustering via Low-rank and Sparse Decomposition. 
 %     Rongkai Xia, Yan Pan, Lei Du, and Jian Yin. In Proceedings of AAAI 
 %     Conference on Artificial Intelligence (AAAI), 2014

[m,p,n]=size(T);%num of samples
Z=zeros(m,p);
E=randn(m,p,n);
Y=zeros(m,p,n);
Q=zeros(m,p);
P=zeros(m,p);

mu=1e-4;
rho=1.6;
max_iter=100;
stopeps = 1e-5;

step=0;
while(1)
    %tic;
    step=step+1;
    max_inf_norm=-1;
    for i=1:n
        Ti=T(:,:,i);
        Ei=E(:,:,i);
        diff=Ti-Ei-P;
        inf_norm=norm(diff,'inf');
        max_inf_norm=max(max_inf_norm,inf_norm);
    end
    if step>1 && max_inf_norm<stopeps  
        break;
    end
    if step > max_iter
         fprintf('reach max iterations %d \n',step);
         break;
    end
    
    %update P
    B=1/(n+1)*(Q-Z/mu+sum(T-E-Y/mu,3));
    P=nonnegASC(B);
    for i=1:m
        if sum(P(i,:))-1.0>=1e-10
            error('sum to 1 error');
        end
    end
    %update Q
    M=P+Z/mu;
    C=1/mu;
    [U, Sigma, V] = svd(M,'econ');
    Sigma = diag(Sigma);
    svp=length(find(Sigma>C));
    if svp>=1
        Sigma = Sigma(1:svp)-C;
    else
        svp = 1;
        Sigma = 0;
    end
    Q= U(:, 1:svp) *diag(Sigma)*V(:, 1:svp)';
    
    %update Ei
    for i=1:n
        C=T(:,:,i)-P-Y(:,:,i)/mu;
        E(:,:,i)=max(C-lambda/mu,0)+min(C+lambda/mu,0);
        Y(:,:,i)=Y(:,:,i)+mu*(P+E(:,:,i)-T(:,:,i));
    end
    Z=Z+mu*(P-Q);
    %update mu
    mu=min(rho*mu,1e10);
end
[pi,~]=eigs(P',1);
Dist=pi/sum(pi);
pi=diag(Dist);
if isempty(find(Dist<0))
    P=(pi^0.5*P*pi^-0.5+pi^-0.5*P'*pi^0.5)/2;
else
    P=(pi*P+P'*pi)/2;
end
