function [posx,posy,posx2,posy2,post] = rescalePos(posfile,boxSize,filt_eeg,sampleRate)

% load data
load(posfile);

%% if there isn't a second LED recording, reject all of this
if numel(posx2) < 1 || numel(posy2) < 1
    posx = NaN; posy = NaN; posx2 = NaN; posy2 = NaN;
    return
end

%% take out NaN's and replace them with neighboring values
% I replace the NaN's with values that precede the NaN
positions = {posx, posy, posx2, posy2};
for k = 1:4
    pos_temp = positions{k};
    nan_ind = find(isnan(pos_temp));
    for m = 1:numel(nan_ind)
        if nan_ind(m) - 1 == 0
            temp = find(~isnan(pos_temp),1,'first');
            pos_temp(nan_ind(m)) = pos_temp(temp);
        else
            pos_temp(nan_ind(m)) = pos_temp(nan_ind(m)-1);
        end
    end
    
    positions{k} = pos_temp;
    
end

posx = positions{1}; posy = positions{2}; 
posx2 = positions{3}; posy2 = positions{4};

%% make sure that the length of the vectors are correct given the eeg recording
maxTime = numel(filt_eeg)/sampleRate*50;
posx = posx(1:min(maxTime,numel(post))); posx2 = posx2(1:min(maxTime,numel(post)));
posy = posy(1:min(maxTime,numel(post))); posy2 = posy2(1:min(maxTime,numel(post)));
post = post(1:min(maxTime,numel(post)));

%% rescale the x and y position, so position goes from 0 to boxsize (typically 50-100 cm)
% assumes shape is a box
% rescale x-position
maxval_x = max(max([posx posx2])); minval_x = min(min([posx posx2]));
posx = boxSize * (posx-minval_x) / (maxval_x-minval_x); 
posx2 = boxSize * (posx2-minval_x) / (maxval_x-minval_x); 

% rescale y-position
maxval_y = max(max([posy posy2])); minval_y = min(min([posy posy2]));
posy = boxSize * (posy-minval_y) / (maxval_y-minval_y); 
posy2 = boxSize * (posy2-minval_y) / (maxval_y-minval_y); 


return