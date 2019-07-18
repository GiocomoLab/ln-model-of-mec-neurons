%% select_model.m
% This code will implement forward feature selection in order to determine
% the simplest model that best describes neural spiking. First, the
% highest-performing single-variable model is identified. Then, the
% highest-performing double-variable model that includes the
% single-variable model is identified. This continues until the full model
% is identified. Next, statistical tests are applied to see if including
% extra variables significantly improves model performance. The first time
% that including variable does NOT signficantly improve performance, the
% procedure is stopped and the model at that point is recorded as the
% selected model.
%
% the model indexing scheme:
% phst, phs, pht, pst, hst, ph, ps, pt, hs, ht, st, p,  h,  s,  t
% 1      2    3    4    5    6  7   8   9   10  11  12  13  14  15

%
% Syntax:
%
% Arguments:
%
% Outputs:
%
%

function select_model(self)

end % function
