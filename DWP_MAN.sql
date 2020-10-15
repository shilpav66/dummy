--
-- DWP_MAN  (Package) 
--
CREATE OR REPLACE PACKAGE       DWP_MAN AS

   VersionNo   VARCHAR2(5) := 'V001';
   CreStat     NUMBER := Adm_chk.GET_OBJ_STAT('ISP','CREATED');
   CompStat       NUMBER := Adm_chk.GET_OBJ_STAT('ISP','COMPLETED');
   RemTosStat  NUMBER := 3;
   RemIosStat  NUMBER := 4;
   Err          EXCEPTION;
   ErrText        VARCHAR2(40);


   PROCEDURE CREATE_ISP(pBuCodeSup IN VARCHAR2,
                          pItemNo IN VARCHAR2,
                          pUser IN VARCHAR2);
END DWP_MAN;
/


--
-- DWP_MAN  (Synonym) 
--
CREATE OR REPLACE PUBLIC SYNONYM DWP_MAN FOR DWP_MAN
/


GRANT EXECUTE ON DWP_MAN TO GPSEU_DEV
/

GRANT EXECUTE ON DWP_MAN TO GPS_GADD
/

--
-- DWP_MAN  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY       dwp_man
AS
   /******************************************************************************
      NAME:       Create_Isp
      PURPOSE:    Insert ISP in table ITEM_SUP_T
                  and prel-values into ITEM_SUP_FROM_DATE_T.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        09-Jun-2009 LJAR              Moved this procedure
      1.8        2013-Sep-17 BESVE1            Use saved records in temp tables if it exists for the relation when pua_item and pua_item_price is inserted
                                               and an insert in Item_Sup_T is done.

      NOTES: Origin - ISP_MAN.CREATE_ISP
      1.9				 27-Apr-2017	MANKM1					 Changes for IKEA00911911 - DWP Reverse Flow
   ******************************************************************************/
   PROCEDURE create_isp (pbucodesup   IN VARCHAR2,
                         pitemno      IN VARCHAR2,
                         puser        IN VARCHAR2)
   IS
      lcitemweinet   item_sup_from_date_t.item_wei_net%TYPE;
      lcitemweigro   item_sup_from_date_t.item_wei_gro%TYPE;
      lcitemlen      item_sup_from_date_t.item_len%TYPE;
      lcitemwid      item_sup_from_date_t.item_wid%TYPE;
      lcitemhei      item_sup_from_date_t.item_hei%TYPE;
      lcmpacklen     item_sup_from_date_t.mpack_len%TYPE;
      lcmpackwid     item_sup_from_date_t.mpack_wid%TYPE;
      lcmpackhei     item_sup_from_date_t.mpack_hei%TYPE;
      lcmpackqty     item_sup_from_date_t.item_qty_mpack%TYPE;
      lcpallqty      item_sup_from_date_t.item_qty_pall%TYPE;
      lcmeasstat     item_sup_from_date_t.meas_stat_calc%TYPE;
      lcunitno       item_t.unit_no%TYPE;
      lcitemtype     item_t.item_type%TYPE := itm_chk.get_type (pitemno);
      lcitemvol      item_sup_from_date_t.c_vol%TYPE;
      lcmpackvol     item_sup_from_date_t.c_vol%TYPE;
      lcpallvol      item_sup_from_date_t.c_vol%TYPE;
      lccalcvol      item_sup_from_date_t.c_vol%TYPE;
      lcdebug        VARCHAR2 (10) := 'DEFINE';
      lcdummy        VARCHAR2 (1);


      CURSOR selprel
      IS
         SELECT item_wei_net_prel,
                item_wei_gro_prel,
                item_len_prel,
                item_wid_prel,
                item_hei_prel,
                mpack_len_prel,
                mpack_wid_prel,
                mpack_hei_prel,
                item_qty_mpack_prel,
                item_qty_pall_prel,
                meas_stat_calc_pr,
                unit_no
           FROM item_t
          WHERE item_no = pitemno;

      PROCEDURE debug (pmess IN VARCHAR2)
      IS
         lcdebug   BOOLEAN := TRUE;
      BEGIN
         IF lcdebug
         THEN
            DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'yyyy-mm-dd hh24:mi:ss') || '   ' || pmess);
         END IF;
      END;

      FUNCTION item_exists (psupno IN VARCHAR2, pitemno IN VARCHAR2)
         RETURN VARCHAR2
      AS
      BEGIN
         SELECT MIN ('X')
           INTO lcdummy
           FROM item_sup_t
          WHERE bu_code_sup = psupno AND item_no = pitemno;

         IF lcdummy IS NULL
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END;

      FUNCTION dwp_item_exists (psupno IN VARCHAR2, pitemno IN VARCHAR2)
         RETURN VARCHAR2
      AS
      BEGIN
         SELECT MIN ('X')
           INTO lcdummy
           FROM item_sup_from_date_tmp_t
          WHERE bu_code_sup = psupno AND item_no = pitemno;

         IF lcdummy IS NULL
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END;

      FUNCTION date_exists (psupno IN VARCHAR2, pitemno IN VARCHAR2)
         RETURN VARCHAR2
      AS
      BEGIN
         SELECT MIN ('X')
           INTO lcdummy
           FROM item_sup_from_date_t
          WHERE bu_code_sup = psupno AND item_no = pitemno;

         IF lcdummy IS NULL
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END;

      FUNCTION dwp_switched (psupno IN VARCHAR2, psuptype IN VARCHAR2)
         RETURN VARCHAR2
      AS
      BEGIN
         SELECT MIN ('X')
           INTO lcdummy
           FROM bu_supplier_t
          WHERE bu_code_sup = psupno AND bu_type_sup = psuptype
                AND TRUNC (NVL (dwp_switch_date - 1, SYSDATE)) <
                       TRUNC (SYSDATE);

         IF lcdummy IS NULL
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END;

      FUNCTION insert_from_dwp (psupno IN VARCHAR2, pitemno IN VARCHAR2)
         RETURN VARCHAR2
      AS
      BEGIN
         debug ('INSERT_FROM_DWP 1: ' || psupno || '/' || pitemno);

         INSERT INTO gpseu.item_sup_from_date_t (item_no,
                                                 item_type,
                                                 bu_code_sup,
                                                 bu_type_sup,
                                                 from_date,
                                                 item_wei_gro,
                                                 item_wid,
                                                 item_hei,
                                                 item_len,
                                                 pall_wid,
                                                 pall_hei,
                                                 pall_len,
                                                 pall_wei,
                                                 pall_wei_stack,
                                                 pallt_code,
                                                 item_qty_pall,
                                                 item_qty_mpack,
                                                 item_wei_net,
                                                 mpack_len,
                                                 mpack_wid,
                                                 mpack_hei,
                                                 meas_stat_calc,
                                                 end_date,
                                                 src_name_ins,
                                                 src_com_ins,
                                                 ins_date,
                                                 user_code_ins,
                                                 src_name_upd,
                                                 src_com_upd,
                                                 ii_date,
                                                 user_code_upd,
                                                 delete_date,
                                                 item_no_pallet,
                                                 item_type_pallet,
                                                 loading_ledge_nof,
                                                 cyl_stat_calc,
                                                 ver_no,
                                                 c_vol,
                                                 upd_date,
                                                 iu_date,
                                                 mpack_wei)
            SELECT item_no,
                   item_type,
                   bu_code_sup,
                   bu_type_sup,
                   from_date,
                   item_wei_gro,
                   item_wid,
                   item_hei,
                   item_len,
                   pall_wid,
                   pall_hei,
                   pall_len,
                   pall_wei,
                   pall_wei_stack,
                   pallt_code,
                   item_qty_pall,
                   item_qty_mpack,
                   item_wei_net,
                   mpack_len,
                   mpack_wid,
                   mpack_hei,
                   DECODE (meas_stat_calc,
                           '1', 'Y',
                           '0', 'N',
                           meas_stat_calc),
                   end_date,
                   'DWP_RFLOW',
                   'DWP_MAN',
                   SYSDATE,
                   user_code_ins,
                   src_name_upd,
                   src_com_upd,
                   SYSDATE,
                   user_code_upd,
                   delete_dtime,
                   item_no_pallet,
                   item_type_pallet,
                   loading_ledge_nof,
                   DECODE (cyl_stat_calc,
                           '1', 'Y',
                           '0', 'N',
                           cyl_stat_calc),
                   1,
                   c_vol,
                   SYSDATE,
                   SYSDATE,
                   mpack_wei
              FROM item_sup_from_date_tmp_t b
             WHERE b.bu_code_sup = psupno AND b.item_no = pitemno
                   AND b.from_date =
                          (SELECT MAX (d.from_date)
                             FROM item_sup_from_date_tmp_t d
                            WHERE     d.item_no = b.item_no
                                  AND d.item_type = b.item_type
                                  AND d.bu_code_sup = b.bu_code_sup
                                  AND d.bu_type_sup = b.bu_type_sup);

         DELETE item_sup_from_date_tmp_t b
          WHERE b.bu_code_sup = psupno AND b.item_no = pitemno;

         --
         debug ('INSERT_FROM_DWP 2: ' || psupno || '/' || pitemno);

         INSERT INTO gpseu.item_sup_pack_date_t (item_no,
                                                 item_type,
                                                 bu_code_sup,
                                                 bu_type_sup,
                                                 map_code,
                                                 from_date,
                                                 end_date,
                                                 map_wei_piece,
                                                 map_wei_multi,
                                                 map_wei_pall,
                                                 src_name_ins,
                                                 src_com_ins,
                                                 ins_date,
                                                 user_code_ins,
                                                 src_name_upd,
                                                 src_com_upd,
                                                 upd_date,
                                                 user_code_upd,
                                                 ii_date,
                                                 iu_date,
                                                 delete_date,
                                                 ver_no)
            SELECT item_no,
                   item_type,
                   bu_code_sup,
                   bu_type_sup,
                   map_code,
                   from_date,
                   end_date,
                   map_wei_piece,
                   map_wei_multi,
                   map_wei_pall,
                   'DWP_RFLOW',
                   'DWP_MAN',
                   SYSDATE,
                   user_code_ins,
                   src_name_upd,
                   src_com_upd,
                   SYSDATE,
                   user_code_upd,
                   SYSDATE,
                   SYSDATE,
                   delete_dtime,
                   1
              FROM item_sup_pack_date_tmp_t b
             WHERE b.bu_code_sup = psupno AND b.item_no = pitemno
                   AND b.from_date =
                          (SELECT MAX (d.from_date)
                             FROM item_sup_pack_date_tmp_t d
                            WHERE     d.item_no = b.item_no
                                  AND d.item_type = b.item_type
                                  AND d.bu_code_sup = b.bu_code_sup
                                  AND d.bu_type_sup = b.bu_type_sup
                                  AND d.map_code = b.map_code)
                   AND NOT EXISTS
                              (SELECT 'X'
                                 FROM gpseu.item_sup_pack_date_t c
                                WHERE     c.item_no = b.item_no
                                      AND c.item_type = b.item_type
                                      AND c.bu_code_sup = b.bu_code_sup
                                      AND c.bu_type_sup = b.bu_type_sup
                                      AND c.map_code = b.map_code
                                      AND c.from_date = b.from_date);

         DELETE FROM item_sup_pack_date_tmp_t b
               WHERE b.bu_code_sup = psupno AND b.item_no = pitemno;

         RETURN 'OK';
      END;
   BEGIN
      lcdebug := 'START';

      debug ('Start: ' || pbucodesup || '/' || pitemno);

      -- Create Object Holder (ITEM_SUP_T)
      IF item_exists (pbucodesup, pitemno) = 'N'
      THEN
         --debug('INSERTING_NEW_ITEM' in item_sup_t);
         INSERT INTO item_sup_t (item_no,
                                 item_type,
                                 bu_code_sup,
                                 bu_type_sup,
                                 obj_status,
                                 delete_date,
                                 delete_date_ios,
                                 upd_date,
                                 ecis_send_date,
                                 ver_no,
                                 ins_date,
                                 user_code_upd,
                                 user_code_ins)
              VALUES (pitemno,
                      lcitemtype,
                      pbucodesup,
                      'SUP',
                      crestat,
                      NULL,
                      NULL,
                      SYSDATE,
                      NULL,
                      0,
                      SYSDATE,
                      puser,
                      puser);

         lcdebug := 'INSISP';
         debug ('NEW_ITEM INSERTED in item_sup_t');
      ELSE
         debug ('date_exists: ' || pbucodesup || '/' || pitemno);

         lcdummy := date_exists (pbucodesup, pitemno);

         --debug('UPDATE_ITEM');
         UPDATE item_sup_t
            SET ver_no = ver_no + 1,
                delete_date_tos = NULL,
                delete_date_ios = NULL,
                delete_date = NULL,
                ecis_send_date = NULL,
                obj_status =
                   DECODE (lcdummy,
                           'N', crestat,
                           DECODE (obj_status, '30', crestat, obj_status)),
                upd_date = SYSDATE,
                user_code_upd = puser
          WHERE     bu_code_sup = pbucodesup
                AND bu_type_sup = 'SUP'
                AND item_no = pitemno
                AND item_type = NVL (lcitemtype, item_type);

         lcdebug := 'UPDISP';
      END IF;

      --
      -- Fetch preliminar values from ITEM
      -- Added check if Supplier has been converted to use New DWP, if so ITEM_SUP_FROM_DATE_T shall not be updated /BISV 2010-04-20
      --

      OPEN selprel;

      debug ('FETCHING_VALUES');

      FETCH selprel
      INTO lcitemweinet,
           lcitemweigro,
           lcitemlen,
           lcitemwid,
           lcitemhei,
           lcmpacklen,
           lcmpackwid,
           lcmpackhei,
           lcmpackqty,
           lcpallqty,
           lcmeasstat,
           lcunitno;

      CLOSE selprel;

      lcdebug := 'FETCHPREL';

      -- Calculate Volumes for CALC
      debug ('CALCULATE_VALUES');
      dwp_chk.calculate_volumes (lcitemlen,
                                 lcitemwid,
                                 lcitemhei,
                                 lcitemvol,
                                 lcmpacklen,
                                 lcmpackwid,
                                 lcmpackhei,
                                 lcmpackqty,
                                 lcmpackvol,
                                 lccalcvol,
                                 lcunitno,
                                 lcmeasstat);
      lcdebug := 'CALCVOL';

      IF date_exists (pbucodesup, pitemno) = 'N'
      THEN
         -- Create DWP Values (ITEM_SUP_FROM_DATE_T)
         lcdebug := 'INSDATE';

         IF dwp_item_exists (pbucodesup, pitemno) = 'N'
         THEN
            -- If no DWP transaction exists then create default
            INSERT INTO item_sup_from_date_t (item_no,
                                              item_type,
                                              bu_code_sup,
                                              bu_type_sup,
                                              from_date,
                                              item_wei_gro,
                                              item_wid,
                                              item_hei,
                                              item_len,
                                              item_wei_net,
                                              pall_wid,
                                              pall_hei,
                                              pall_len,
                                              pall_wei,
                                              pall_wei_stack,
                                              pallt_code,
                                              item_no_pallet,
                                              item_type_pallet,
                                              stacking_class,
                                              loading_ledge_nof,
                                              mpack_wid,
                                              mpack_hei,
                                              mpack_len,
                                              mpack_wei,
                                              item_qty_pall,
                                              item_qty_mpack,
                                              meas_stat_calc,
                                              upd_date,
                                              ver_no,
                                              ins_date,
                                              user_code_upd,
                                              c_vol,
                                              user_code_ins)
                 VALUES (pitemno,
                         lcitemtype,
                         pbucodesup,
                         'SUP',
                         TRUNC (SYSDATE),
                         lcitemweigro,
                         lcitemwid,
                         lcitemhei,
                         lcitemlen,
                         lcitemweinet,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         'ADS',
                         NULL,
                         NULL,
                         lcmpackwid,
                         lcmpackhei,
                         lcmpacklen,
                         NULL,
                         lcpallqty,
                         lcmpackqty,
                         lcmeasstat,
                         SYSDATE,
                         0,
                         SYSDATE,
                         puser,
                         lccalcvol,
                         puser);
         ELSE
            -- DWP transaction exists then create from temp table
            IF NVL (insert_from_dwp (pbucodesup, pitemno), 'XX') != 'OK'
            THEN
               debug (
                     'DWP_MAN. Wrong Insert from DWP: '
                  || pbucodesup
                  || '/'
                  || pitemno
                  || ':=  '
                  || NVL (insert_from_dwp (pbucodesup, pitemno), 'XX'));

               raise_application_error (
                  -20005,
                  'Error trg: DWP_MAN.create_isp '
                  || adm_chk.get_error (SQLERRM));
            END IF;
         END IF;
      ELSE
         IF dwp_switched (pbucodesup, 'SUP') = 'N'
         THEN
            UPDATE item_sup_from_date_t
               SET delete_date = NULL,
                   upd_date = SYSDATE,
                   ver_no = ver_no + 1,
                   user_code_upd = puser,
                   end_date = NULL,
                   src_com_ins = NULL,
                   src_com_upd = NULL,
                   src_name_ins = NULL,
                   src_name_upd = NULL
             WHERE     item_no = pitemno
                   AND item_type = lcitemtype
                   AND bu_code_sup = pbucodesup
                   AND bu_type_sup = 'SUP'
                   AND from_date =
                          (SELECT MAX (from_date)
                             FROM item_sup_from_date_t
                            WHERE     item_no = pitemno
                                  AND item_type = lcitemtype
                                  AND bu_code_sup = pbucodesup
                                  AND bu_type_sup = 'SUP');
         END IF;
      END IF;
      UPDATE item_sup_t
          SET upd_date = SYSDATE,
           iu_Date = SYSDATE,
           ver_no = ver_no + 1,
           obj_status_date = SYSDATE,
           obj_status = '20'
     WHERE item_no =pitemno
       AND item_type = NVL (lcitemtype, item_type)
       AND bu_code_sup = pbucodesup
       AND bu_type_sup =  'SUP'
       AND obj_status = '10'
       AND  EXISTS  (select 'X' from gps_dwp2_item_send_t
                                    where item_no = pitemno and bu_code_send = pbucodesup
                                    and  TRUNC(SYSDATE) between FROM_PACK_DATE and nvl(TO_PACK_DATE,TRUNC(SYSDATE)+1)
                                    and delete_dtime IS NULL);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE item_sup_t
            SET ver_no = ver_no + 1,
                delete_date_tos = NULL,
                delete_date_ios = NULL,
                delete_date = NULL,
                ecis_send_date = NULL,
                obj_status = compstat,
                upd_date = SYSDATE
          WHERE     bu_code_sup = pbucodesup
                AND bu_type_sup = 'SUP'
                AND item_no = pitemno
                AND item_type = NVL (lcitemtype, item_type)
                AND delete_date_tos IS NOT NULL;

         IF SQL%ROWCOUNT = 0
         THEN
            -- Make sure that the article are sent to ECIS...
            UPDATE item_sup_t
               SET ver_no = ver_no + 1,
                   ecis_send_date = NULL,
                   upd_date = SYSDATE
             WHERE     bu_code_sup = pbucodesup
                   AND bu_type_sup = 'SUP'
                   AND item_no = pitemno
                   AND item_type = NVL (lcitemtype, item_type)
                   AND ecis_send_date IS NOT NULL;
         END IF;
      WHEN err
      THEN
         raise_application_error (-20099, errtext);
      WHEN OTHERS
      THEN
         raise_application_error (
            SQLCODE,
            'DWP_MAN.Create_Isp:(' || lcdebug || ') ' || SQLERRM);
   END create_isp;
END dwp_man;
/


--
-- DWP_MAN  (Synonym) 
--
CREATE OR REPLACE PUBLIC SYNONYM DWP_MAN FOR DWP_MAN
/


GRANT EXECUTE ON DWP_MAN TO GPSEU_DEV
/

GRANT EXECUTE ON DWP_MAN TO GPS_GADD
/

