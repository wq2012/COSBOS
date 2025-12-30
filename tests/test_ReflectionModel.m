function test_ReflectionModel()
    testsDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(testsDir);
    addpath(genpath(fullfile(rootDir, 'ReflectionModel')));
    
    %% Test lightDistribution
    fprintf('Testing lightDistribution...\n');
    val0 = lightDistribution(0);
    assert(val0 > 0, 'lightDistribution(0) should be positive');
    val90 = lightDistribution(pi/2);
    assert(val90 >= 0, 'lightDistribution(pi/2) should be non-negative');
    fprintf('lightDistribution passed.\n');
    
    %% Test getReflectionKernel
    fprintf('Testing getReflectionKernel...\n');
    light_pos = [5, 5, 10];
    sensor_pos = [2, 2, 2];
    dim = [10, 10, 10]; % Tiny room
    para = 1; % Lambertian
    
    K = getReflectionKernel(light_pos, sensor_pos, dim, para);
    assert(isequal(size(K), [dim(1), dim(2)]), 'getReflectionKernel returned wrong size');
    assert(all(K(:) >= 0), 'Reflection kernel should be non-negative');
    fprintf('getReflectionKernel passed.\n');
    
    %% Test generateAllKernels
    fprintf('Testing generateAllKernels...\n');
    lights = [5, 5, 10; 8, 8, 10];
    sensors = [2, 2, 2];
    % generateAllKernels(lights, sensors, dim, para)
    % Note: order of args in function def is (lights, sensors, dim, para)
    % Let's verify file content... 
    % File says: function K=generateAllKernels(lights,sensors,dim,para)
    
    allK = generateAllKernels(lights, sensors, dim, para);
    assert(isequal(size(allK), [size(sensors,1), size(lights,1)]), 'generateAllKernels output cell array size incorrect');
    assert(~isempty(allK{1,1}), 'Kernel cell should not be empty');
    fprintf('generateAllKernels passed.\n');
    
end
