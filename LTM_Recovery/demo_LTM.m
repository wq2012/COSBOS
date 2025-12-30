% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

%% Demonstration of Light Transport Matrix (LTM) Recovery
% This script demonstrates different techniques to recover the mapping A from Y = AX.

clear; clc; close all;

% Find module directory and data directory
moduleDir = fileparts(mfilename('fullpath'));
dataDir = fullfile(moduleDir, 'Data');

%% Demo 1: Overdetermined system
% Full rank recovery using pseudo-inverse.
load(fullfile(dataDir, 'U_18565.mat'));
X = bsxfun(@minus, TestLight(2:end, :), TestLight(1, :));
Y = bsxfun(@minus, cdata(2:end, :), cdata(1, :));
X = X';
Y = Y';
A_fullrank = solve_A_fullrank(X, Y);

%% Demo 2-4 prep: Underdetermined system
% First find the baseline LTM A0 from full-rank data.
load(fullfile(dataDir, '0_30876.mat'));
X = bsxfun(@minus, TestLight(2:end, :), TestLight(1, :));
Y = bsxfun(@minus, cdata(2:end, :), cdata(1, :));
X = X';
Y = Y';
A0 = solve_A_fullrank(X, Y);

% Assume we only have a small number of perturbation patterns (N2 = 20)
N2 = 20; 

%% Demo 2: Underdetermined, low rank recovery (Frobenius norm)
load(fullfile(dataDir, 'U_18565.mat'));
X = bsxfun(@minus, TestLight(2:end, :), TestLight(1, :));
Y = bsxfun(@minus, cdata(2:end, :), cdata(1, :));
X = X(1:N2, :)';
Y = Y(1:N2, :)';
Z = A0 * X - Y;

E = solve_A_Fnorm(X, Z);
A_Fnorm = A0 - E;

%% Demo 3: Underdetermined, L0 recovery (Sparsity)
E = solve_A_0norm(X, Z);
A_0norm = A0 - E;

%% Demo 4: Underdetermined, L1 recovery (Sparsity)
E = solve_A_1norm(X, Z);
A_1norm = A0 - E;

