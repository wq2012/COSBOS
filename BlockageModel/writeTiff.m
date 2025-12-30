% Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>, 
% Signal Analysis and Machine Perception Laboratory, 
% Department of Electrical, Computer, and Systems Engineering, 
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

function writeTiff(V, filename)
% WRITETIFF Save a 3D volume to a multi-page TIFF image.
%
%   WRITETIFF(V, filename) normalizes the volume V to 0-255 range 
%   and writes it as a stack of 8-bit grayscale images in a TIFF file.
%
%   Input:
%       V:        3D scalar volume.
%       filename: Output filename (e.g., 'volume.tif').

% Normalize and convert to uint8
maxValue = max(V(:));
minValue = min(V(:));
V = (V - minValue) / (maxValue - minValue) * 255;
V = uint8(round(V));

% Write each slice
for i = 1:size(V, 3)
    if i == 1
        imwrite(V(:, :, i), filename);
    else
        imwrite(V(:, :, i), filename, 'WriteMode', 'append');
    end
end