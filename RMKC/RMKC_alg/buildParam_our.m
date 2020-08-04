function paramCell = buildParam_our(p1Candidates1,p1Candidates6,p1Candidates7)
if ~exist('p1Candidates1', 'var')
    p1Candidates1 = [1e-4,1e-3,1e-2,1e-1,1,10,100,1000,10000];
end

p1Candidates2=1;
p1Candidates3=1.1;
p1Candidates5=1;

if ~exist('p1Candidates6', 'var')
	p1Candidates6 = [1e-3,1e-2,1e-1,1,10,100,1000];
end

if ~exist('p1Candidates7', 'var')
	p1Candidates7 =0.7;
end

n1 = length(p1Candidates1);
n6=length(p1Candidates6);
n7=length(p1Candidates7);
nP = n1*n6*n7;

paramCell = cell(nP, 1);
idx = 0;

for i1 = 1:n1
	for i6=1:n6
        for i7=1:n7
			param = [];
			if ~isempty(p1Candidates1)
				param.lambda1 = p1Candidates1(i1);
				param.opts.mu=p1Candidates2;
				param.opts.rho=p1Candidates3;
                param.ini=p1Candidates5;
                param.lambda2=p1Candidates6(i6);
                param.t=p1Candidates7(i7);
			end
    
			idx = idx + 1;
			paramCell{idx} = param;
                
		end
	end
end
end