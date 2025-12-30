% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

%% Demonstration of Light Reflection Model
% This script demonstrates occupancy sensing with ceiling-mounted sensors.

moduleDir = fileparts(mfilename('fullpath'));
rootDir = fileparts(moduleDir);
addpath(fullfile(rootDir, 'LTM_Recovery'));

%% Step 1: Recover the Light Transport Matrix (LTM)
% Load baseline data
dataDir = fullfile(moduleDir, 'Data');
load(fullfile(dataDir, '0_24323.mat'));
X = bsxfun(@minus, TestLight(2:end, :), TestLight(1, :));
Y = bsxfun(@minus, cdata(2:end, :), cdata(1, :));
X = X';
Y = Y';
A0 = solve_A_fullrank(X, Y);

% Load data with occupancy
load(fullfile(dataDir, 'A_17327.mat'));
X = bsxfun(@minus, TestLight(2:end, :), TestLight(1, :));
Y = bsxfun(@minus, cdata(2:end, :), cdata(1, :));
X = X';
Y = Y';
A = solve_A_fullrank(X, Y);

%% Step 2: Generate Reflection Kernels
coordinates_reflection;
para = 1; % Lambertian model
K = generateAllKernels(lights, sensors, dim, para);

%% Step 3: Compute Floor-Plane Occupancy Map
% Calculate the difference matrix E
E = A0 - A;
E(E < 0) = 0;

% Parameters from the paper [1] (Eq. 16)
lambda1 = 1;
lambda2 = 1;

% Vectorized occupancy map calculation
ns = size(sensors, 1);
nl = size(lights, 1);

% Extract weights 'a' for all s, l pairs
% a(s, l) = E(4*s-3, 3*l-2) + E(4*s-2, 3*l-1) + E(4*s-1, 3*l)
% Let's construct indices for vectorization
s_idx = (1:ns)';
l_idx = 1:nl;
E_idx1 = 4 * s_idx - 3;
E_idx2 = 4 * s_idx - 2;
E_idx3 = 4 * s_idx - 1;
L_idx1 = 3 * l_idx - 2;
L_idx2 = 3 * l_idx - 1;
L_idx3 = 3 * l_idx;

weights = E(E_idx1, L_idx1) + E(E_idx2, L_idx2) + E(E_idx3, L_idx3);
weights = weights .^ lambda1;

% Weighted sum of kernels
% C = sum_{s,l} weights(s,l) * K{s,l}
% Since K is a cell array of matrices, we can use cellfun or a simple loop.
% Multi-dimensional cell multiplication is tricky, but we can vectorize 
% the multiplication of each cell by its weight.
weightedK = cellfun(@(k, w) k * w, K, num2cell(weights), 'UniformOutput', false);

% Sum all matrices in the cell array
C = zeros(dim(1), dim(2));
sumK = zeros(dim(1), dim(2));
for i = 1:numel(weightedK)
    C = C + weightedK{i};
    sumK = sumK + K{i};
end

%% Step 4: Visualization
% Final normalized occupancy map
C = C ./ (sumK .^ lambda2);

figure;
imagesc(C);
axis equal off;
colormap('hot');
colorbar;
title('Floor-Plane Occupancy Map (Reflection Model)');

