function [obj] = calmyObj(H,K,gamma,G,M,rho,lambda)
%% calmyObj(H,K,gamma,G,M,rho,lambda)

num = size(K,1);
term1 = trace(G*(eye(num)- H*H'));
K_gamma =  mycombFun(K,gamma);
term2 =  trace((G-K_gamma)'*(G-K_gamma));
term3 = gamma'*M*gamma;
obj = term1 + (rho/2)*term2 + (lambda/2)*term3;