function [f, df, hessian] = ln_poisson_model(param,data,modelType)

X = data{1}; % subset of A
Y = data{2}; % number of spikes

% compute the firing rate
u = X * param;
rate = exp(u);

% roughness regularizer weight - note: these are tuned using the sum of f,
% and thus have decreasing influence with increasing amounts of data
b_pos = 8e0; b_hd = 5e1; b_spd = 5e1; b_th = 5e1;

% start computing the Hessian
rX = bsxfun(@times,rate,X);       
hessian_glm = rX'*X;

%% find the P, H, S, or T parameters and compute their roughness penalties

% initialize parameter-relevant variables
J_pos = 0; J_pos_g = []; J_pos_h = []; 
J_hd = 0; J_hd_g = []; J_hd_h = [];  
J_spd = 0; J_spd_g = []; J_spd_h = [];  
J_theta = 0; J_theta_g = []; J_theta_h = [];  

% find the parameters
numPos = 400; numHD = 18; numSpd = 10; numTheta = 18; % hardcoded: number of parameters
[param_pos,param_hd,param_spd,param_theta] = find_param(param,modelType,numPos,numHD,numSpd,numTheta);

% compute the contribution for f, df, and the hessian
if ~isempty(param_pos)
    [J_pos,J_pos_g,J_pos_h] = rough_penalty_2d(param_pos,b_pos);
end

if ~isempty(param_hd)
    [J_hd,J_hd_g,J_hd_h] = rough_penalty_1d_circ(param_hd,b_hd);
end

if ~isempty(param_spd)
    [J_spd,J_spd_g,J_spd_h] = rough_penalty_1d(param_spd,b_spd);
end

if ~isempty(param_theta)
    [J_theta,J_theta_g,J_theta_h] = rough_penalty_1d_circ(param_theta,b_th);
end

%% compute f, the gradient, and the hessian 

f = sum(rate-Y.*u) + J_pos + J_hd + J_spd + J_theta;
df = real(X' * (rate - Y) + [J_pos_g; J_hd_g; J_spd_g; J_theta_g]);
hessian = hessian_glm + blkdiag(J_pos_h,J_hd_h,J_spd_h,J_theta_h);


%% smoothing functions called in the above script
function [J,J_g,J_h] = rough_penalty_2d(param,beta)

    numParam = numel(param);
    D1 = spdiags(ones(sqrt(numParam),1)*[-1 1],0:1,sqrt(numParam)-1,sqrt(numParam));
    DD1 = D1'*D1;
    M1 = kron(eye(sqrt(numParam)),DD1); M2 = kron(DD1,eye(sqrt(numParam)));
    M = (M1 + M2);
    
    J = beta*0.5*param'*M*param;
    J_g = beta*M*param;
    J_h = beta*M;

function [J,J_g,J_h] = rough_penalty_1d_circ(param,beta)
    
    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    
    % to correct the smoothing across first and last bin
    DD1(1,:) = circshift(DD1(2,:),[0 -1]);
    DD1(end,:) = circshift(DD1(end-1,:),[0 1]);
    
    J = beta*0.5*param'*DD1*param;
    J_g = beta*DD1*param;
    J_h = beta*DD1;

function [J,J_g,J_h] = rough_penalty_1d(param,beta)

    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    J = beta*0.5*param'*DD1*param;
    J_g = beta*DD1*param;
    J_h = beta*DD1;
   
%% function to find the right parameters given the model type
function [param_pos,param_hd,param_spd,param_theta] = find_param(param,modelType,numPos,numHD,numSpd,numTheta)

param_pos = []; param_hd = []; param_spd = []; param_theta = [];

if all(modelType == [1 0 0 0]) 
    param_pos = param;
elseif all(modelType == [0 1 0 0]) 
    param_hd = param;
elseif all(modelType == [0 0 1 0]) 
    param_spd = param;
elseif all(modelType == [0 0 0 1]) 
    param_theta = param;

elseif all(modelType == [1 1 0 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
elseif all(modelType == [1 0 1 0]) 
    param_pos = param(1:numPos);
    param_spd = param(numPos+1:numPos+numSpd);
elseif all(modelType == [1 0 0 1]) 
    param_pos = param(1:numPos);
    param_theta = param(numPos+1:numPos+numTheta);
elseif all(modelType == [0 1 1 0]) 
    param_hd = param(1:numHD);
    param_spd = param(numHD+1:numHD+numSpd);
elseif all(modelType == [0 1 0 1]) 
    param_hd = param(1:numHD);
    param_theta = param(numHD+1:numHD+numTheta);
elseif all(modelType == [0 0 1 1])  
    param_spd = param(1:numSpd);
    param_theta = param(numSpd+1:numSpd+numTheta);
    
elseif all(modelType == [1 1 1 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_spd = param(numPos+numHD+1:numPos+numHD+numSpd);
elseif all(modelType == [1 1 0 1]) 
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_theta = param(numPos+numHD+1:numPos+numHD+numTheta);
elseif all(modelType == [1 0 1 1]) 
    param_pos = param(1:numPos);
    param_spd = param(numPos+1:numPos+numSpd);
    param_theta = param(numPos+numSpd+1:numPos+numSpd+numTheta);
elseif all(modelType == [0 1 1 1]) 
    param_hd = param(1:numHD);
    param_spd = param(numHD+1:numHD+numSpd);
    param_theta = param(numHD+numSpd+1:numHD+numSpd+numTheta);
    
elseif all(modelType == [1 1 1 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_spd = param(numPos+numHD+1:numPos+numHD+numSpd);
    param_theta = param(numPos+numHD+numSpd+1:numPos+numHD+numSpd+numTheta);
end
    


