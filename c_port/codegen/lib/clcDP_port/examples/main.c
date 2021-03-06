/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 21-Jun-2016 17:44:08
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/
/* Include Files */
#include "rt_nonfinite.h"
#include "clcDP_port.h"
#include "main.h"
#include "clcDP_port_terminate.h"
#include "clcDP_port_emxAPI.h"
#include "clcDP_port_initialize.h"
#include <stdio.h>

/* Function Declarations */
static void argInit_100x1_real_T(double result[100]);
static void argInit_11x800_real_T(double result[8800]);
static void argInit_150x100_real_T(double result[15000]);
static void argInit_1x2_real_T(double result[2]);
static void argInit_1x3_real_T(double result[3]);
static void argInit_1x6_real_T(double result[6]);
static void argInit_800x1_real_T(double result[800]);
static double argInit_real_T(void);
static void argInit_struct0_T(struct0_T *result);
static struct1_T argInit_struct1_T(void);
static void argInit_struct2_T(struct2_T *result);
static void argInit_struct3_T(struct3_T *result);
static void argInit_struct4_T(struct4_T *result);
static void main_clcDP_port(void);

/* Function Definitions */

/*
 * Arguments    : double result[100]
 * Return Type  : void
 */
static void argInit_100x1_real_T(double result[100])
{
  int b_j0;

  /* Loop over the array to initialize each element. */
  for (b_j0 = 0; b_j0 < 100; b_j0++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[b_j0] = argInit_real_T();
  }
}

/*
 * Arguments    : double result[8800]
 * Return Type  : void
 */
static void argInit_11x800_real_T(double result[8800])
{
  int b_j0;
  int b_j1;

  /* Loop over the array to initialize each element. */
  for (b_j0 = 0; b_j0 < 11; b_j0++) {
    for (b_j1 = 0; b_j1 < 800; b_j1++) {
      /* Set the value of the array element.
         Change this value to the value that the application requires. */
      result[b_j0 + 11 * b_j1] = argInit_real_T();
    }
  }
}

/*
 * Arguments    : double result[15000]
 * Return Type  : void
 */
static void argInit_150x100_real_T(double result[15000])
{
  int b_j0;
  int b_j1;

  /* Loop over the array to initialize each element. */
  for (b_j0 = 0; b_j0 < 150; b_j0++) {
    for (b_j1 = 0; b_j1 < 100; b_j1++) {
      /* Set the value of the array element.
         Change this value to the value that the application requires. */
      result[b_j0 + 150 * b_j1] = argInit_real_T();
    }
  }
}

/*
 * Arguments    : double result[2]
 * Return Type  : void
 */
static void argInit_1x2_real_T(double result[2])
{
  int b_j1;

  /* Loop over the array to initialize each element. */
  for (b_j1 = 0; b_j1 < 2; b_j1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[b_j1] = argInit_real_T();
  }
}

/*
 * Arguments    : double result[3]
 * Return Type  : void
 */
static void argInit_1x3_real_T(double result[3])
{
  int b_j1;

  /* Loop over the array to initialize each element. */
  for (b_j1 = 0; b_j1 < 3; b_j1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[b_j1] = argInit_real_T();
  }
}

/*
 * Arguments    : double result[6]
 * Return Type  : void
 */
static void argInit_1x6_real_T(double result[6])
{
  int b_j1;

  /* Loop over the array to initialize each element. */
  for (b_j1 = 0; b_j1 < 6; b_j1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[b_j1] = argInit_real_T();
  }
}

/*
 * Arguments    : double result[800]
 * Return Type  : void
 */
static void argInit_800x1_real_T(double result[800])
{
  int b_j0;

  /* Loop over the array to initialize each element. */
  for (b_j0 = 0; b_j0 < 800; b_j0++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[b_j0] = argInit_real_T();
  }
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T(void)
{
  return 0.0;
}

/*
 * Arguments    : struct0_T *result
 * Return Type  : void
 */
static void argInit_struct0_T(struct0_T *result)
{
  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result->disFlg = argInit_real_T();
  result->wayStp = argInit_real_T();
  result->engKinBegInx = argInit_real_T();
  result->batEngStp = argInit_real_T();
  result->batEngBeg = argInit_real_T();
  result->batPwrAux = argInit_real_T();
  result->psiBatEng = argInit_real_T();
  result->psiTim = argInit_real_T();
  result->staChgPenCosVal = argInit_real_T();
  result->wayInxBeg = argInit_real_T();
  result->wayInxEnd = argInit_real_T();
  result->staBeg = argInit_real_T();
}

/*
 * Arguments    : void
 * Return Type  : struct1_T
 */
static struct1_T argInit_struct1_T(void)
{
  struct1_T result;

  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result.staNum = argInit_real_T();
  result.wayNum = argInit_real_T();
  result.engKinNum = argInit_real_T();
  return result;
}

/*
 * Arguments    : struct2_T *result
 * Return Type  : void
 */
static void argInit_struct2_T(struct2_T *result)
{
  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result->vehVelMin = argInit_real_T();
  result->vehVelMax = argInit_real_T();
  result->vehAccMax = argInit_real_T();
  result->vehAccMin = argInit_real_T();
  result->drgCof = argInit_real_T();
  result->vehMas = argInit_real_T();
  result->whlRosResCof = argInit_real_T();
  result->whlDrr = argInit_real_T();
  result->batRstChr = argInit_real_T();
  result->batRstDch = argInit_real_T();
  result->batEngMax = argInit_real_T();
  result->batPwrMax = argInit_real_T();
  result->batPwrMin = argInit_real_T();
  result->geaEfy = argInit_real_T();
  result->fulDen = argInit_real_T();
  result->fulLhv = argInit_real_T();
}

/*
 * Arguments    : struct3_T *result
 * Return Type  : void
 */
static void argInit_struct3_T(struct3_T *result)
{
  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  argInit_800x1_real_T(result->slpVec_wayInx);
  argInit_11x800_real_T(result->engKinMat_engKinInx_wayInx);
  argInit_800x1_real_T(result->engKinNumVec_wayInx);
}

/*
 * Arguments    : struct4_T *result
 * Return Type  : void
 */
static void argInit_struct4_T(struct4_T *result)
{
  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  argInit_1x2_real_T(result->batOcvCof_batEng);
  argInit_1x6_real_T(result->geaRat);
  argInit_150x100_real_T(result->iceSpdMgd);
  argInit_150x100_real_T(result->iceTrqMgd);
  argInit_150x100_real_T(result->iceFulPwr_iceSpd_iceTrq);
  argInit_1x3_real_T(result->iceTrqMaxCof);
  argInit_1x3_real_T(result->iceTrqMinCof);
  argInit_150x100_real_T(result->emoSpdMgd);
  argInit_150x100_real_T(result->emoTrqMgd);
  argInit_150x100_real_T(result->emoPwr_emoSpd_emoTrq);
  argInit_100x1_real_T(result->emoTrqMin_emoSpd);
  argInit_100x1_real_T(result->emoTrqMax_emoSpd);
  argInit_150x100_real_T(result->emoPwrMgd);
  argInit_150x100_real_T(result->emoTrq_emoSpd_emoPwr);
  argInit_100x1_real_T(result->emoPwrMax_emoSpd);
  argInit_100x1_real_T(result->emoPwrMin_emoSpd);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_clcDP_port(void)
{
  emxArray_real_T *engKinOptVec;
  emxArray_real_T *batEngDltOptVec;
  emxArray_real_T *fulEngDltOptVec;
  emxArray_real_T *staVec;
  emxArray_real_T *psiEngKinOptVec;
  struct0_T r1;
  struct2_T r2;
  struct3_T r3;
  static struct4_T r4;
  struct1_T r5;
  boolean_T resVld;
  double fulEngOpt;
  emxInitArray_real_T(&engKinOptVec, 1);
  emxInitArray_real_T(&batEngDltOptVec, 1);
  emxInitArray_real_T(&fulEngDltOptVec, 1);
  emxInitArray_real_T(&staVec, 1);
  emxInitArray_real_T(&psiEngKinOptVec, 1);

  /* Initialize function 'clcDP_port' input arguments. */
  /* Initialize function input argument 'inputparams'. */
  /* Initialize function input argument 'testparams'. */
  /* Initialize function input argument 'fahrparams'. */
  /* Initialize function input argument 'tst_array_struct'. */
  /* Initialize function input argument 'fzg_array_struct'. */
  /* Call the entry-point 'clcDP_port'. */
  argInit_struct0_T(&r1);
  argInit_struct2_T(&r2);
  argInit_struct3_T(&r3);
  argInit_struct4_T(&r4);
  r5 = argInit_struct1_T();
  clcDP_port(&r1, &r5, &r2, &r3, &r4, engKinOptVec, batEngDltOptVec,
             fulEngDltOptVec, staVec, psiEngKinOptVec, &fulEngOpt, &resVld);
  emxDestroyArray_real_T(psiEngKinOptVec);
  emxDestroyArray_real_T(staVec);
  emxDestroyArray_real_T(fulEngDltOptVec);
  emxDestroyArray_real_T(batEngDltOptVec);
  emxDestroyArray_real_T(engKinOptVec);
}

/*
 * Arguments    : int argc
 *                const char * const argv[]
 * Return Type  : int
 */
int main(int argc, const char * const argv[])
{
  (void)argc;
  (void)argv;

  /* Initialize the application.
     You do not need to do this more than one time. */
  clcDP_port_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_clcDP_port();

  /* Terminate the application.
     You do not need to do this more than one time. */
  clcDP_port_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
