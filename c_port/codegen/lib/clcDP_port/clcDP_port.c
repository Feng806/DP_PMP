/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: clcDP_port.c
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 21-Jun-2016 17:44:08
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "clcDP_port.h"
#include "clcDP_port_emxutil.h"
#include "fprintf.h"
#include "clcOptTrj_port.h"
#include "clcDP_olyHyb_port.h"
#include <stdio.h>

/* Function Definitions */

/*
 * % assign structure fields to variables
 *  inputparams - originally simulink inputs
 * Arguments    : const struct0_T *inputparams
 *                const struct1_T *testparams
 *                const struct2_T *fahrparams
 *                const struct3_T *tst_array_struct
 *                const struct4_T *fzg_array_struct
 *                emxArray_real_T *engKinOptVec
 *                emxArray_real_T *batEngDltOptVec
 *                emxArray_real_T *fulEngDltOptVec
 *                emxArray_real_T *staVec
 *                emxArray_real_T *psiEngKinOptVec
 *                double *fulEngOpt
 *                boolean_T *resVld
 * Return Type  : void
 */
void clcDP_port(const struct0_T *inputparams, const struct1_T *testparams, const
                struct2_T *fahrparams, const struct3_T *tst_array_struct, const
                struct4_T *fzg_array_struct, emxArray_real_T *engKinOptVec,
                emxArray_real_T *batEngDltOptVec, emxArray_real_T
                *fulEngDltOptVec, emxArray_real_T *staVec, emxArray_real_T
                *psiEngKinOptVec, double *fulEngOpt, boolean_T *resVld)
{
  emxArray_real_T *optPreInxTn3;
  emxArray_real_T *batFrcOptTn3;
  emxArray_real_T *fulEngOptTn3;
  emxArray_real_T *cos2goActMat;
  emxInit_real_T(&optPreInxTn3, 3);
  emxInit_real_T(&batFrcOptTn3, 3);
  emxInit_real_T(&fulEngOptTn3, 3);
  b_emxInit_real_T(&cos2goActMat, 2);

  /*             --- Ausgangsgr��en: */
  /*  Vektor - Trajektorie der optimalen kin. Energien */
  /*  Vektor - optimale Batterieenergie�nderung */
  /*  Vektor - optimale Kraftstoffenergie�nderung */
  /*  Vektor - Trajektorie des optimalen Antriebsstrangzustands */
  /*  Vektor - costate f�r kinetische Energie */
  /*  Skalar - optimale Kraftstoffenergie */
  /*  testparams - originally tstDat800 structure */
  /* % Calculating optimal predecessors with DP + PMP */
  b_fprintf();

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
  
  clcDP_olyHyb_port(inputparams->disFlg, inputparams->wayStp,
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

// print out some outputs
int m;
printf("\n\noptPreInxTn3 dims: %d\n", optPreInxTn3->numDimensions);
for (m = 0; m < optPreInxTn3->numDimensions; m++)
		printf("optPreInxTn3 size[%d]: %d\n", m, optPreInxTn3->size[m]);
printf("optPreInxTn3 allocatedSize: %d\n:", optPreInxTn3->allocatedSize);
printf("optPreInxTn3.canFreeData: %d\n", optPreInxTn3->canFreeData);
//for (m = 0; m < optPreInxTn3->allocatedSize; m++)
//printf("optPreInxTn3 data[%d]: %d\n", m, optPreInxTn3->data[m]);
printf("optPreInxTn3 data[341]: %4.4f\n", optPreInxTn3->data[341]);


printf("\nfulEngOptTn3 dims: %d\n", fulEngOptTn3->numDimensions);
for (m = 0; m < fulEngOptTn3->numDimensions; m++)
		printf("fulEngOptTn3 size[%d]: %d\n", m, fulEngOptTn3->size[m]);
printf("fulEngOptTn3 allocateSize: %d\n", fulEngOptTn3->allocatedSize);
printf("fulEngOptTn3.canFreeData: %d\n", fulEngOptTn3->canFreeData);
printf("fulEngOptTn3 data[341]: %4.4f", fulEngOptTn3->data[341]);

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
  
  
//  clcOptTrj_port(inputparams->wayStp, testparams->wayNum, inputparams->wayInxBeg,
//                 inputparams->wayInxEnd, testparams->engKinNum,
//                 tst_array_struct->engKinNumVec_wayInx,
//                 tst_array_struct->engKinMat_engKinInx_wayInx, optPreInxTn3,
//                 batFrcOptTn3, fulEngOptTn3, cos2goActMat, engKinOptVec,
//                 batEngDltOptVec, fulEngDltOptVec, staVec, psiEngKinOptVec,
//                 fulEngOpt);


  /*  engKinOptVec=0; */
  /*  batEngDltOptVec=0; */
  /*  fulEngDltOptVec=0; */
  /*  staVec=0; */
  /*  psiEngKinOptVec=0; */
  /*  fulEngOpt=0; */
  
//  *resVld = true;
  f_fprintf();
  emxFree_real_T(&cos2goActMat);
  emxFree_real_T(&fulEngOptTn3);
  emxFree_real_T(&batFrcOptTn3);
  emxFree_real_T(&optPreInxTn3);
}

/*
 * File trailer for clcDP_port.c
 *
 * [EOF]
 */
