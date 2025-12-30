% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

function A = solve_A_Fnorm(X, Y)
% SOLVE_A_FNORM Solve Y = AX for A by minimizing the Frobenius norm of changes.
%
%   A = SOLVE_A_FNORM(X, Y) finds the best low-rank approximation of A
%   using Singular Value Decomposition (SVD). This is effective when 
%   recovering a matrix that has undergone low-rank changes.
%
%   Input:
%       X: Input matrix (features).
%       Y: Output matrix.
%
%   Output:
%       A: Recovered matrix.

threshold = 0.01; % threshold for singular values

l = size(Y, 1);
m = size(X, 1);

[U, S, V] = svd(X); % X = U * S * V'

% Remove small singular values for stability
nn = sum(diag(S) > threshold); 
S = S(:, 1:nn);
V = V(:, 1:nn);

% Calculate the regression
Y = Y * V;
Sinv = diag(1 ./ diag(S));
Z1 = Y * Sinv;
Z = [Z1, zeros(l, m - nn)];
A = Z * U';
