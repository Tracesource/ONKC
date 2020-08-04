
ds={'YALE_165n_1024d_15c_zscore_uni'};
addpath(fullfile(pwd, '..', 'lib'));
for id = 1:length(ds)
    dataset = ['..\data\', ds{id}]
    runExp1(dataset, buildParamKernel({'Linear', 'Polynomial', 'Gaussian'}, {[],  [2, 4], sqrt([0.01,  0.1, 1, 10,  100] / sqrt(2))}, {'NCW-SCALE-SYM'}), 10,'NCW-SCALE-SYM');
end