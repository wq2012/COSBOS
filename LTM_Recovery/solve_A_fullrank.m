% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

function A = solve_A_fullrank(X, Y)
% SOLVE_A_FULLRANK Solve Y = AX for A when the system is overdetermined.
%
%   A = SOLVE_A_FULLRANK(X, Y) calculates A using the pseudo-inverse
%   when the system of equations has more observations than variables.
%
%   Input:
%       X: Input matrix (features).
%       Y: Output matrix.
%
%   Output:
%       A: Recovered matrix.

if size(X, 2) >= size(X, 1)
    A = Y / X;
else
    error('Error: Rank is not full. Cannot use full rank recovery of LTM.');
end