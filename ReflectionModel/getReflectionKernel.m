% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

function K = getReflectionKernel(light, sensor, dim, para)
% GETREFLECTIONKERNEL Compute the reflection kernel for one sensor-fixture pair.
%
%   K = GETREFLECTIONKERNEL(light, sensor, dim, para) calculates the 
%   predicted light reflection on the floor plane based on the fixture 
%   and sensor positions.
%
%   Input:
%       light:   3D spatial coordinates of the light fixture [1x3].
%       sensor:  3D spatial coordinates of the sensor [1x3].
%       dim:     3D dimension of the room [1x3].
%       para:    Reflection model parameter (0: non-Lambertian, 1: Lambertian).
%
%   Output:
%       K: The resulting reflection kernel (2D matrix of size dim(1)xdim(2)).

% Extract scalar coordinates for readability and speed
lx=light(1);
ly=light(2);
lz=light(3);
sx=sensor(1);
sy=sensor(2);
sz=sensor(3);

% Vectorized implementation for performance.
% This replaces the nested loops over x and y with matrix operations.
%
% 1. coordinate grid generation:
%    We use ndgrid(1:dim(1), 1:dim(2)) to generate matrices X and Y.
%    X(i,j) contains the x-coordinate for the pixel (i,j).
%    Y(i,j) contains the y-coordinate for the pixel (i,j).
%    This avoids the explicit 'for x' and 'for y' loops.
[X, Y] = ndgrid(1:dim(1), 1:dim(2));

% 2. Distance calculations:
%    Calculate distances from every grid point (X,Y) to the light (lx, ly)
%    and sensor (sx, sy) simultaneously for the entire grid.
%    result `d1` and `d2` are matrices of size dim(1) x dim(2).
d1 = sqrt((lx - X).^2 + (ly - Y).^2);
d2 = sqrt((sx - X).^2 + (sy - Y).^2);

% 3. 3D Distance calculations:
%    Convert 2D distances to 3D distances including height differences (lz, sz).
D1 = sqrt(d1.^2 + lz^2);
D2 = sqrt(d2.^2 + sz^2);

% 4. Cosine calculations:
%    Calculate cosine of angles. Result is element-wise matrix division.
cos1 = lz ./ D1;
cos2 = sz ./ D2;

% 5. Angle calculations:
%    Calculate theta1 for all points.
theta1 = acos(cos1);

% 6. Luminous Intensity calculation:
%    The lightDistribution function calls interp1.
%    Since theta1 is a matrix, interp1 runs on all elements at once, 
%    which is much faster than calling it inside a loop.
Iq = lightDistribution(theta1);

% 7. Final Kernel calculation:
%    Combine all terms using element-wise multiplication (.*) and division (./).
%    Original: v = lightDistribution(theta1)*cos1*cos2/D1^2/D2^2;
v = Iq .* cos1 .* cos2 ./ (D1.^2) ./ (D2.^2);

% 8. Lambertian correction:
if para == 1
    v = v .* cos2; % Lambertian reflectance
end

K = v;
