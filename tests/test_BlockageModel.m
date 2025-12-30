function test_BlockageModel()
    testsDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(testsDir);
    addpath(genpath(fullfile(rootDir, 'BlockageModel')));
    addpath(genpath(fullfile(rootDir, 'LTM_Recovery')));
    
    %% Compile MEX files if needed (Simple check)
    % In a proper CI, we might compile explicitly, but let's try to ensure they exist
    if exist(fullfile(rootDir, 'BlockageModel', 'volumeFromHashing.mex'), 'file') ~= 3 && ...
       exist(fullfile(rootDir, 'BlockageModel', 'volumeFromHashing.mexa64'), 'file') ~= 3
        fprintf('Compiling volumeFromHashing...\n');
        curDir = pwd;
        cd(fullfile(rootDir, 'BlockageModel'));
        mex volumeFromHashing.cpp
        cd(curDir);
    end
    if exist(fullfile(rootDir, 'BlockageModel', 'hashGaussians.mex'), 'file') ~= 3 && ...
       exist(fullfile(rootDir, 'BlockageModel', 'hashGaussians.mexa64'), 'file') ~= 3
        fprintf('Compiling hashGaussians...\n');
        curDir = pwd;
        cd(fullfile(rootDir, 'BlockageModel'));
        mex hashGaussians.cpp
        cd(curDir);
    end

    %% Test coordinates
    fprintf('Testing coordinates script...\n');
    % coordinates_blockage is a script, so it puts variables in workspace
    coordinates_blockage; 
    assert(exist('sensors','var') && exist('lights','var') && exist('dim','var'), 'coordinates script did not create variables');
    assert(size(sensors, 2) == 3, 'sensors should be Nx3');
    assert(length(dim) == 3, 'dim should be length 3 vector');
    fprintf('coordinates passed.\n');
    
    %% Test hashGaussians and volumeFromHashing
    fprintf('Testing hashGaussians and volumeFromHashing...\n');
    sigma = 20;
    
    % Use smaller dim for test speed
    test_dim = [20, 20, 20];
    % Create dummy sensors and lights fitting in test_dim
    s = [5, 5, 5; 15, 15, 15];
    l = [5, 5, 15; 15, 15, 5];
    
    H = hashGaussians(s, l, test_dim, sigma);
    % H should be a vector of size prod(test_dim) * number_of_pairs
    % pairs = n_sensors * n_lights = 2*2 = 4
    expected_H_len = prod(test_dim) * size(s,1) * size(l,1);
    assert(length(H) == expected_H_len, 'hashGaussians output length mismatch');
    
    % Test volumeFromHashing
    % E is the difference matrix, size [n_sensors*n_lights * 4*3 ?] 
    % Wait, checking volumeFromHashing.cpp loops:
    % ns = number of sensors
    % nl = number of lights
    % E seems to be flat array. 
    % In volumeFromHashing.cpp:
    % for(i=0;i<4*ns*3*nl;i++) ... 
    % So E should have size 4*ns * 3*nl = 12 * ns * nl elements.
    
    ns = size(s,1);
    nl = size(l,1);
    E_len = 4 * ns * 3 * nl;
    E = rand(E_len, 1);
    
    V = volumeFromHashing(s, l, test_dim, H, E);
    assert(isequal(size(V), test_dim), 'volumeFromHashing output dimensions mismatch');
    fprintf('hashGaussians and volumeFromHashing passed.\n');

    %% Test writeTiff
    fprintf('Testing writeTiff...\n');
    filename = 'test_output.tif';
    if exist(filename, 'file')
        delete(filename);
    end
    writeTiff(V, filename);
    assert(exist(filename, 'file') == 2, 'writeTiff did not create file');
    delete(filename);
    fprintf('writeTiff passed.\n');

end
