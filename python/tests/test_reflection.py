import numpy as np
import scipy.io
import os
import pytest
from cosbos import reflection

@pytest.fixture
def ground_truth():
    # Load .mat file
    data_path = os.path.join(os.path.dirname(__file__), 'data', 'ground_truth.mat')
    return scipy.io.loadmat(data_path)

def test_getReflectionKernel(ground_truth):
    # Extract inputs
    # In generate script:
    # light = lights(1,:); sensor = sensors(1,:);
    # K = getReflectionKernel(light, sensor, dim, para);
    
    light = ground_truth['light'].flatten()
    sensor = ground_truth['sensor'].flatten()
    dim = ground_truth['dim'].flatten()
    para = ground_truth['para'].item()
    
    K_true = ground_truth['K']
    
    # Run Python implementation
    K_pred = reflection.getReflectionKernel(light, sensor, dim, para)
    
    # Verify
    np.testing.assert_allclose(K_pred, K_true, rtol=1e-5, atol=1e-8)
