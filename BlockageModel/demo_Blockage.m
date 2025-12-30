% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

%% Demonstration of Light Blockage Model
% This script demonstrates occupancy sensing with wall-mounted sensors.

clear; clc; close all;

% Find module directory and add LTM_Recovery to path
moduleDir = fileparts(mfilename('fullpath'));
rootDir = fileparts(moduleDir);
addpath(fullfile(rootDir, 'LTM_Recovery'));

% Step 1: Compile the C++/MEX files (if not already compiled)
compile; 

%% Step 2: Recover Baseline Light Transport Matrix (A0)
dataDir = fullfile(moduleDir, 'Data');
load(fullfile(dataDir, '0_30876.mat'));
X = bsxfun(@minus, TestLight(2:end, :), TestLight(1, :));
Y = bsxfun(@minus, cdata(2:end, :), cdata(1, :));
X = X';
Y = Y';
A0 = solve_A_fullrank(X, Y);

%% Step 3: Recover Current Light Transport Matrix (A) with Occupancy
load(fullfile(dataDir, 'U_85164.mat'));
X = bsxfun(@minus, TestLight(2:end, :), TestLight(1, :));
Y = bsxfun(@minus, cdata(2:end, :), cdata(1, :));
X = X';
Y = Y';
A = solve_A_fullrank(X, Y);

%% Step 4: Render Room Occupancy Volume
% Calculate the difference matrix E
E = A0 - A;
E(E < 0) = 0;

% Parameters for the blockage model
sigma = 20;
coordinates_blockage; % Load spatial coordinates and room dimensions (sensors, lights, dim)

% Compute Gaussian hashing (line-to-pixel distances)
H = hashGaussians(sensors, lights, dim, sigma); 

% Render the final 3D volume
V = volumeFromHashing(sensors, lights, dim, H, E);

% Mirror the y-axis to be consistent with paper coordinate conventions
V = V(:, end:-1:1, :); 

%% Step 5: Visualization and Output
% Visualize floor-plane occupancy (sum along z-axis)
FloorPlane = sum(V, 3);
figure;
imagesc(FloorPlane);
axis equal off;
colormap('hot');
colorbar;
title('Floor-Plane Occupancy (Blockage Model)');

% Save result to a 3D TIFF image
writeTiff(V, 'V.tif');
