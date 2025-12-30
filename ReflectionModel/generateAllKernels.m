% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

function K = generateAllKernels(lights, sensors, dim, para)
% GENERATEALLKERNELS Generate reflection kernels for all sensor-fixture pairs.
%
%   K = GENERATEALLKERNELS(lights, sensors, dim, para) computes the 
%   reflection kernel for every possible pair of lights and sensors.
%
%   Input:
%       lights:  3D spatial coordinates of all fixtures [Nx3].
%       sensors: 3D spatial coordinates of all sensors [Mx3].
%       dim:     3D dimension of the room [1x3].
%       para:    Reflection model parameter (0: non-Lambertian, 1: Lambertian).
%
%   Output:
%       K: MxN cell array where K{s,l} is the reflection kernel for 
%          sensor s and light l.
%
%   Note: This function can be slow for large grids. Consider caching results.

K = cell(size(sensors, 1), size(lights, 1));

for s = 1:size(sensors, 1)
    for l = 1:size(lights, 1)
        K{s, l} = getReflectionKernel(lights(l, :), sensors(s, :), dim, para);
        K{s, l} = K{s, l}(:, end:-1:1); % Consistent with paper occupancy scenarios
    end
end