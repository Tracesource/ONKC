function [gamma,fval,exitflag] = updataGamma(M,K,G,rho,lambda)

numker = size(K,3);
f =zeros(numker,1);
for p =1:numker
    f(p) = -rho*trace(K(:,:,p)*G);
end
H = (rho+lambda)*(M+M')/2;
A = [];
b = [];
Aeq = ones(1,numker);
beq = 1;
l = zeros(numker,1);
u = ones(numker,1);
[gamma,fval,exitflag] = quadprog(H,f,A,b,Aeq,beq,l,u);
gamma(gamma<1e-8)=0;
gamma = gamma/sum(gamma);