clear
clc
warning off;

% path = 'D:\Work\lab_xwl\code\';
path = '/ONKC/';
addpath(genpath(path));
dataName = 'cornell_Kmatrix'; %%% flower17; flower102; CCV; caltech101_numofbasekernel_10
%% %% washington; wisconsin; texas; cornell
%% caltech101_nTrain5_48

load([path,'dataset/',dataName,'_Kmatrix'],'KH','Y');
% load([path,'datasets\',dataName,'_Kmatrix'],'KH','Y');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numclass = length(unique(Y));
numker = size(KH,3);
num = size(KH,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KH = kcenter(KH);
KH = knorm(KH);

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