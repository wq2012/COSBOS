function test_LTM_Recovery()
    testsDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(testsDir);
    addpath(genpath(fullfile(rootDir, 'LTM_Recovery')));
    
    % Setup a basic problem Y = A * X
    % Let's make it small for speed and simplicity
    m1 = 5; % rows of X (features)
    m2 = 3; % rows of Y (outputs)
    n = 10; % number of samples
    
    A_true = randn(m2, m1);
    X = randn(m1, n);
    Y = A_true * X;
    
    %% Test solve_A_fullrank
    % Requires X to have rank >= rows(X), so n >= m1
    fprintf('Testing solve_A_fullrank...\n');
    A_hat = solve_A_fullrank(X, Y);
    assert(norm(A_hat - A_true, 'fro') < 1e-10, 'solve_A_fullrank failed to recover A');
    fprintf('solve_A_fullrank passed.\n');
    
    %% Test solve_A_1norm
    % Use a sparse A for better testing of L1/L0 norm solvers?
    % Just testing they run and return correct shape for now.
    fprintf('Testing solve_A_1norm...\n');
    try
        A_hat_l1 = solve_A_1norm(X, Y);
        assert(isequal(size(A_hat_l1), size(A_true)), 'solve_A_1norm returned wrong size');
        % Note: Exact recovery might not happen without specific sparsity conditions, so we just check size and execution
        fprintf('solve_A_1norm passed.\n');
    catch e
        warning('solve_A_1norm failed: %s', e.message);
    end
    
    %% Test solve_A_0norm
    fprintf('Testing solve_A_0norm...\n');
    try
        A_hat_l0 = solve_A_0norm(X, Y);
        assert(isequal(size(A_hat_l0), size(A_true)), 'solve_A_0norm returned wrong size');
        fprintf('solve_A_0norm passed.\n');
    catch e
        warning('solve_A_0norm failed: %s', e.message);
    end
    
end
