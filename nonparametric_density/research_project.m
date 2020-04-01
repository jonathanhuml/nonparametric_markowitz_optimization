%note: you will need to run clusters.m and load
%obj.mlx for this file to run
%kldiv.m has been giving some of our group errors
%This file (kldiv.m) is NOT essential to running this script
%kldiv.m is simply my source of encoding the Kullback
%Liebler divergence

%dow and constituents
data = readtable("djia.csv");
datax = table2array(data(:,:));

%Rice's Rule for bins
nbins = ceil((length(datax)^(1/3)) * 2);
bins = (1:nbins)';
minimum = min(datax,[],'all'); 
maximum = max(datax,[],'all');

%range/nbins 
step_size = (maximum-minimum)/nbins; 

%don't really need to sort the data
%I just did to visualize the results and make 
%sure everything looks right
sorted = sort(datax);
nrow = size(sorted,1);
ncol = size(sorted,2);


binned = zeros(6*252,30);
for i = 1:nrow
    for j = 1:ncol
        for b = 1:nbins
            %a value needs to be between the minimum plus a multiple of the
            %step size and the previous/next bin index to be in that bin
            if sorted(i,j) >= minimum+(step_size*(b-1)) && sorted(i,j) <= minimum+(step_size*(b))
                binned(i,j) = bins(b,:);
            end
            %if greater than all these steps, put into 24th bin
            if sorted(i,j) >= minimum+(step_size*(23))
                binned(i,j) = 24;
            end
        end
    end
end


%floor function just so that integers and doubles match up
%this gets the counts of each unqiue bin by going down rows
%across columns, and through each of the 24 bins
counted = zeros(24,30);
for i = 1:nrow
    for j = 1:ncol
        for u = 1:length(unique(binned))
            if floor(binned(i,j)) == floor(u)
                counted(u,j) = counted(u,j) + 1; 
            end
        end
    end
end

%proportions
freq = counted ./ length(datax); 

%smoothing method
epsilon = 0.0000001; 
for i = 1:size(freq,1)
    for j = 1:size(freq,2)
       y = nnz(~freq(:,j));
       if freq(i,j) == 0
           %make each zero value have some small epsilon
           freq(i,j) = freq(i,j) + epsilon;
       end
       if freq(i,j) ~= 0
           %probability must add to one, so each time we add one epsilon
           %we subtract a fraction of epsilon from all nonzero values
           freq(i,j) = freq(i,j) - (epsilon/(length(freq)-y)); 
       end
            
    end
end


%%
%this is the optimization process
%we loop through each randomized portfolio found from clustering method
%this is just one example from asset numbers, the ten_asset portfolio
divergences = zeros(length(ten_assets),1);
for i = 1:length(ten_assets)
   
    prob = optimproblem;
    xarray = optimvar('xarray',10,1);  %xarray is our weights
    %ten weights for ten assets

    obj = fcn2optimexpr(@objfun,freq(:,1), freq(:, ten_assets(i,:)), xarray);

    %specification = freq(:,1); 
    %optimized = freq(:,2:3);

    prob.Objective = obj; 

    %weights must be equal to one
    constr = sum(xarray) <=1; 
    prob.Constraints.weights = constr;
    constr2 = sum(xarray) >= 1;
    prob.Constraints.weights2 = constr2;

    %starting point is 1/n equal weights
    x0.xarray = ones(10,1) ./ 10;

    [sol,fval,exitflag] = solve(prob,x0);
    divergences(i,1) = fval;
end
%%
%min divergence for ten_asset is 138
%same process as above, I just want specific weights for 10
prob = optimproblem;
xarray = optimvar('xarray',10,1); 

obj = fcn2optimexpr(@objfun,freq(:,1), freq(:, ten_assets(138,:)), xarray);

%specification = freq(:,1); 
%optimized = freq(:,2:3);

prob.Objective = obj; 

constr = sum(xarray) <=1; 
prob.Constraints.weights = constr;
constr2 = sum(xarray) >= 1;
prob.Constraints.weights2 = constr2;

x0.xarray = ones(10,1) ./ 10;

[sol,fval,exitflag] = solve(prob,x0);
divergences(i,1) = fval;
