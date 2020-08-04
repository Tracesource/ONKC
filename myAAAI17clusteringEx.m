clear
clc
warning off;

path = 'D:\myWork\work2015\';
addpath(genpath(path));
dataName = 'flower102_numOfClass_30'; %%% flower17; flower102; CCV; caltech101_mit_numOfClass_10
%% caltech101_numOfClass_10_Kmatrix
%% flower102_numOfClass_30
%% PIE10P; AR10P; YALE; proteinFold
load([path,'datasets\',dataName,'_Kmatrix'],'KH','Y');
% load([path,'datasets\',dataName,'_Kmatrix'],'KH','Y');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numclass = length(unique(Y));
numker = size(KH,3);
num = size(KH,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KH = kcenter(KH);
KH = knorm(KH);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qnorm = 2;
%%%%%%%%---Average---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma0 = ones(numker,1)/numker;
avgKer  = mycombFun(KH,gamma0);
[U1] = mykernelkmeans(avgKer, numclass);
res(:,1) = myNMIACC(U1,Y,numclass);

% %%%%%%%%%%---Single Best----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
accpval2 = zeros(numker,1);
nmipval2 = zeros(numker,1);
purpval2 = zeros(numker,1);
for p =1:numker
    [U2] = mykernelkmeans(KH(:,:,p),numclass);
    res2 = myNMIACC(U2,Y,numclass);
    accpval2(p) = res2(1);
    nmipval2(p) = res2(2);
    purpval2(p) = res2(3);
end
res(:,2) = [max(accpval2);max(nmipval2);max(purpval2)];

%%%%%%%---MKKM---%%%%%%%%%%%%%%%%%%%%%%%%%
H_normalized3 = mkkmeans_train(KH,numclass,qnorm);
res(:,3) = myNMIACC(H_normalized3,Y,numclass);

% %%%%%%%%%%%%%--Spectral Clustering Co-training---%%%%%%%%%%%%%%%%%%%%%%%
[H_normalized5] = spectral_cotraining(KH,numclass);
accval5 = zeros(numker,1);
nmival5 = zeros(numker,1);
purval5 = zeros(numker,1);
for p =1:numker
    res5 = myNMIACC(H_normalized5(:,:,p),Y,numclass);
    accval5(p) = res5(1);
    nmival5(p) = res5(2);
    purval5(p) = res5(3);
end
res(:,4) = [max(accval5);max(nmival5);max(purval5)];

%%%%%%%%%%%%%--RMSC---%%%%%%%%%%%%%%%%%%%%%%%
lambdaset6 = 2.^[-8:2:0];
accval6 = zeros(length(lambdaset6),1);
nmival6 = zeros(length(lambdaset6),1);
purval6 = zeros(length(lambdaset6),1);
for il =1:length(lambdaset6)
    [P_hat6] = RMSC(KH, lambdaset6(il));
    [U6] = baseline_spectral_onkernel(P_hat6,numclass);
    U_normalized6 = U6./ repmat(sqrt(sum(U6.^2, 2)), 1,numclass);
    res6 = myNMIACC(U_normalized6,Y,numclass);
    accval6(il) = res6(1);
    nmival6(il) = res6(2);
    purval6(il) = res6(3);
end
res(:,5) = [max(accval6);max(nmival6);max(purval6)];
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambdaset71 = [10^-3,10^3];
lambdaset72 = [10^-2,10^2];
tset73 = [0.3:0.2:0.7];
acc_val7 = zeros(2,2,3);
nmi_val7 = zeros(2,2,3);
pur_val7 = zeros(2,2,3);
for il1 = 1:2
    for il2 = 1:2
        for it =1:3
            [Kstar_7] = opt_alg(KH,lambdaset71(il1),lambdaset72(il2),tset73(it));
            [U71] = mykernelkmeans(Kstar_7, numclass);
            res7 = myNMIACC(U71,Y,numclass);
            acc_val7(il1,il2,it) = res7(1);
            nmi_val7(il1,il2,it) = res7(2);
            pur_val7(il1,il2,it) = res7(3);
        end
    end
end
[out71,indx71] = mytst3D(acc_val7);  
[out72,indx72] = mytst3D(nmi_val7);
[out73,indx73] = mytst3D(pur_val7); 
res(:,6) = [acc_val7(out71(1,1),out71(1,2),indx71(1)); nmi_val7(out72(1,1),out72(1,2),indx72(1));...
    pur_val7(out73(1,1),out73(1,2),indx73(1))];

%%%%%%%%%%%%---LMKKM---%%%%%%%%%%%%%%%%%%%%%%%
[H_normalized8,obj8]= lmkkmeans_train(KH, numclass);
res(:,7) = myNMIACC(H_normalized8,Y,numclass);

%%%%%%%%%%%%%---RMKKM---%%%%%%%%%%%%%%%%%%%%%%%
gammaset9 = [0.3];
maxIter = 30;
accval9 = zeros(length(gammaset9),1);
nmival9 = zeros(length(gammaset9),1);
purval9 = zeros(length(gammaset9),1);
for il =1:length(gammaset9)
    tmp1 = zeros(maxIter,1);
    tmp2 = zeros(maxIter,1);
    tmp3 = zeros(maxIter,1);
    for it =1:maxIter;
        [indx9] = RMKKM(KH, numclass, 'gamma', gammaset9(il), 'maxiter',100);
        indx9 = indx9(:);
        [newIndx9] = bestMap(Y,indx9);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tmp1(it) = mean(Y==newIndx9);
        tmp2(it) = MutualInfo(Y,newIndx9);
        tmp3(it) = purFuc(Y,newIndx9);
    end
    accval9(il) = max(tmp1);
    nmival9(il) = max(tmp2);
    purval9(il) = max(tmp3);
end
res(:,8) = [max(accval9);max(nmival9);max(purval9)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambdaset4 = 2.^[-7:2:9];
tauset = [0.1:0.1:0.8];
accval41 = zeros(length(tauset),length(lambdaset4));
nmival41 = zeros(length(tauset),length(lambdaset4));
purval41 = zeros(length(tauset),length(lambdaset4));
for it =1:length(tauset)
    numSel = round(tauset(it)*num);
    A4 = genarateNeighborhood(avgKer,numSel);
    HE4 = calHessian(KH,A4);
    for il =1:length(lambdaset4)
        [H_normalized4,gamma41,obj41] = mylocalizedregmultikernelclustering(KH,HE4,A4,numclass,lambdaset4(il));
        res41 = myNMIACC(H_normalized4,Y,numclass);
        accval41(it,il) = res41(1);
        nmival41(it,il) = res41(2);
        purval41(it,il) = res41(3);
    end
end
res(:,9) = [max(max(accval41)); max(max(nmival41)); max(max(purval41))];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M = calculateM(KH);
rhoset2 = 2.^[-7:1:9];
lambdaset2 = 2.^[-6:1:7];
accval2 = zeros(length(rhoset2),length(lambdaset2));
nmival2 = zeros(length(rhoset2),length(lambdaset2));
purval2 = zeros(length(rhoset2),length(lambdaset2));
for ir =1:length(rhoset2)
    for il = 1:length(lambdaset2)
        [H_normalized2,gamma2,G2,obj2] = myoptimalNeighborhoodkernelclustering(KH,M,numclass,rhoset2(ir),lambdaset2(il));
        res2 = myNMIACC(H_normalized2,Y,numclass);
        accval2(ir,il) = res2(1);
        nmival2(ir,il) = res2(2);
        purval2(ir,il) = res2(3);
    end
end
res(:,10) = [max(max(accval2)); max(max(nmival2)); max(max(purval2))];

save([path,'work2017\myRes2017\',dataName,'_clustering_acc.mat'],'res');