function [frFilt,spkTrain] = get_InstFR(spktimes, time, sampling_rate_of_time, varargin)
% use (example):
%     cel = [2 1];
%     spktimes = get_spktimes_of_cel(root,cel);
%     [spkRate,~] = get_InstFR(spktimes,root.ts,root.fs_video,'filter_length',125,'filter_type','Gauss');
% get_InstFR(spktimes,time,sampling_rate_of_time,varargin) with optional inputs 'filter_length' (name-value pair) for length of filter
% (sigma for Gaussian filter, length of boxcar for boxcar filter), and
% 'filter_type' with options 'boxplot', 'Gauss', or 'hanning' for boxcar,
% Gaussian or hanning kernel, respectively. Default is boxplot. Outputs are the filtered
% firing rate and the spike train (vector of number of spikes per time
% bin). If the spkTrain is already known (spkTrain = vector with number of
% spikes per time bin), it can be given as input and will not be calculated
% from spktimes and time, which has to be given as empty matrices in that
% case.

p = inputParser;
addParameter(p,'filter_type','boxplot')
addParameter(p,'filter_length',100)
addParameter(p,'spkTrain',[])
parse(p,varargin{:})
filter_type = p.Results.filter_type;
filter_length = p.Results.filter_length;
spkTrain = p.Results.spkTrain;

%% Calculate number of spikes per time bin (instantaneous firing rate)
if isempty(spkTrain)
    spkTrain = zeros(size(time));
    %     temp = root.spike(root.cel(1), root.cel(2)).i; % indices of spike times within time
    [~,~,temp] = histcounts(spktimes,time);
    tt = unique(temp);
    % delete zeros
    for i = 1:length(tt)
        spkTrain(tt(i)) = sum(temp == tt(i));
    end
end

switch filter_type
    case 'boxplot'
        frFilt = smooth(spkTrain,filter_length/(1000/sampling_rate_of_time));
        frFilt = frFilt * sampling_rate_of_time;
    case 'Gauss'
        sigma = filter_length/(1000/sampling_rate_of_time);
        ssize = floor(10*sigma);
        x = linspace(-ssize / 2, ssize / 2, ssize);
        gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
        gaussFilter = gaussFilter / sum (gaussFilter); % normalize
        frFilt = conv (spkTrain, gaussFilter, 'same');
        frFilt = frFilt * sampling_rate_of_time;
%     case 'hanning' % there seems to be an error. The length of the output signal does not
%     match the length of the input signal
%         HannFilter = hanning(filter_length/(1000/sampling_rate_of_time));
%         HannFilter = HannFilter / sum(HannFilter);
%         frFilt = conv(spkTrain, HannFilter, 'same');
%         frFilt = frFilt * sampling_rate_of_time;
end

end
