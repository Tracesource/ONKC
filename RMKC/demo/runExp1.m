function runExp1(datasets, kernelParamCell, nRepeats,str)
addpath(fullfile(pwd, '..', 'lib'));
addpath(fullfile(pwd, '..', 'data'));
addpath(fullfile(pwd, '..', 'RMKKM'));
addpath(fullfile(pwd, '..', 'RMKC_alg'));

if ~exist('datasets', 'var') || isempty(datasets)
    datasets = {fullfile('..', filesep, 'data', filesep, 'jaffe_213n_676d_10c.mat')};
end
if ~iscell(datasets) && ischar(datasets)
    datasets = {datasets};
end

if ~exist('kernelParamCell', 'var') || isempty(kernelParamCell)
    % Kernel setting
    kernelParamCell = buildParamKernel({'Linear', 'PolyPlus', 'Polynomial', 'Gaussian'}, {[], [2, 4], [2, 4], sqrt([0.01, 0.05, 0.1, 1, 10, 50, 100] / sqrt(2))}, {'scale'});
end

if ~exist('nRepeats', 'var') || isempty(nRepeats)
    nRepeats = 10;
end
if ~exist('str', 'var') 
    str='scale';
end

for idataset = 1:length(datasets)
    [inXCell, y] = extractVarible(datasets{idataset});
    Ks = constructMultipleKernel(inXCell, kernelParamCell);
    
    
    prefix = substr(datasets{idataset}, filesep, '.mat');
    prefix=[prefix,str];
%    prefix=prefix(1:end-1);
    if ~exist(prefix, 'dir')
        mkdir(prefix);
    end
    prefix = fullfile(prefix, filesep, prefix);
    
    result_aio = [];
    result_aio.acc_obj_table = [];
    result_aio.purity_obj_table = [];
    result_aio.nmi_obj_table = [];
    result_aio.acc_avg_table = [];
    result_aio.purity_avg_table = [];
    result_aio.nmi_avg_table = [];
    result_aio.acc_std_table = [];
    result_aio.purity_std_table = [];
    result_aio.nmi_std_table = [];
    result_aio.algs =  {};
    
 
     

    
%      % our+sc
%try
       if ~exist([prefix, '_our_sc1.mat'], 'file')

           ourParamCell = buildParam_our([0.001,0.01,0.1,1,10,100,1000],[0.001,0.01,0.1,1,10,100],[0,0.3,0.5,0.7]);
           [result_our_km,result_our_sc] = run_ours(Ks, y, nRepeats,ourParamCell);% 1 * nRepeats
           save([prefix, '_our_sc1.mat'], 'result_our_sc');
           save([prefix, '_our_km1.mat'], 'result_our_km');
       else
           load([prefix, '_our_sc1.mat'], 'result_our_sc');
           load([prefix, '_our_km1.mat'], 'result_our_km');
       end
      result_aio = agg_res(result_aio, result_our_km, 'our_km');
      result_aio = agg_res(result_aio, result_our_sc, 'our_sc');
%catch
%    disp([prefix, '_our_sc1.mat',':wrong' ]);
%end
    
    
    
    save([prefix, '_aio1.mat']);
end
end

function result = agg_res(result, res, alg_name)
% result.acc_obj_table = [result.acc_obj_table, max(res.acc_obj_v)];
% result.purity_obj_table = [result.purity_obj_table, max(res.purity_obj_v)];
% result.nmi_obj_table = [result.nmi_obj_table, max(res.nmi_obj_v)];

result.acc_avg_table = [result.acc_avg_table, max(res.acc_avg_v)];
result.purity_avg_table = [result.purity_avg_table, max(res.purity_avg_v)];
result.nmi_avg_table = [result.nmi_avg_table, max(res.nmi_avg_v)];

result.acc_std_table = [result.acc_std_table, max(res.acc_std_v)];
result.purity_std_table = [result.purity_std_table, max(res.purity_std_v)];
result.nmi_std_table = [result.nmi_std_table, max(res.nmi_std_v)];

result.algs = [result.algs, {alg_name}];
end