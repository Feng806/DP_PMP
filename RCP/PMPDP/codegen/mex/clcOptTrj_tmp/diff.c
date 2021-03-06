/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * diff.c
 *
 * Code generation for function 'diff'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "clcOptTrj_tmp.h"
#include "diff.h"
#include "eml_int_forloop_overflow_check.h"
#include "clcOptTrj_tmp_emxutil.h"
#include "clcOptTrj_tmp_data.h"

/* Variable Definitions */
static emlrtRSInfo n_emlrtRSI = { 106, "diff",
  "C:\\Program Files\\MATLAB\\R2015a\\toolbox\\eml\\lib\\matlab\\datafun\\diff.m"
};

static emlrtRTEInfo c_emlrtRTEI = { 1, 14, "diff",
  "C:\\Program Files\\MATLAB\\R2015a\\toolbox\\eml\\lib\\matlab\\datafun\\diff.m"
};

static emlrtRTEInfo i_emlrtRTEI = { 51, 19, "diff",
  "C:\\Program Files\\MATLAB\\R2015a\\toolbox\\eml\\lib\\matlab\\datafun\\diff.m"
};

/* Function Definitions */
void diff(const emlrtStack *sp, const emxArray_real_T *x, emxArray_real_T *y)
{
  int32_T ixLead;
  boolean_T overflow;
  int32_T iyLead;
  real_T work_data_idx_0;
  int32_T m;
  real_T tmp1;
  real_T tmp2;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (x->size[0] == 0) {
    ixLead = y->size[0];
    y->size[0] = 0;
    emxEnsureCapacity(sp, (emxArray__common *)y, ixLead, (int32_T)sizeof(real_T),
                      &c_emlrtRTEI);
  } else {
    ixLead = x->size[0] - 1;
    if (muIntScalarMin_sint32(ixLead, 1) < 1) {
      ixLead = y->size[0];
      y->size[0] = 0;
      emxEnsureCapacity(sp, (emxArray__common *)y, ixLead, (int32_T)sizeof
                        (real_T), &c_emlrtRTEI);
    } else {
      overflow = (x->size[0] != 1);
      if (overflow) {
      } else {
        emlrtErrorWithMessageIdR2012b(sp, &i_emlrtRTEI,
          "Coder:toolbox:autoDimIncompatibility", 0);
      }

      ixLead = y->size[0];
      y->size[0] = x->size[0] - 1;
      emxEnsureCapacity(sp, (emxArray__common *)y, ixLead, (int32_T)sizeof
                        (real_T), &c_emlrtRTEI);
      ixLead = x->size[0] - 1;
      if (!(ixLead == 0)) {
        ixLead = 1;
        iyLead = 0;
        work_data_idx_0 = x->data[0];
        st.site = &n_emlrtRSI;
        if (2 > x->size[0]) {
          overflow = false;
        } else {
          overflow = (x->size[0] > 2147483646);
        }

        if (overflow) {
          b_st.site = &l_emlrtRSI;
          check_forloop_overflow_error(&b_st);
        }

        for (m = 2; m <= x->size[0]; m++) {
          tmp1 = x->data[ixLead];
          tmp2 = work_data_idx_0;
          work_data_idx_0 = tmp1;
          tmp1 -= tmp2;
          ixLead++;
          y->data[iyLead] = tmp1;
          iyLead++;
        }
      }
    }
  }
}

/* End of code generation (diff.c) */
