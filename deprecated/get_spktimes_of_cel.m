function [spktimes] = get_spktimes_of_cel(root,cel)

% set cel in root object
root.cel = cel;
% get spike times
spktimes = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);