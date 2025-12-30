% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

function A = solve_A_1norm(X, Y)
% SOLVE_A_1NORM Solve Y = AX for A by minimizing L1-norm of vec(A).
%
%   A = SOLVE_A_1NORM(X, Y) solves the linear system Y = A * X for A,
%   where A is assumed to be sparse, and its L1-norm is minimized using 
%   primal-dual interior point method.
%
%   Input:
%       X: Input matrix (features).
%       Y: Output matrix.
%
%   Output:
%       A: Recovered sparse matrix.

% Add path to l1-magic
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, 'Lib/l1magic/Optimization'));

m1 = size(X, 1);
m2 = size(Y, 1);

% Construct the Kronecker product form for vec(A)
XX = kron(X', eye(m2, m2));
YY = Y(:);

% Solve using l1-magic primal-dual solver
evalc('AA = l1eq_pd(zeros(m2*m1,1), XX, [], YY)'); % avoid echo 
A = reshape(AA, [m2, m1]);
