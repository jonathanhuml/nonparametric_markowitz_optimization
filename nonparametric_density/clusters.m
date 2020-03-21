rng(420); 
cluster = readtable("bins.csv");
index = cluster{:,3};


%for non zero modulo 5 size portfolios, you 
%just make the "1" in variable "y" random
%and make them sum to whatever the portfolio size is
five_assets = zeros(200,5); 
for c = 1:5
    clust = index((cluster{:,2} == c),:);
    for i = 1:200
        y = randsample(clust,1);
        five_assets(i,c) = y;
    end
end

%basically the same process for 5-10 
ten_assets = zeros(200,10); 
for i = 1:200
    x = [randsample(index((cluster{:,2} == 1),:),2)'  randsample(index((cluster{:,2} == 2),:),2)'...
        randsample(index((cluster{:,2} == 3),:),2)' randsample(index((cluster{:,2} == 4),:),2)'...
        randsample(index((cluster{:,2} == 5),:),2)'];
    ten_assets(i,:) = x;
  
end