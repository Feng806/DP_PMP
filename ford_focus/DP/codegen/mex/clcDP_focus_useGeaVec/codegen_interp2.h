/*
 * codegen_interp2.h
 *
 * Code generation for function 'codegen_interp2'
 *
 */

#ifndef __CODEGEN_INTERP2_H__
#define __CODEGEN_INTERP2_H__

/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "mwmathutil.h"
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blas.h"
#include "rtwtypes.h"
#include "clcDP_focus_useGeaVec_types.h"

/* Function Declarations */
extern real_T codegen_interp2(const emlrtStack *sp, const real_T X[73], const
  real_T Y[66], const emxArray_real_T *Z, real_T xi, real_T yi);

#ifdef __WATCOMC__

#pragma aux codegen_interp2 value [8087];

#endif
#endif

/* End of code generation (codegen_interp2.h) */
