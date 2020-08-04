function [result_km,result_sc] = run_ours(Ks, y, nRepeats, paramCell)
nP = length(paramCell);
nK = length(Ks);
nData = max(size(y));
K = zeros(nData, nData, nK);
for iKernel = 1:nK
    K(:, :, iKernel) = Ks{iKernel};
end
clear Ks;
nClusters = length(unique(y));
if ~exist('nRepeats', 'var')
	nRepeats = 1;
end
result_km = [];
result_km.acc_obj_v = zeros(nP, 1);
result_km.purity_obj_v = zeros(nP, 1);
result_km.nmi_obj_v = zeros(nP, 1);
result_km.acc_avg_v = zeros(nP, 1);
result_km.purity_avg_v = zeros(nP, 1);
result_km.nmi_avg_v = zeros(nP, 1);
result_km.acc_std_v = zeros(nP, 1);
result_km.purity_std_v = zeros(nP, 1);
result_km.nmi_std_v = zeros(nP, 1);
result_km.detail = struct('acc_v_km', zeros(nP, nRepeats), 'purity_v_km', zeros(nP, nRepeats), 'nmi_v_km', zeros(nP, nRepeats),...
	'label_v_km', zeros(nP, max(size(y)), nRepeats), 'obj_v_km', zeros(nP, nRepeats));

acc_v_km = zeros(nP, nRepeats);
purity_v_km = zeros(nP, nRepeats);
nmi_v_km = zeros(nP, nRepeats);
obj_v_km = zeros(nP, nRepeats);
label_v_km = zeros(nP,nData, nRepeats);


result_sc = [];
result_sc.acc_avg_v = zeros(nP, 1);
result_sc.purity_avg_v = zeros(nP, 1);
result_sc.nmi_avg_v = zeros(nP, 1);
result_sc.acc_std_v = zeros(nP, 1);
result_sc.purity_std_v = zeros(nP, 1);
result_sc.nmi_std_v = zeros(nP, 1);


acc_v_sc = zeros(nP, nRepeats);
purity_v_sc = zeros(nP, nRepeats);
nmi_v_sc = zeros(nP, nRepeats);
obj_v_sc = zeros(nP, nRepeats);
label_v_sc = zeros(nP,nData, nRepeats);
for p = 1 : nP
    str = sprintf( 'Trying paramter set %d out of %d', p, nP );
    disp( str );
    
    param = paramCell{p};
    

    
    rng('default');
   % KK=ADMM( K, param.lambda1, param.lambda2,param.opts,param.ini,param.t);
    KK=opt_alg(K,param.lambda1,param.lambda2,param.opts,param.ini,param.t);
    [acc,nmi,pur]=baseline_spectral_onkernel(KK,nClusters,y);
    acc_v_sc(p,:) = acc;
    purity_v_sc(p,:) = pur;
    nmi_v_sc(p,:) = nmi;
     
	 %run multiple kernel kmeans on our results
     for iRepeat = 1:nRepeats
       
         [label, ~, ~, ~, objHistory] = RMKKM(KK, nClusters, 'lossType', 'l2', 'replicates', 1);
         res = ClusteringMeasure(y, label);
         acc_v_km(p,iRepeat) = res(1);
         purity_v_km(p,iRepeat) = res(2);
         nmi_v_km(p,iRepeat) = res(3);
         obj_v_km(p,iRepeat) = objHistory(end);
         label_v_km(p,:, iRepeat) = label;

     end
    

end
for p = 1 : nP
     result_km.detail.acc_v(p,:) = acc_v_km(p,:);
     result_km.detail.purity_v(p,:) = purity_v_km(p,:);
     result_km.detail.nmi_v(p,:) = nmi_v_km(p,:);
     result_km.detail.obj_v(p,:) = obj_v_km(p,:);
     result_km.detail.label_v(p,:,:) = label_v_km(p,:,:);
%     
     [~, oidx] = min(obj_v_km,[],2);
     result_km.acc_obj_v( p ) = acc_v_km(p,oidx(p));
     result_km.nmi_obj_v( p ) = nmi_v_km(p,oidx(p));
     result_km.purity_obj_v( p) = purity_v_km(p,oidx(p));
     result_km.acc_avg_v( p ) = mean(acc_v_km(p,:));
     result_km.nmi_avg_v( p ) = mean(nmi_v_km(p,:));
     result_km.purity_avg_v( p) = mean(purity_v_km(p,:));
     result_km.acc_std_v( p ) = std(acc_v_km(p,:));
     result_km.nmi_std_v( p ) = std(nmi_v_km(p,:));
     result_km.purity_std_v( p) = std(purity_v_km(p,:));

    result_sc.detail.acc_v(p,:) = acc_v_sc(p,:);
    result_sc.detail.purity_v(p,:) = purity_v_sc(p,:);
    result_sc.detail.nmi_v(p,:) = nmi_v_sc(p,:);

    result_sc.acc_avg_v( p ) = mean(acc_v_sc(p,:));
    result_sc.nmi_avg_v( p ) = mean(nmi_v_sc(p,:));
    result_sc.purity_avg_v( p) = mean(purity_v_sc(p,:));
    result_sc.acc_std_v( p ) = std(acc_v_sc(p,:));
    result_sc.nmi_std_v( p ) = std(nmi_v_sc(p,:));
    result_sc.purity_std_v( p) = std(purity_v_sc(p,:));
    

end
    
end
