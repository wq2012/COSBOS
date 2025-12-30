% COMPILE Compile the C++/MEX files for the blockage model.

% Save current directory and go to the module directory
curDir = pwd;
thisDir = fileparts(mfilename('fullpath'));
cd(thisDir);

try
    fprintf('Compiling hashGaussians.cpp...\n');
    mex -v hashGaussians.cpp;
    
    fprintf('Compiling volumeFromHashing.cpp...\n');
    mex -v volumeFromHashing.cpp;
catch e
    fprintf('Compilation failed: %s\n', e.message);
end

% Return to original directory
cd(curDir);
