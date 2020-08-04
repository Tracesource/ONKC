function [G] = updateG(K_gamma,rho,H)

num = size(K_gamma,1);
HH = eye(num) - H*H';
B = K_gamma - (1/rho)*HH;
B = (B+B')/2;
[V,D] = eig(B);
diagD = diag(D);
diagD(diagD<eps)=0;
G = V*diag(diagD)*V';
G = (G+G')/2;