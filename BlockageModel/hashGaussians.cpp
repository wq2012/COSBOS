/**
 * Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>,
 * Signal Analysis and Machine Perception Laboratory,
 * Department of Electrical, Computer, and Systems Engineering,
 * Rensselaer Polytechnic Institute, Troy, NY 12180, USA
 */

/** 
 * HASHGAUSSIANS: C++/MEX code for hashing Gaussians and distances.
 *
 * This function calculates distances from every pixel in a 3D volume to the
 * line segments connecting sensor-light pairs, and computes a Gaussian 
 * distribution based on these distances.
 *
 * Compilation: 
 *     mex hashGaussians.cpp
 *
 * Usage:
 *     H = hashGaussians(sensors, lights, dim, sigma)
 *         sensors: 3D spatial coordinates of sensors [N x 3]
 *         lights:  3D spatial coordinates of lights [M x 3]
 *         dim:     3D dimension of the room [1 x 3]
 *         sigma:   Standard deviation of the Gaussian kernel (scalar)
 *         H:       The hashed Gaussian data [prod(dim)*N*M x 1]
 */

#include "mex.h"
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <iostream>
#include <vector>

using namespace std;

/**
 * Calculates distance from point (x,y,z) to line segment (x1,y1,z1)-(x2,y2,z2).
 * Returns the distance and a flag indicating if the projection is on the segment.
 */
struct DistResult {
    double d;
    bool onSegment;
};

inline DistResult pointToLineDistance(double x, double y, double z, 
                                     double x1, double y1, double z1, 
                                     double x2, double y2, double z2) {
    double x3 = x2 - x1;
    double y3 = y2 - y1;
    double z3 = z2 - z1;
    double segmentLenSq = x3*x3 + y3*y3 + z3*z3;
    
    if (segmentLenSq == 0) return {sqrt((x-x1)*(x-x1) + (y-y1)*(y-y1) + (z-z1)*(z-z1)), true};

    double alpha = (x3*(x - x1) + y3*(y - y1) + z3*(z - z1)) / segmentLenSq;
    
    double xv = x1 - x + alpha * x3;
    double yv = y1 - y + alpha * y3;
    double zv = z1 - z + alpha * z3;
    
    DistResult res;
    res.d = sqrt(xv*xv + yv*yv + zv*zv);
    res.onSegment = (alpha >= 0.0 && alpha <= 1.0);
        
    return res;
}

/**
 * Main computation loop to generate the Gaussian volume.
 * Optimized to avoid heap allocations in inner loops.
 */
void generateGaussian(double *H, double *sensors, double *lights, int *dim, double sigma, int ns, int nl) {
    long dimProd = (long)dim[0] * dim[1] * dim[2];
    double invTwoSigmaSq = 1.0 / (2.0 * sigma * sigma);

    cout << "Rendering volume H (" << ns << " sensors, " << nl << " lights) ..." << endl;
    
    // Pre-extract coordinates to avoid repeated indexing
    vector<double> sx(ns), sy(ns), sz(ns);
    vector<double> lx(nl), ly(nl), lz(nl);
    for (int s = 0; s < ns; ++s) {
        sx[s] = sensors[s];
        sy[s] = sensors[s + ns];
        sz[s] = sensors[s + ns * 2];
    }
    for (int l = 0; l < nl; ++l) {
        lx[l] = lights[l];
        ly[l] = lights[l + nl];
        lz[l] = lights[l + nl * 2];
    }

    for (long i = 0; i < dimProd; i++) {
        long a = i;
        int x = a % dim[0];
        a /= dim[0];
        int y = a % dim[1];
        int z = a / dim[1];
        
        for (int j = 0; j < ns * nl; j++) {
            int s = j % ns;
            int l = j / ns;
            
            DistResult res = pointToLineDistance((double)x, (double)y, (double)z, 
                                                sx[s], sy[s], sz[s], 
                                                lx[l], ly[l], lz[l]);
            
            H[i + dimProd * j] = exp(-res.d * res.d * invTwoSigmaSq);
        }
    }
}

/* MEX gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Check for proper number of arguments */
    if (nrhs != 4) {
        mexErrMsgIdAndTxt("MATLAB:hashGaussians:invalidNumInputs", "Four inputs required.");
    }
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("MATLAB:hashGaussians:invalidNumOutputs", "One output required.");
    }
    
    /* Check sigma input */
    if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3]) != 1) {
        mexErrMsgIdAndTxt("MATLAB:hashGaussians:sigmaNotScalar", "Input sigma must be a scalar double.");
    }
    
    double sigma = mxGetScalar(prhs[3]);
    double *sensors = mxGetPr(prhs[0]);
    double *lights = mxGetPr(prhs[1]);
    double *dimInput = mxGetPr(prhs[2]);
    
    int dim[3];
    dim[0] = (int)dimInput[0];
    dim[1] = (int)dimInput[1];
    dim[2] = (int)dimInput[2];
    
    int ns = (int)mxGetM(prhs[0]);
    int nl = (int)mxGetM(prhs[1]);
            
    /* Create output matrix */
    mwSize outDims[2];
    outDims[0] = (mwSize)dim[0] * dim[1] * dim[2] * ns * nl;
    outDims[1] = 1;
    plhs[0] = mxCreateNumericArray(2, outDims, mxDOUBLE_CLASS, mxREAL);
    
    double *H = mxGetPr(plhs[0]);
    
    /* Call calculation routine */
    generateGaussian(H, sensors, lights, dim, sigma, ns, nl);
}
