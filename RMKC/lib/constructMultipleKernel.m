function Ks = constructMultipleKernel(inXCell, kernelParamCell)
if iscell(inXCell)
    nKernel = length(inXCell) * length(kernelParamCell);
    Ks = cell(nKernel, 1);
    idx = 0;
    for iView = 1:length(inXCell)
        for iKernel = 1:length(kernelParamCell);
            idx = idx + 1;
            kernelOption = kernelParamCell{iKernel};
            if strcmpi(kernelOption.KernelType, 'Gaussian')
                kernelOption.t = kernelOption.t * optSigma(inXCell{iView});
            end
            Ks{idx} = constructKernel(inXCell{iView}, inXCell{iView}, kernelOption);
            Ks{idx} = KernelNormalize(Ks{idx}, kernelOption.normType);
        end
    end
else
    nKernel = length(kernelParamCell);
    Ks = cell(nKernel, 1);
    for iKernel = 1:nKernel
        kernelOption = kernelParamCell{iKernel};
        if strcmpi(kernelOption.kernelType, 'Gaussian')
            kernelOption.t = kernelOption.t * optSigma(inXCell);
        end
        Ks{iKernel} = constructKernel(inXCell, inXCell, kernelOption);
        Ks{iKernel} = KernelNomalize(Ks{iKernel}, kernelOption.normType);
    end
end