function [rateMap] = computeRateMap(posx,posy,fr)

% this assumes that posx and posy were already scaled to have appropriate
% max and min. also take 'fr' variable, which is just the number of spikes
% that occurred in every 20 ms time bin

% use 20 bins, no matter the size of the environment
numBins = 20+1;

xAxis = linspace(min(posx),max(posx),numBins);
yAxis = xAxis;

% initialize rate map
rateMap = zeros(numBins-1,numBins-1);

% find the mean firing rate in each position bin
for i  = 1:numBins-1
    for j = 1:numBins-1
        start_x = xAxis(i); stop_x = xAxis(i+1);
        start_y = yAxis(j); stop_y = yAxis(j+1);
        
        % find the times the animal was in the bin
        if i == numBins-1
            x_ind = find(posx >= start_x & posx <= stop_x);
        else
            x_ind = find(posx >= start_x & posx < stop_x);
        end
        
        if j == numBins-1
            y_ind = find(posy >= start_y & posy <= stop_y);
        else
            y_ind = find(posy >= start_y & posy < stop_y);
        end
        
        ind = intersect(x_ind,y_ind);
        
        % fill in rate map
        rateMap(numBins - j,i) = nanmean(fr(ind));
    end
end

% MORE PROCESSING OF RATE MAP (SMOOTHING, ETC):

% fill in the NaNs with neigboring values
nan_ind = find(isnan(rateMap));
[j,i] = ind2sub(size(rateMap),nan_ind);
nan_num= numel(nan_ind);

% fill in the NaNs with neigboring values
for n = 1:nan_num
    ind_i = i(n); ind_j = j(n);
    
    right = rateMap(ind_j,min(ind_i+1,numBins-1)); 
    left = rateMap(ind_j,max(ind_i-1,1)); 
    down = rateMap(min(ind_j+1,numBins-1),ind_i); 
    up = rateMap(max(ind_j-1,1),ind_i);
    
    ru = rateMap(max(ind_j-1,1),min(ind_i+1,numBins-1));
    lu = rateMap(max(ind_j-1,1),max(ind_i-1,1));
    ld = rateMap(min(ind_j+1,numBins-1),max(ind_i-1,1));
    rd = rateMap(max(ind_j-1,1),min(ind_i+1,numBins-1));
    
    rateMap(ind_j,ind_i) = nanmean([left right up down lu ru rd ld]);
    
end

% smooth with Gaussian
H = fspecial('gaussian'); % using default values - size=[3 3] and sigma=0.5
rateMap = imfilter(rateMap,H);


return