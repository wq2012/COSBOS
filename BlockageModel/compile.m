% COMPILE Compile the C++/MEX files for the blockage model.

thisDir = fileparts(mfilename('fullpath'));
mex(fullfile(thisDir, 'hashGaussians.cpp'), '-outdir', thisDir);
mex(fullfile(thisDir, 'volumeFromHashing.cpp'), '-outdir', thisDir);
