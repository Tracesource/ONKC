function paramSensResult = paramSensitive(expResult, paramCell)
if ~isstruct(expResult) || ~iscell(paramCell)
    error('result should be a struct, and param should be a cell');
end

fs_info = extractParamFields(paramCell);
res_info = extractResFields(expResult, paramCell);

nMetrics = length(res_info);
nParam = length(fs_info);
paramSensResult = cell(nMetrics, nParam);
for i1 = 1:nMetrics
    for i2 = 1:nParam
        paramSensResult{i1, i2} = fs_info{i2};
        paramSensResult{i1, i2}.(res_info{i1}) = expResult.(res_info{i1});
        resList = cell(1, length(fs_info{i2}.valueList));
        for i3 = 1:length(resList)
            tmp = expResult.(res_info{i1});
            resList{i3} = tmp(fs_info{i2}.paramList{i3});
        end
        if ~isempty(resList{1}) && ~isstruct(resList{1}) && ~iscell(resList{1})
            paramSensResult{i1, i2}.resList = resList;
            paramSensResult{i1, i2}.resAvg = cellfun(@mean, resList);
            paramSensResult{i1, i2}.resMax = cellfun(@max, resList);
            paramSensResult{i1, i2}.resMin = cellfun(@min, resList);
        end
    end
end

end

function fs_info = extractParamFields(paramCell)
fs_str = '';
fs_sep = '|';
nParam = length(paramCell);
for iParam = 1:nParam
    fs_iParam = fieldnames(paramCell{iParam});
    for iField = 1:length(fs_iParam)
        if ~isstruct(paramCell{iParam}.(fs_iParam{iField}))
            tmp = strsplit(fs_str, fs_sep);
            isFlag = 0;
            for iTemp = 1:length(tmp);
                if strcmpi(tmp{iTemp}, fs_iParam{iField})
                    isFlag = 1;
                end
            end
            if ~isFlag
                if isempty(fs_str)
                    fs_str = fs_iParam{iField};
                else
                    fs_str = [fs_str, fs_sep, fs_iParam{iField}];
                end
            end
        end
    end
end
fs = strsplit(fs_str, fs_sep);
nField = length(fs);
fs_info = cell(length(nField), 1);
for iField = 1:nField
    fs_info{iField} = struct('name', fs{iField}, 'value', [], 'paramIdx', []);
    for iParam = 1:nParam
        if isfield(paramCell{iParam}, fs{iField})
            if ischar(paramCell{iParam}.(fs{iField})) || isscalar(paramCell{iParam}.(fs{iField}))
                if ischar(paramCell{iParam}.(fs{iField}))
                    if isempty(fs_info{iField}.value)
                        fs_info{iField}.value = paramCell{iParam}.(fs{iField});
                    else
                        fs_info{iField}.value =  [fs_info{iField}.value, fs_sep, paramCell{iParam}.(fs{iField})];
                    end
                else
                    if isempty(fs_info{iField}.value)
                        fs_info{iField}.value = num2str(paramCell{iParam}.(fs{iField}));
                    else
                        fs_info{iField}.value =  [fs_info{iField}.value, fs_sep, num2str(paramCell{iParam}.(fs{iField}))];
                    end
                end
                fs_info{iField}.paramIdx = [fs_info{iField}.paramIdx, iParam];
            end
        end
    end
end

multiValueIdx = zeros(nField, 1);
for iField = 1:nField
    if ~isempty(fs_info{iField}.value)
        fs_info{iField}.value = strsplit(fs_info{iField}.value, fs_sep);
        valueList = unique(fs_info{iField}.value);
        fs_info{iField}.valueList = valueList;
        if isscalar(str2num(valueList{1}))
            scoreList = zeros(length(valueList),1);
            for iValue = 1:length(valueList)
                scoreList(iValue) = str2num(valueList{iValue});
            end
            [~, idx] = sort(scoreList, 'ascend');
            fs_info{iField}.valueList = cell(1, length(valueList));
            for iValue = 1:length(valueList)
                fs_info{iField}.valueList{iValue} = valueList{idx(iValue)};
            end
        end
        
        if length(fs_info{iField}.valueList) > 1
            multiValueIdx(iField) = 1;
            fs_info{iField}.paramList = cell(1, length(fs_info{iField}.valueList));
            nParam_f = length(fs_info{iField}.paramIdx);
            for iParam = 1:nParam_f
                for iTemp = 1:length(fs_info{iField}.valueList)
                    if strcmpi(fs_info{iField}.valueList{iTemp}, fs_info{iField}.value{iParam})
                        idx_t = iTemp;
                    end
                end
                fs_info{iField}.paramList{idx_t} = [fs_info{iField}.paramList{idx_t}, fs_info{iField}.paramIdx(iParam)];
            end
        end
    end
end

multiValueIdx = find(multiValueIdx);
fs_info_valid = cell(1, length(multiValueIdx));

for iField = 1:length(multiValueIdx)
    fs_info_valid{iField} = fs_info{multiValueIdx(iField)};
end
fs_info = fs_info_valid;

end

function res_info = extractResFields(expResult, paramCell)
nParam = length(paramCell);

fs_str = [];
fs_sep = '|';
fs = fieldnames(expResult);
for iField = 1:length(fs)
    if isvector(expResult.(fs{iField})) && length(expResult.(fs{iField})) == nParam
        if isempty(fs_str)
            fs_str = fs{iField};
        else
            fs_str = [fs_str, fs_sep, fs{iField}];
        end
    end
end

res_info = strsplit(fs_str, fs_sep);

end