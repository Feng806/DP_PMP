/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_clcDP_tmp_mex.c
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 13-Jun-2016 11:59:29
 */

/* Include Files */
#include "_coder_clcDP_tmp_api.h"
#include "_coder_clcDP_tmp_mex.h"
#include <stdio.h>

/* Function Declarations */
static void clcDP_tmp_mexFunction(int32_T nlhs, mxArray *plhs[7], int32_T nrhs,
  const mxArray *prhs[18]);

/* Function Definitions */

/*
 * Arguments    : int32_T nlhs
 *                const mxArray *plhs[7]
 *                int32_T nrhs
 *                const mxArray *prhs[18]
 * Return Type  : void
 */
static void clcDP_tmp_mexFunction(int32_T nlhs, mxArray *plhs[7], int32_T nrhs,
  const mxArray *prhs[18])
{
  int32_T n;
  const mxArray *inputs[18];
  const mxArray *outputs[7];
  int32_T b_nlhs;
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 18) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 18, 4,
                        9, "clcDP_tmp");
  }

  if (nlhs > 7) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 9,
                        "clcDP_tmp");
  }

  /* Temporary copy for mex inputs. */
  for (n = 0; n < nrhs; n++) {
    inputs[n] = prhs[n];
  }

  /* Call the function. */
  clcDP_tmp_api(inputs, outputs);

  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }

  emlrtReturnArrays(b_nlhs, plhs, outputs);

  /* Module termination. */
  clcDP_tmp_terminate();
}

/*
 * Arguments    : int32_T nlhs
 *                const mxArray * const plhs[]
 *                int32_T nrhs
 *                const mxArray * const prhs[]
 * Return Type  : void
 */
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  /* Initialize the memory manager. */
  mexAtExit(clcDP_tmp_atexit);

  /* Module initialization. */
  clcDP_tmp_initialize();

  /* Dispatch the entry-point. */
  clcDP_tmp_mexFunction(nlhs, plhs, nrhs, prhs);
}

/*
 * File trailer for _coder_clcDP_tmp_mex.c
 *
 * [EOF]
 */
