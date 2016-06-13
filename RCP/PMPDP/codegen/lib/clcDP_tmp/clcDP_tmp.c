/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: clcDP_tmp.c
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 13-Jun-2016 11:59:29
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "clcDP_tmp.h"
#include "clcDP_tmp_emxutil.h"
#include "fprintf.h"
#include "clcOptTrj_tmp.h"
#include "clcDP_olyHyb_tmp.h"
#include <stdio.h>

/* Function Definitions */

/*
 * --- Eingangsgr��en:
 *          Skalar - Flag f�r Ausgabe in das Commandwindow
 *           Skalar f�r die Wegschrittweite in m
 *        Skalar der Batteriediskretisierung in J
 *        Skalar f�r die Batterieenergie am Beginn in Ws
 *        Skalar f�r die Nebenverbrauchlast in W
 *        Skalar f�r den Co-State der Batterieenergie
 *           Skalar f�r den Co-State der Zeit
 *  Skalar f�r die Strafkosten beim Zustandswechsel
 *        Skalar f�r Anfangsindex in den Eingangsdaten
 *        Skalar f�r Endindex in den Eingangsdaten
 *        Skalar f�r die max. Anz. an engKin-St�tzstellen
 *           Skalar f�r die max. Anzahl an Zustandsst�tzstellen
 *           Skalar f�r die max. Anzahl an Wegst�tzstellen
 *           Skalar f�r den Startzustand des Antriebsstrangs
 *  Vektor der Anzahl der kinetischen Energien
 *    Vektor der Steigungen in rad
 *  Matrix der kinetischen Energien in J%#codegen
 * Arguments    : double disFlg
 *                double wayStp
 *                double batEngStp
 *                double batEngBeg
 *                double batPwrAux
 *                double psiBatEng
 *                double psiTim
 *                double staChgPenCosVal
 *                double wayInxBeg
 *                double wayInxEnd
 *                double engKinNum
 *                double staNum
 *                double wayNum
 *                double staBeg
 *                const double engKinNumVec_wayInx[800]
 *                const double slpVec_wayInx[800]
 *                const double engKinMat_engKinInx_wayInx[8800]
 *                const struct0_T *FZG
 *                emxArray_real_T *engKinOptVec
 *                emxArray_real_T *batEngDltOptVec
 *                emxArray_real_T *fulEngDltOptVec
 *                emxArray_real_T *staVec
 *                emxArray_real_T *psiEngKinOptVec
 *                double *fulEngOpt
 *                boolean_T *resVld
 * Return Type  : void
 */
void clcDP_tmp(double disFlg, double wayStp, double batEngStp, double batEngBeg,
               double batPwrAux, double psiBatEng, double psiTim, double
               staChgPenCosVal, double wayInxBeg, double wayInxEnd, double
               engKinNum, double staNum, double wayNum, double staBeg, const
               double engKinNumVec_wayInx[800], const double slpVec_wayInx[800],
               const double engKinMat_engKinInx_wayInx[8800], const struct0_T
               *FZG, emxArray_real_T *engKinOptVec, emxArray_real_T
               *batEngDltOptVec, emxArray_real_T *fulEngDltOptVec,
               emxArray_real_T *staVec, emxArray_real_T *psiEngKinOptVec, double
               *fulEngOpt, boolean_T *resVld)
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
  /*        Vektor - Trajektorie der optimalen kin. Energien */
  /* Vektor - optimale Batterieenergie�nderung */
  /*  Vektor - optimale Kraftstoffenergie�nderung */
  /*           Vektor - Trajektorie des optimalen Antriebsstrangzustands */
  /*  Vektor - costate f�r kinetische Energie */
  /*       Skalar - optimale Kraftstoffenergie */
  /* % Calculating optimal predecessors with DP + PMP */
  b_fprintf();

  /*  --- Ausgangsgr��en: */
  /*    Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten */
  /*    Tensor 3. Stufe der Batteriekraft */
  /*    Tensor 3. Stufe f�r die Kraftstoffenergie */
  /*     Matrix der optimalen Kosten der Hamiltonfunktion */
  /*      FUNKTION */
  /*                --- Eingangsgr��en: */
  /*          Skalar - Flag f�r Ausgabe in das Commandwindow */
  /*           Skalar f�r die Wegschrittweite in m */
  /*        Skalar der Batteriediskretisierung in J */
  /*        Skalar f�r die Batterieenergie am Beginn in Ws */
  /*        Skalar f�r die Nebenverbrauchlast in W */
  /*        Skalar f�r den Co-State der Batterieenergie */
  /*           Skalar f�r den Co-State der Zeit */
  /*  Skalar f�r die Strafkosten beim Zustandswechsel */
  /*        Skalar f�r Anfangsindex in den Eingangsdaten */
  /*        Skalar f�r Endindex in den Eingangsdaten */
  /*                Skalar f�r den Index der Anfangsgeschwindigkeit */
  /*        Skalar f�r die max. Anz. an engKin-St�tzstellen */
  /*           Skalar f�r die max. Anzahl an Zustandsst�tzstellen */
  /*           Skalar f�r die max. Anzahl an Wegst�tzstellen */
  /*           Skalar f�r den Startzustand des Antriebsstrangs */
  /*  Vektor der Anzahl der kinetischen Energien */
  /*    Vektor der Steigungen in rad */
  /*  Matrix der kinetischen Energien in J */
  /*               struct der Fahrzeugparameter */
  clcDP_olyHyb_tmp(disFlg, wayStp, batEngStp, batEngBeg, batPwrAux, psiBatEng,
                   psiTim, staChgPenCosVal, wayInxBeg, wayInxEnd, engKinNum,
                   staNum, wayNum, staBeg, engKinNumVec_wayInx, slpVec_wayInx,
                   engKinMat_engKinInx_wayInx, FZG, optPreInxTn3, batFrcOptTn3,
                   fulEngOptTn3, cos2goActMat);

  /* % Calculating optimal trajectories for result of DP + PMP */
  /*        Vektor - Trajektorie der optimalen kin. Energien */
  /* Vektor - optimale Batterieenergie�nderung */
  /*  Vektor - optimale Kraftstoffenergie�nderung */
  /*           Vektor - Trajektorie des optimalen Antriebsstrangzustands */
  /*  Vektor - costate f�r kinetische Energie */
  /*        Skalar - optimale Kraftstoffenergie */
  /*         FUNKTION */
  /*           Flag, ob Zielzustand genutzt werden muss */
  /*           Skalar f�r die Wegschrittweite in m */
  /*           Skalar f�r die max. Anzahl an Wegst�tzstellen */
  /*        Skalar f�r Anfangsindex in den Eingangsdaten */
  /*        Skalar f�r Endindex in den Eingangsdaten */
  /*           Skalar f�r den finalen Zustand */
  /*        Skalar f�r die max. Anz. an engKin-St�tzstellen */
  /*  Skalar f�r Zielindex der kinetischen Energie */
  /*           Skalar f�r die max. Anzahl an Zustandsst�tzstellen */
  /*  Vektor der Anzahl der kinetischen Energien */
  /*  Matrix der kinetischen Energien in J */
  /*     Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten */
  /*    Tensor 3. Stufe der Batteriekraft */
  /*    Tensor 3. Stufe f�r die Kraftstoffenergie */
  /*     Matrix der optimalen Kosten der Hamiltonfunktion */
  clcOptTrj_tmp(wayStp, wayNum, wayInxBeg, wayInxEnd, engKinNum,
                engKinNumVec_wayInx, engKinMat_engKinInx_wayInx, optPreInxTn3,
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
  f_fprintf();
  emxFree_real_T(&cos2goActMat);
  emxFree_real_T(&fulEngOptTn3);
  emxFree_real_T(&batFrcOptTn3);
  emxFree_real_T(&optPreInxTn3);
}

/*
 * File trailer for clcDP_tmp.c
 *
 * [EOF]
 */
