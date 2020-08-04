clear
clc
warning off;

path = 'D:\Work\lab_xwl\code\';
addpath(genpath(path));
dataName = 'flower17'; %%% flower17; flower102; CCV; caltech101_mit_numOfClass_10
%% caltech101_numOfClass_10_Kmatrix
%% washington texas cornell; wisconsin, UCI_DIGIT
load([path,'dataset\',dataName,'_Kmatrix'],'KH','Y');
% load([path,'datasets\',dataName,'_Kmatrix'],'KH','Y');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numclass = length(unique(Y));
numker = size(KH,3);
num = size(KH,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KH = kcenter(KH);
KH = knorm(KH);
M = calculateM(KH);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qnorm = 2;
%%%%%%%%---Average---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gamma0 = ones(numker,1)/numker;
% avgKer  = mycombFun(KH,gamma0);
% [H_normalized1] = mykernelkmeans(avgKer,numclass);
% res(:,1) = myNMIACC(H_normalized1,Y,numclass);

% % %%%%%%%%%%---Single Best%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% accpval2 = zeros(numker,1);
% nmipval2 = zeros(numker,1);
% purpval2 = zeros(numker,1);
% for p =1:numker
%     [H_normalized2] = mykernelkmeans(KH(:,:,p),numclass);
%     res2 = myNMIACC(H_normalized2,Y,numclass);
%     accpval2(p) = res2(1);
%     nmipval2(p) = res2(2);
%     purpval2(p) = res2(3);
% end
% res(:,2) = [max(accpval2);max(nmipval2);max(purpval2)];
% 
% %%%%%%%%%%%---MKKM----%%%%%%%%%%%%%%%%%%%%%%%%%
% [H_normalized3,gamma3,obj3] = mkkmeans_train(KH,numclass,qnorm);
% res(:,3) = myNMIACC(H_normalized3,Y,numclass);
% 
% % %%%%%%%%%%%%%--Spectral Clustering Co-training---%%%%%%%%%%%%%%%%%%%%%%%
% accval4 = zeros(numker,1);
% nmival4 = zeros(numker,1);
% purval4 = zeros(numker,1);
% [H_normalized4] = spectral_cotraining(KH,numclass);
% for p =1:numker
%     res4 = myNMIACC(H_normalized4(:,:,p),Y,numclass);
%     accval4(p) = res4(1);
%     nmival4(p) = res4(2);
%     purval4(p) = res4(3);
% end
% res(:,4) = [max(accval4);max(nmival4);max(purval4)];
% 
% %%%%%%%%%%%%%--RMSC---%%%%%%%%%%%%%%%%%%%%%%%
% lambdaset5 = 2.^[-8:2:0];
% accval5 = zeros(length(lambdaset5),1);
% nmival5 = zeros(length(lambdaset5),1);
% purval5 = zeros(length(lambdaset5),1);
% for il =1:length(lambdaset5)
%     [P_hat5] = RMSC(KH, lambdaset5(il));
%     [U5] = baseline_spectral_onkernel(P_hat5,numclass);
%     res5 = myNMIACC(U5,Y,numclass);
%     accval5(il) = res5(1);
%     nmival5(il) = res5(2);
%     purval5(il) = res5(3);
% end
% res(:,5) = [max(accval5);max(nmival5);max(purval5)];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lambdaset61 = [10^-3,10^3];
% lambdaset62 = [10^-2,10^2];
% tset63 = [0.3:0.2:0.7];
% acc_val6 = zeros(2,2,3);
% nmi_val6 = zeros(2,2,3);
% pur_val6 = zeros(2,2,3);
% for il1 = 1:2
%     for il2 = 1:2
%         for it =1:3
%             [Kstar_6] = opt_alg(KH,lambdaset61(il1),lambdaset62(il2),tset63(it));
%             [U61] = mykernelkmeans(Kstar_6, numclass);
%             res6 = myNMIACC(U61,Y,numclass);
%             acc_val6(il1,il2,it) = res6(1);
%             nmi_val6(il1,il2,it) = res6(2);
%             pur_val6(il1,il2,it) = res6(3);
%         end
%     end
% end
% [out61,indx61] = mytst3D(acc_val6);  
% [out62,indx62] = mytst3D(nmi_val6);
% [out63,indx63] = mytst3D(pur_val6); 
% res(:,6) = [acc_val6(out61(1,1),out61(1,2),indx61(1)); nmi_val6(out62(1,1),out62(1,2),indx62(1));...
%     pur_val6(out63(1,1),out63(1,2),indx63(1))];
% 
% % % %%%%%%%%%%%%---LMKKM---%%%%%%%%%%%%%%%%%%%%%%%
% % [H_normalized7,obj7]= lmkkmeans_train(KH, numclass);
% % res(:,7) = myNMIACC(H_normalized7,Y,numclass);
% 
% %%%%%%%%%%%%%---RMKKM---%%%%%%%%%%%%%%%%%%%%%%%
% gammaset7 = [0.1:0.2:0.5];
% maxIter = 30;
% accval7 = zeros(length(gammaset7),1);
% nmival7 = zeros(length(gammaset7),1);
% purval7 = zeros(length(gammaset7),1);
% for il =1:length(gammaset7)
%     tmp1 = zeros(maxIter,1);
%     tmp2 = zeros(maxIter,1);
%     tmp3 = zeros(maxIter,1);
%     for it =1:maxIter;
%         [indx7] = RMKKM(KH, numclass, 'gamma', gammaset7(il), 'maxiter',100);
%         indx7 = indx7(:);
%         [newIndx7] = bestMap(Y,indx7);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         tmp1(it) = mean(Y==newIndx7);
%         tmp2(it) = MutualInfo(Y,newIndx7);
%         tmp3(it) = purFuc(Y,newIndx7);
%     end
%     accval7(il) = max(tmp1);
%     nmival7(il) = max(tmp2);
%     purval7(il) = max(tmp3);
% end
% res(:,8) = [max(accval7); max(nmival7); max(purval7)];
% 
% % %%%%%%%%%---AAAI16----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lambdaset8 = 2.^[-5:2:5];
% accval8 = zeros(length(lambdaset8),1);
% nmival8 = zeros(length(lambdaset8),1);
% purval8 = zeros(length(lambdaset8),1);
% for il =1:length(lambdaset8)
%     [H_normalized8,gamma8,obj8] = myregmultikernelclustering(KH,M,numclass,lambdaset8(il));
%     res8 = myNMIACC(H_normalized8,Y,numclass);
%     accval8(il) = res8(1);
%     nmival8(il) = res8(2);
%     purval8(il) = res8(3);
% end
% res(:,9) = [max(accval8); max(nmival8); max(purval8)];

% %%%%%%%%%%%%%%%%%%----IJCAI16----%%%%%%%%%%%%%%%%%%
% lambdaset9 = 2.^[-5:2:9];
% tauset9 = [0.1:0.1:0.8];
% accval9 = zeros(length(tauset9),length(lambdaset9));
% nmival9 = zeros(length(tauset9),length(lambdaset9));
% purval9 = zeros(length(tauset9),length(lambdaset9));
% for it =1:length(tauset9)
%     numSel = round(tauset9(it)*num);
%     A9 = genarateNeighborhood(avgKer,numSel);
%     HE9 = calHessian(KH,A9);
%     for il =1:length(lambdaset9)
%         [H_normalized9,gamma9,obj9] = mylocalizedregmultikernelclustering(KH,HE9,A9,numclass,lambdaset9(il));
%         res9 = myNMIACC(H_normalized9,Y,numclass);
%         accval9(it,il) = res9(1);
%         nmival9(it,il) = res9(2);
%         purval9(it,il) = res9(3);
%     end
% end
% res(:,10) = [max(max(accval9)); max(max(nmival9)); max(max(purval9))];

%%%%%%%%%%%%%----proposed----------%%%%%%%%%%%%%%%%%%%%%%%
rhoset10 = 2.^[7:2:15];
lambdaset10 = 2.^[3:1:5];
accval10 = zeros(length(rhoset10),length(lambdaset10));
nmival10 = zeros(length(rhoset10),length(lambdaset10));
purval10 = zeros(length(rhoset10),length(lambdaset10));
for ir =1:length(rhoset10)
    for il = 1:length(lambdaset10)
        [H_normalized10,gamma10,G10,obj10] = myoptimalNeighborhoodkernelclustering(KH,M,numclass,rhoset10(ir),lambdaset10(il));
        res10 = myNMIACC(H_normalized10,Y,numclass);
        accval10(ir,il) = res10(1);
        nmival10(ir,il) = res10(2);
        purval10(ir,il) = res10(3);
    end
end
res(:,11) = [max(max(accval10)); max(max(nmival10)); max(max(purval10))];

save([path,'work2017\myResAAAI2017\',dataName,'_clustering.mat'],'res');