/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * diff.h
 *
 * Code generation for function 'diff'
 *
 */

#ifndef __DIFF_H__
#define __DIFF_H__

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
#include "clcOptTrj_tmp_types.h"

/* Function Declarations */
extern void diff(const emlrtStack *sp, const emxArray_real_T *x, emxArray_real_T
                 *y);

#endif

/* End of code generation (diff.h) */
