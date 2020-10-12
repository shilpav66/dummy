/* Formatted on 2012-07-13 13:43:51 (QP5 v5.163.1008.3004) test*/
REM*************************************************************
REM12345678901234567890123456789012345678901234567890123456789012345678901234567890
REM AGREEMENT  : F4910001, CREATE CONSIGNMENT
REM SOURCE     : GPS
REM DESTINATION: CNS
REM OBJECT     : CSM
REM DESCRIPTION: SEND OF TABLE CONSIGNMENT_%
REM MADE BY    : ULF MATTSSON PURCHASING IT
REM CREATED    : 010503
REM IDRS FLOW  : \TOS\3_0\OBJECTS\CSM\DOCUMENTATION\CsmSpec.doc
REM CHANGED
REM WHO      WHEN      WHAT
REM -----    -------   ------------------------------------------
REM

REM IDR300   SELECTION TABLE NAME MISSING FOR DEST TABLE PUR
REM MAFZ            081006        del. blank line changed to REM due to 10g migration
REM BISV            090123        added select of LD_SEQNO
REM ANJOA2          140825        added ORD_NO_ISOM, ORDL_NO_ISOM and I table names IKEA00314758
REM MANKM1					161125				added PM_CODE for CSM line and changed I-tables also
REM*************************************************************
WHENEVER SQLERROR EXIT SQL.SQLCODE

UPDATE run_idrs
   SET fix_date = SYSDATE
 WHERE idrs_name = 'F4910001'
/

UPDATE consignment_t
   SET SEND_MARK_CNS_CRE = 'Y'
 WHERE (BU_CODE_CRE_CSM, BU_TYPE_CRE_CSM, CSM_NO) IN
          (SELECT BU_CODE_CRE, BU_TYPE_CRE, CSM_NO
             FROM RUN_IDRS_T, F4910001_V
            WHERE     F4910001_V.UPD_DATE > RUN_IDRS_T.RUN_DATE - 0.5
                  AND RUN_IDRS_T.IDRS_NAME = 'F4910001'
                  AND F4910001_V.SEND_MARK_CNS_CRE IS NULL)
/

SELECT RECORD_TYPE,
       TRANS_DATE,
       BU_CODE_CRE,
       BU_TYPE_CRE,
       CSM_NO,
       BU_CODE_CNOR,
       BU_TYPE_CNOR,
       BUA_NO_CNOR,
       BU_CODE_PUP,
       BU_TYPE_PUP,
       BUA_NO_PUP,
       BU_CODE_CNEE,
       BU_TYPE_CNEE,
       BUA_NO_CNEE,
       TOD_CODE,
       TOD_TXT_PLACE,
       MOT_CODE,
       IFTMBF_DATE,
       DSP_DAY_PLAN,
       TRPT_WEI_ORD,
       TRPT_VOL_ORD,
       LOAD_METER_ORD,
       LU_ID_REF,
       F4910001_V.SRC_NAME_INS,
       PACK_NOF_CSM,
       CP_FLAG,
       BU_CODE_TSO,
       BU_TYPE_TSO,
       NOTI_SEQNO,
       CRE_DAY_CSM,
       LUT_CODE_REQ,
       ARR_DATE_REQ,
       LD_SEQNO,
       PROP_CRE_SYSTEM,
       CSM_VOL_NET,
       CSM_WEI_NET,
       CSM_VOL_GRO,
       CSM_WEI_GRO,
       UOM_CODE_WEI,
       UOM_CODE_VOL,
       CSM_VOL_PAL,
       CSM_WEI_PAL
  FROM F4910001_V, RUN_IDRS_T
 WHERE     F4910001_V.UPD_DATE > RUN_IDRS_T.RUN_DATE - 0.5
       AND RUN_IDRS_T.IDRS_NAME = 'F4910001'
       AND F4910001_V.SEND_MARK_CNS_CRE = 'Y'
/* SUPPLIER = PUR                */
/* TABLE =  I_4910061            */
/

SELECT RECORD_TYPE,
       TRANS_DATE,
       BU_CODE_CRE_CSM,
       BU_TYPE_CRE_CSM,
       CSM_NO,
       CSML_NO,
       ITEM_ID,
       ITEM_TYPE,
       ITEM_QTY_DSP,
       BU_CODE_CRE_ORD,
       BU_TYPE_CRE_ORD,
       ORD_NO,
       ORDL_NO,
       PUA_NO,
       PUA_VER_NO,
       CREATE_DATE_ORD,
       BU_CODE_RCV,
       BU_TYPE_RCV,
       SEQ_NO_ORD,
       SRC_NAME_ORD,
       STO_NO_DDC,
       ORD_NO_DDC,
       ORD_NO_COS,
       ORD_TYPE,
       SRC_NAME_INS,
       ORD_TYPE_ITS,
       CSML_VOL_NET,
       CSML_WEI_NET,
       CSML_VOL_GRO,
       CSML_WEI_GRO,
       UOM_CODE_WEI,
       UOM_CODE_VOL,
       PROD_DATE,
       HM_FLAG,
       CSML_WEI_PAL,
       CSML_VOL_PAL,
       ORD_NO_ISOM,
       ORDL_NO_ISOM,
       PM_CODE
  FROM F4910002_V
 WHERE (BU_CODE_CRE_CSM, BU_TYPE_CRE_CSM, CSM_NO) IN
          (SELECT BU_CODE_CRE, BU_TYPE_CRE, CSM_NO
             FROM RUN_IDRS_T, F4910001_V
            WHERE     F4910001_V.UPD_DATE > RUN_IDRS_T.RUN_DATE - 0.5
                  AND RUN_IDRS_T.IDRS_NAME = 'F4910001'
                  AND F4910001_V.SEND_MARK_CNS_CRE = 'Y')
/* SUPPLIER = PUR                */
/* TABLE =  I_4910062            */
/

SELECT RECORD_TYPE,
       TRANS_DATE,
       BU_CODE_CRE,
       BU_TYPE_CRE,
       CSM_NO,
       MSG_ID_CSM,
       MSG_TXT_CSM,
       SRC_NAME_INS
  FROM F4910003_V
 WHERE (BU_CODE_CRE, BU_TYPE_CRE, CSM_NO) IN
          (SELECT BU_CODE_CRE, BU_TYPE_CRE, CSM_NO
             FROM RUN_IDRS_T, F4910001_V
            WHERE     F4910001_V.UPD_DATE > RUN_IDRS_T.RUN_DATE - 0.5
                  AND RUN_IDRS_T.IDRS_NAME = 'F4910001'
                  AND F4910001_V.SEND_MARK_CNS_CRE = 'Y')
/* SUPPLIER = PUR                */
/* TABLE =  I_4910063            */
/* DEST = F3CNS             */
/* TIMESTAMP */
/

UPDATE consignment_t
   SET SEND_DATE_CNS_CRE = SYSDATE, SEND_MARK_CNS_CRE = NULL
 WHERE (BU_CODE_CRE_CSM, BU_TYPE_CRE_CSM, CSM_NO) IN
          (SELECT BU_CODE_CRE, BU_TYPE_CRE, CSM_NO
             FROM RUN_IDRS_T, F4910001_V
            WHERE     F4910001_V.UPD_DATE > RUN_IDRS_T.RUN_DATE - 0.5
                  AND RUN_IDRS_T.IDRS_NAME = 'F4910001'
                  AND F4910001_V.SEND_MARK_CNS_CRE = 'Y')
/

UPDATE run_idrs
   SET run_date = fix_date, run_date_prev = run_date
 WHERE idrs_name = 'F4910001'
/
