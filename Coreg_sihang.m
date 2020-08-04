clear
clc
warning off;

% path = 'D:\Work\lab_xwl\code\';
path = '/home/ftp2/jiyuan/Kernel_Kmeans/';
addpath(genpath(path));
dataName = 'flower102'; %%% flower17; flower102; CCV; caltech101_mit_numOfClass_10
%% caltech101_numOfClass_10_Kmatrix
%% washington texas cornell; wisconsin, UCI_DIGIT
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qnorm = 2;

% % %%%%%%%%%%%%%--Spectral Clustering Co-training---%%%%%%%%%%%%%%%%%%%%%%%
accval4 = zeros(numker,1);
nmival4 = zeros(numker,1);
purval4 = zeros(numker,1);
tic;
[H_normalized4] = spectral_cotraining(KH,numclass);
tsavg = toc;
for p =1:numker
    res4 = my_eval_avg(H_normalized4(:,:,p),Y,numclass);
    accval4(p) = res4(1);
    nmival4(p) = res4(2);
    purval4(p) = res4(3);
end
res = [max(accval4);max(nmival4);max(purval4)];
