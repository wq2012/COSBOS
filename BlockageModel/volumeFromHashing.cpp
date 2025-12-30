/**
 * Copyright (C) 2014 Quan Wang <wangq10@rpi.edu>,
 * Signal Analysis and Machine Perception Laboratory,
 * Department of Electrical, Computer, and Systems Engineering,
 * Rensselaer Polytechnic Institute, Troy, NY 12180, USA
 */

/** 
 * VOLUMEFROMHASHING: C++/MEX code for rendering volume from hashed Gaussians.
 *
 * Compilation: 
 *     mex volumeFromHashing.cpp
 *
 * Usage:
 *     V = volumeFromHashing(sensors, lights, dim, H, E)
 *         sensors: 3D spatial coordinates of sensors [N x 3]
 *         lights:  3D spatial coordinates of lights [M x 3]
 *         dim:     3D dimension of the room [1 x 3]
 *         H:       Hashed Gaussian data
 *         E:       Difference matrix, E = A0 - A 
 */

#include "mex.h"
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <iostream>
#include <vector>

using namespace std;

/**
 * Main computation loop to render the volume V.
 * Optimized with flat array for L and improved memory management.
 */
void generateVolume(double *V, const mwSize *dim, double *H, double *E, int ns, int nl) {
    // Aggregation of E into matrix L
    // We use a flat vector instead of double** for better cache locality
    vector<double> L(ns * nl, 0.0);
    
    cout << "Constructing matrix L ..." << endl;
    for (long i = 0; i < 4 * ns * 3 * nl; i++) {
        int sc = i % (4 * ns);
        int lc = (i - sc) / (4 * ns);
        int s = sc / 4;
        int l = lc / 3;
        if (sc % 4 == lc % 3) {
            L[s + l * ns] += E[i];
        }
    }

    long dimProd = (long)dim[0] * dim[1] * dim[2];
    cout << "Rendering volume V ..." << endl;
    for (long i = 0; i < dimProd; i++) {
        double normalizor = 0;
        V[i] = 0;
        for (int j = 0; j < ns * nl; j++) {
            double gaussian = H[i + dimProd * j];
            V[i] += L[j] * gaussian;
            normalizor += gaussian;
        }
        if (normalizor > 0) {
            V[i] /= normalizor;
        }
    }
}

/* MEX gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Check for proper number of arguments */
    if (nrhs != 5) {
        mexErrMsgIdAndTxt("MATLAB:volumeFromHashing:invalidNumInputs", "Five inputs required.");
    }
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("MATLAB:volumeFromHashing:invalidNumOutputs", "One output required.");
    }

    double *dimInput = mxGetPr(prhs[2]);
    mwSize dim[3];
    dim[0] = (mwSize)dimInput[0];
    dim[1] = (mwSize)dimInput[1];
    dim[2] = (mwSize)dimInput[2];
    
    double *H = mxGetPr(prhs[3]);
    double *E = mxGetPr(prhs[4]);
    
    int ns = (int)mxGetM(prhs[0]);
    int nl = (int)mxGetM(prhs[1]);
    
    /* Set the output pointer to the output matrix */
    plhs[0] = mxCreateNumericArray(3, dim, mxDOUBLE_CLASS, mxREAL);
    double *V = mxGetPr(plhs[0]);
    
    /* Call calculation routine */
    generateVolume(V, dim, H, E, ns, nl);
}
