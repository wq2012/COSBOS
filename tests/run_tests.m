function run_tests()
    % Master test runner script
    
    addpath(fullfile(pwd, 'tests'));
    
    tests_to_run = {
        @test_BlockageModel,
        @test_ReflectionModel,
        @test_LTM_Recovery
    };
    
    passed_count = 0;
    failed_count = 0;
    
    for i = 1:length(tests_to_run)
        test_func = tests_to_run{i};
        func_name = func2str(test_func);
        fprintf('--------------------------------------------------\n');
        fprintf('Running %s...\n', func_name);
        try
            test_func();
            fprintf('%s PASSED.\n', func_name);
            passed_count = passed_count + 1;
        catch e
            fprintf('%s FAILED.\n', func_name);
            fprintf('Error: %s\n', e.message);
            fprintf('Stack trace:\n');
            for k=1:length(e.stack)
                fprintf('  %s:%d\n', e.stack(k).name, e.stack(k).line);
            end
            failed_count = failed_count + 1;
        end
    end
    
    fprintf('--------------------------------------------------\n');
    fprintf('Summary: %d Passed, %d Failed.\n', passed_count, failed_count);
    
    if failed_count > 0
        error('Some tests failed.');
    end
end
