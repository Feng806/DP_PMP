/*
 * clcDP_focus_useGeaVec_terminate.c
 *
 * Code generation for function 'clcDP_focus_useGeaVec_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "clcDP_focus_useGeaVec.h"
#include "clcDP_focus_useGeaVec_terminate.h"
#include <stdio.h>

/* Function Definitions */
void clcDP_focus_useGeaVec_atexit(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void clcDP_focus_useGeaVec_terminate(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (clcDP_focus_useGeaVec_terminate.c) */