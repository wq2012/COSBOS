import numpy as np
import scipy.io
import os
import pytest
from cosbos import blockage

@pytest.fixture
def ground_truth():
    data_path = os.path.join(os.path.dirname(__file__), 'data', 'ground_truth.mat')
    return scipy.io.loadmat(data_path)

def test_hashGaussians(ground_truth):
    # Extract inputs
    sensors = ground_truth['sensors_blockage']
    lights = ground_truth['lights_blockage']
    dim = ground_truth['dim'].flatten()
    sigma = ground_truth['sigma'].item()
    
    H_true = ground_truth['H'].flatten() # MATLAB H is [prod(dim)*N*M, 1]
    
    # Run Python implementation
    H_pred = blockage.hashGaussians(sensors, lights, dim, sigma)
    
    # Verify
    np.testing.assert_allclose(H_pred, H_true, rtol=1e-5, atol=1e-8)

def test_volumeFromHashing(ground_truth):
    sensors = ground_truth['sensors_blockage']
    lights = ground_truth['lights_blockage']
    dim = ground_truth['dim'].flatten()
    H = ground_truth['H'].flatten('F') # Ensure column-major order
    E = ground_truth['E'].flatten('F')
    
    V_true = ground_truth['V']
    
    # Run Python implementation
    V_pred = blockage.volumeFromHashing(sensors, lights, dim, H, E)
    
    # Verify
    np.testing.assert_allclose(V_pred, V_true, rtol=1e-5, atol=1e-8)
