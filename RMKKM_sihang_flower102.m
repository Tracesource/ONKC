clear
clc
warning off;

% path = 'D:\Work\lab_xwl\code\';
path = '/home/ftp2/jiyuan/Kernel_Kmeans/';
addpath(genpath(path));
dataName = 'flower102'; %%% flower17; flower102; CCV; caltech101_mit_numOfClass_10
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

gammaset7 = [0.1:0.2:0.5];
maxIter = 30;
accval7 = zeros(length(gammaset7),1);
nmival7 = zeros(length(gammaset7),1);
purval7 = zeros(length(gammaset7),1);
ts = zeros(length(gammaset7), maxIter);
for il =1:length(gammaset7)
    tmp1 = zeros(maxIter,1);
    tmp2 = zeros(maxIter,1);
    tmp3 = zeros(maxIter,1);
    for it =1:maxIter;
        tic;
        [indx7] = RMKKM(KH, numclass, 'gamma', gammaset7(il), 'maxiter',100);
        ts(il, it) = toc;
        indx7 = indx7(:);
        [newIndx7] = bestMap(Y,indx7);
        tmp1(it) = mean(Y==newIndx7);
        tmp2(it) = MutualInfo(Y,newIndx7);
        tmp3(it) = purFuc(Y,newIndx7);
    end
    accval7(il) = mean(tmp1);
    nmival7(il) = mean(tmp2);
    purval7(il) = mean(tmp3);
end
res = [max(accval7); max(nmival7); max(purval7)];
tsavg = mean(mean(ts)));