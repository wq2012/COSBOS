% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

function A = solve_A_0norm(X, Y)
% SOLVE_A_0NORM Solve Y = AX for A by minimizing L0-norm of vec(A).
%
%   A = SOLVE_A_0NORM(X, Y) solves the linear system Y = A * X for A,
%   where A is assumed to be sparse, and its L0-norm is minimized using 
%   Orthogonal Matching Pursuit (OMP).
%
%   Input:
%       X: Input matrix (features).
%       Y: Output matrix.
%
%   Output:
%       A: Recovered sparse matrix.

% Add path to SparseLab solvers
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, 'Lib/SparseLab2.1-Core/Solvers'));

m1 = size(X, 1);
m2 = size(Y, 1);

% Construct the Kronecker product form for vec(A)
XX = kron(X', eye(m2, m2));
YY = Y(:);

% Solve using OMP
AA = SolveOMP(XX, YY, m1 * m2);
A = reshape(AA, [m2, m1]);
