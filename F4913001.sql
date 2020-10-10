/* Formatted on 2012-09-07 07:13:26 (QP5 v5.163.1008.3004) */
REM*************************************************************
REM 12345678901234567890123456789012345678901234567890123456789012345678901234567890
REM AGREEMENT  : F4913001, DISPATCH CONSIGNMENT
REM SOURCE     : EPU002
REM DESTINATION: CNS
REM OBJECT     : CSM
REM DESCRIPTION: SEND OF TABLE CONSIGNMENT_%
REM MADE BY    : ULF MATTSSON PURCHASING IT
REM CREATED    : 010516
REM IDRS FLOW  : \TOS\3_0\OBJECTS\CSM\DOCUMENTATION\CsmSpec.doc
REM CHANGED
REM WHO      WHEN      WHAT
REM -----    -------   ------------------------------------------
REM ANJOA2          140825        added ORD_NO_ISOM, ORDL_NO_ISOM and I table names IKEA00314758
REM MANKM1					161125				added PM_CODE for CSM line and changed i-tables also
REM*************************************************************
REM WHENEVER SQLERROR EXIT 16 ROLLBACK
WHENEVER SQLERROR EXIT sql.sqlcode

UPDATE run_idrs
   SET fix_date = SYSDATE
 WHERE idrs_name = 'F4913001'
/

SELECT record_type,
       trans_date,
       bu_code_cre,
       bu_type_cre,
       csm_no,
       bu_code_cnee,
       bu_type_cnee,
       bua_no_cnee,
       bu_code_pup,
       bu_type_pup,
       bua_no_pup,
       tod_code,
       tod_txt_place,
       mot_code,
       iftmbf_date,
       dsp_day_plan,
       load_meter_ord,
       trpt_vol_ord,
       trpt_wei_ord,
       lu_id_ref,
       pack_nof_csm,
       cp_flag,
       bu_code_tso,
       bu_type_tso,
       noti_seqno,
       lut_code_req,
       dsp_day,
       invo_no,
       cert_no,
       bl_id,
       f4913001_v.upd_date,
       send_date_cns_cre,
       arr_date_req,
       csm_vol_net,
       csm_wei_net,
       csm_vol_gro,
       csm_wei_gro,
       uom_code_wei,
       uom_code_vol,
       csm_vol_pal,
       csm_wei_pal,
       prop_cre_system
  FROM f4913001_v, run_idrs_t
 WHERE f4913001_v.upd_date > run_idrs_t.run_date
       AND run_idrs_t.idrs_name = 'F4913001'
       AND ( (    obj_status IN ('15', '255')
              AND send_date_cns_cre IS NOT NULL
              AND f4913001_v.upd_date > send_date_cns_cre)
            OR (obj_status = '30'
                AND NVL (send_date_cns_dsp, SYSDATE + 3000) <
                       run_idrs_t.run_date
                AND f4913001_v.upd_date > send_date_cns_dsp)
            OR (obj_status = '60'
                AND NVL (unload_date, SYSDATE + 3000) < run_idrs_t.run_date)
            OR (obj_status = '65'
                AND NVL (split_date, SYSDATE + 3000) < run_idrs_t.run_date))
/* SUPPLIER = PUR                */
/* TABLE =  I_4913051            */
/

SELECT record_type,
       trans_date,
       bu_code_cre_csm,
       bu_type_cre_csm,
       csm_no,
       csml_no,
       item_id,
       item_type,
       item_qty_dsp,
       bu_code_cre_ord,
       bu_type_cre_ord,
       ord_no,
       ordl_no,
       pua_no,
       pua_ver_no,
       create_date_ord,
       bu_code_rcv,
       bu_type_rcv,
       seq_no_ord,
       src_name_ord,
       sto_no_ddc,
       ord_no_ddc,
       ord_no_cos,
       ord_type,
       src_name_ins,
       ord_type_its,
       csml_vol_net,
       csml_wei_net,
       csml_vol_gro,
       csml_wei_gro,
       uom_code_wei,
       uom_code_vol,
       prod_date,
       HM_FLAG,
       CSML_WEI_PAL,
       CSML_VOL_PAL,
       ORD_NO_ISOM,
       ORDL_NO_ISOM,
       PM_CODE
  FROM f4913002_v
 WHERE (bu_code_cre_csm, bu_type_cre_csm, csm_no) IN
          (SELECT bu_code_cre, bu_type_cre, csm_no
             FROM run_idrs_t, f4913001_v
            WHERE f4913001_v.upd_date > run_idrs_t.run_date
                  AND run_idrs_t.idrs_name = 'F4913001'
                  AND ( (    obj_status IN ('15', '255')
                         AND send_date_cns_cre IS NOT NULL
                         AND f4913001_v.upd_date > send_date_cns_cre)
                       OR (obj_status = '3x'
                           AND NVL (send_date_cns_dsp, SYSDATE + 3000) <
                                  run_idrs_t.run_date
                           AND f4913001_v.upd_date > send_date_cns_dsp)
                       OR (obj_status = '6x'
                           AND NVL (unload_date, SYSDATE + 3000) <
                                  run_idrs_t.run_date)
                       OR (obj_status = '6x'
                           AND NVL (split_date, SYSDATE + 3000) <
                                  run_idrs_t.run_date)))
/* SUPPLIER = PUR                */
/* TABLE =  I_4913052            */
/

SELECT record_type,
       trans_date,
       bu_code_cre,
       bu_type_cre,
       csm_no,
       msg_id_csm,
       msg_txt_csm,
       src_name_ins
  FROM f4913003_v
 WHERE (bu_code_cre, bu_type_cre, csm_no) IN
          (SELECT bu_code_cre, bu_type_cre, csm_no
             FROM run_idrs_t, f4913001_v
            WHERE f4913001_v.upd_date > run_idrs_t.run_date
                  AND run_idrs_t.idrs_name = 'F4913001'
                  AND ( (    obj_status IN ('15', '255')
                         AND send_date_cns_cre IS NOT NULL
                         AND f4913001_v.upd_date > send_date_cns_cre)
                       OR (obj_status = '30'
                           AND NVL (send_date_cns_dsp, SYSDATE + 3000) <
                                  run_idrs_t.run_date
                           AND f4913001_v.upd_date > send_date_cns_dsp)
                       OR (obj_status = '60'
                           AND NVL (unload_date, SYSDATE + 3000) <
                                  run_idrs_t.run_date)
                       OR (obj_status = '65'
                           AND NVL (split_date, SYSDATE + 3000) <
                                  run_idrs_t.run_date)))
       AND upd_date > (SELECT run_date
                         FROM run_idrs_t
                        WHERE idrs_name = 'F4913001')
/* SUPPLIER = PUR                */
/* TABLE =  I_4913053            */
/* DEST = CNS001                */
/* TIMESTAMP */
/

UPDATE run_idrs
   SET run_date = fix_date, run_date_prev = run_date
 WHERE idrs_name = 'F4913001'
/