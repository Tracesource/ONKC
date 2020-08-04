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

% %%%%%%%%%%%%%--RMSC---%%%%%%%%%%%%%%%%%%%%%%%
lambdaset5 = 2.^[-2];
accval5 = zeros(length(lambdaset5),1);
nmival5 = zeros(length(lambdaset5),1);
purval5 = zeros(length(lambdaset5),1);
ts = zeros(length(lambdaset5),1);
for il =1:length(lambdaset5)
    tic;
    [P_hat5] = RMSC(KH, lambdaset5(il));
    [U5] = baseline_spectral_onkernel(P_hat5,numclass);
    ts(il) = toc;
    res5 = my_eval_avg(U5,Y,numclass);
    accval5(il) = res5(1);
    nmival5(il) = res5(2);
    purval5(il) = res5(3);
end
res = [max(accval5);max(nmival5);max(purval5)];
tsavg = mean(ts);

