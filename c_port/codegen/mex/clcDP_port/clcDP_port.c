/*
 * clcDP_port.c
 *
 * Code generation for function 'clcDP_port'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "clcDP_port.h"
#include "clcDP_port_emxutil.h"
#include "fprintf.h"
#include "clcOptTrj_port.h"
#include "clcDP_olyHyb_port.h"
#include <stdio.h>

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 40, "clcDP_port",
  "C:\\Users\\s0032360\\Documents\\GitHub\\DP_PMP\\c_port\\clcDP_port.m" };

static emlrtRSInfo b_emlrtRSI = { 41, "clcDP_port",
  "C:\\Users\\s0032360\\Documents\\GitHub\\DP_PMP\\c_port\\clcDP_port.m" };

static emlrtRSInfo c_emlrtRSI = { 74, "clcDP_port",
  "C:\\Users\\s0032360\\Documents\\GitHub\\DP_PMP\\c_port\\clcDP_port.m" };

static emlrtRSInfo d_emlrtRSI = { 107, "clcDP_port",
  "C:\\Users\\s0032360\\Documents\\GitHub\\DP_PMP\\c_port\\clcDP_port.m" };

static emlrtRTEInfo emlrtRTEI = { 10, 5, "clcDP_port",
  "C:\\Users\\s0032360\\Documents\\GitHub\\DP_PMP\\c_port\\clcDP_port.m" };

static emlrtDCInfo emlrtDCI = { 70, 24, "clcDP_port",
  "C:\\Users\\s0032360\\Documents\\GitHub\\DP_PMP\\c_port\\clcDP_port.m", 1 };

static emlrtBCInfo emlrtBCI = { 1, 800, 70, 24, "engKinNumVec_wayInx",
  "clcDP_port",
  "C:\\Users\\s0032360\\Documents\\GitHub\\DP_PMP\\c_port\\clcDP_port.m", 0 };

/* Function Definitions */
void clcDP_port(const emlrtStack *sp, const struct0_T *inputparams, const
                struct1_T *testparams, const struct2_T *fahrparams, const
                struct3_T *tst_array_struct, const struct4_T *fzg_array_struct,
                emxArray_real_T *engKinOptVec, emxArray_real_T *batEngDltOptVec,
                emxArray_real_T *fulEngDltOptVec, emxArray_real_T *staVec,
                emxArray_real_T *psiEngKinOptVec, real_T *fulEngOpt, boolean_T
                *resVld)
{
  emxArray_real_T *optPreInxTn3;
  emxArray_real_T *batFrcOptTn3;
  emxArray_real_T *fulEngOptTn3;
  emxArray_real_T *cos2goActMat;
  real_T d0;
  int32_T i0;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T(sp, &optPreInxTn3, 3, &emlrtRTEI, true);
  emxInit_real_T(sp, &batFrcOptTn3, 3, &emlrtRTEI, true);
  emxInit_real_T(sp, &fulEngOptTn3, 3, &emlrtRTEI, true);
  b_emxInit_real_T(sp, &cos2goActMat, 2, &emlrtRTEI, true);

  /*             --- Ausgangsgr��en: */
  /*  Vektor - Trajektorie der optimalen kin. Energien */
  /*  Vektor - optimale Batterieenergie�nderung */
  /*  Vektor - optimale Kraftstoffenergie�nderung */
  /*  Vektor - Trajektorie des optimalen Antriebsstrangzustands */
  /*  Vektor - costate f�r kinetische Energie */
  /*  Skalar - optimale Kraftstoffenergie */
  /* % assign structure fields to variables */
  /*  inputparams - originally simulink inputs */
  /*  testparams - originally tstDat800 structure */
  /* % Calculating optimal predecessors with DP + PMP */
  st.site = &emlrtRSI;
  b_fprintf(&st);

  /*  --- Ausgangsgr��en: */
  /*   Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten */
  /*   Tensor 3. Stufe der Batteriekraft */
  /*   Tensor 3. Stufe f�r die Kraftstoffenergie */
  /*   Matrix der optimalen Kosten der Hamiltonfunktion */
  /*  FUNKTION */
  /*  --- Eingangsgr��en: */
  /*  Skalar - Flag f�r Ausgabe in das Commandwindow */
  /*  Skalar f�r die Wegschrittweite in m */
  /*  Skalar der Batteriediskretisierung in J */
  /*  Skalar f�r die Batterieenergie am Beginn in Ws */
  /*  Skalar f�r die Nebenverbrauchlast in W */
  /*  Skalar f�r den Co-State der Batterieenergie */
  /*  Skalar f�r den Co-State der Zeit */
  /*  Skalar f�r die Strafkosten beim Zustandswechsel */
  /*  Skalar f�r Anfangsindex in den Eingangsdaten */
  /*  Skalar f�r Endindex in den Eingangsdaten */
  /*  Skalar f�r den Index der Anfangsgeschwindigkeit */
  /*  Skalar f�r die max. Anz. an engKin-St�tzstellen */
  /*  Skalar f�r die max. Anzahl an Zustandsst�tzstellen */
  /*  Skalar f�r die max. Anzahl an Wegst�tzstellen */
  /*  Skalar f�r den Startzustand des Antriebsstrangs */
  /*  Vektor der Anzahl der kinetischen Energien */
  /*  Vektor der Steigungen in rad */
  /*  Matrix der kinetischen Energien in J */
  /*  struct der Fahrzeugparameter - NUR SKALARS */
  /*  struct der Fahrzeugparameter - NUR ARRAYS */
  st.site = &b_emlrtRSI;
  clcDP_olyHyb_port(&st, inputparams->disFlg, inputparams->wayStp,
                    inputparams->batEngStp, inputparams->batEngBeg,
                    inputparams->batPwrAux, inputparams->psiBatEng,
                    inputparams->psiTim, inputparams->staChgPenCosVal,
                    inputparams->wayInxBeg, inputparams->wayInxEnd,
                    inputparams->engKinBegInx, testparams->engKinNum,
                    testparams->staNum, testparams->wayNum, inputparams->staBeg,
                    tst_array_struct->engKinNumVec_wayInx,
                    tst_array_struct->slpVec_wayInx,
                    tst_array_struct->engKinMat_engKinInx_wayInx, fahrparams,
                    fzg_array_struct, optPreInxTn3, batFrcOptTn3, fulEngOptTn3,
                    cos2goActMat);
  d0 = inputparams->wayInxEnd;
  i0 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &emlrtDCI, sp);
  emlrtDynamicBoundsCheckFastR2012b(i0, 1, 800, &emlrtBCI, sp);

  /* % Calculating optimal trajectories for result of DP + PMP */
  /*  Vektor - Trajektorie der optimalen kin. Energien */
  /*  Vektor - optimale Batterieenergie�nderung */
  /*  Vektor - optimale Kraftstoffenergie�nderung */
  /*  Vektor - Trajektorie des optimalen Antriebsstrangzustands */
  /*  Vektor - costate f�r kinetische Energie */
  /*  Skalar - optimale Kraftstoffenergie */
  /*  FUNKTION */
  /*  Flag, ob Zielzustand genutzt werden muss */
  /*  Skalar f�r die Wegschrittweite in m */
  /*  Skalar f�r die max. Anzahl an Wegst�tzstellen */
  /*  Skalar f�r Anfangsindex in den Eingangsdaten */
  /*  Skalar f�r Endindex in den Eingangsdaten */
  /*  Skalar f�r den finalen Zustand */
  /*  Skalar f�r die max. Anz. an engKin-St�tzstellen */
  /*  Skalar f�r Zielindex der kinetischen Energie */
  /*  Skalar f�r die max. Anzahl an Zustandsst�tzstellen */
  /*  Vektor der Anzahl der kinetischen Energien */
  /*  Matrix der kinetischen Energien in J */
  /*  Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten */
  /*  Tensor 3. Stufe der Batteriekraft */
  /*  Tensor 3. Stufe f�r die Kraftstoffenergie */
  /*  Matrix der optimalen Kosten der Hamiltonfunktion */
  st.site = &c_emlrtRSI;
  clcOptTrj_port(&st, inputparams->wayStp, testparams->wayNum,
                 inputparams->wayInxBeg, inputparams->wayInxEnd,
                 testparams->engKinNum, testparams->staNum,
                 tst_array_struct->engKinNumVec_wayInx,
                 tst_array_struct->engKinMat_engKinInx_wayInx, optPreInxTn3,
                 batFrcOptTn3, fulEngOptTn3, cos2goActMat, engKinOptVec,
                 batEngDltOptVec, fulEngDltOptVec, staVec, psiEngKinOptVec,
                 fulEngOpt);

  /*  engKinOptVec=0; */
  /*  batEngDltOptVec=0; */
  /*  fulEngDltOptVec=0; */
  /*  staVec=0; */
  /*  psiEngKinOptVec=0; */
  /*  fulEngOpt=0; */
  *resVld = true;
  st.site = &d_emlrtRSI;
  f_fprintf(&st);
  emxFree_real_T(&cos2goActMat);
  emxFree_real_T(&fulEngOptTn3);
  emxFree_real_T(&batFrcOptTn3);
  emxFree_real_T(&optPreInxTn3);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (clcDP_port.c) */
