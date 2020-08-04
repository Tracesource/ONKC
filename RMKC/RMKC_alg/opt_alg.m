function [K,objall] = opt_alg(Ki,lambda1,lambda2,t)


max_iter=100;
ini = 1;
[n,~,v]=size(Ki);
if t==0
    alpha=ones(1,v);
else
    alpha=(ones(1,v)./v).^(1/t);
end
lambda2=lambda2*alpha(1);
K=zeros(n,n);
%
for i=1:v
    K=K+Ki(:,:,i);
    tmp4i(:,:,i)=Ki(:,:,i)+Ki(:,:,i);
end
K=K./v;
if ini==1
    for i=1:v
        E(:,:,i)=(K-Ki(:,:,i))./2;
    end
elseif ini==2
    for i=1:v
        E(:,:,i)=zeros(n,n);  
    end
else
    for i=1:v
        E(:,:,i)=randn(n,n);   
    end
end


objall=[];
for iter=1:max_iter
    
    tmpK=K+K;
    %update E
    for i=1:v
        
        tmp4=tmp4i(:,:,i)-tmpK;
        di=0.5./max(sqrt(sum(E(:,:,i).^2,2)),eps);
        DD=di*di';
        
        l1=lambda1;
        tmp5=bsxfun(@times,tmp4,di');
        tmp6=bsxfun(@plus,l1*DD,2*di);
        tmp7=bsxfun(@plus,tmp6,2*di');
        E(:,:,i)=tmp5./max(tmp7,eps);
        
    end
    
    % Update K
    KE=zeros(n,n);
    for i=1:v
        KE=KE+alpha(i)*(Ki(:,:,i)-E(:,:,i)-E(:,:,i)');
    end
    tmp1=(KE)./max(sum(alpha),eps);
    tao1=sqrt(lambda2/max(sum(alpha),eps));
    tmp1=(tmp1+tmp1')/2;
    try
        [eigvec,eigval]=eig(tmp1);
        Sd=diag(eigval);
        Sd=Sd.*(Sd>tao1);
        newK=eigvec*diag(Sd)*eigvec';
    catch
        tmp1=sparse(tmp1);
        [eigvec,eigval]=eigs(tmp1,n);
        Sd=diag(eigval);
        Sd=Sd.*(Sd>tao1);
        newK=eigvec*diag(Sd)*eigvec';
    end
    
    if max(max(abs(newK-K)))<1e-5
        break;
    end
    K=newK;
    
    %update alpha
    if t>0
        
        for i=1:v
            L21(i)=sum(sqrt(sum(E(:,:,i).^2,2)));
            err1(i)=sum(sum((K-Ki(:,:,i)+E(:,:,i)+E(:,:,i)').^2));
            err2(i)=L21(i)+err1(i);
        end
        
        s=max(err2,eps).^(1/(t-1));
        alpha=s./(sum(s.^t).^(1/t));
        
    end
    
end

end








