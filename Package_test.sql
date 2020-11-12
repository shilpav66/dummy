--
-- TEST_Scipt  (Packaging) 
--
CREATE OR REPLACE PACKAGE TEST_Scipt
AS
/******************************************************************************
   NAME:       test
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        28-Dec-2006             1. Created this package.
******************************************************************************/
   FUNCTION tfunction (param1 IN NUMBER)
      RETURN NUMBER;

END Test_Scipt;
/
--
-- Test_Scipt  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY Test_Scipt AS
/******************************************************************************
   NAME:       test
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        28-Dec-2006             1. Created this package body.
******************************************************************************/

  FUNCTION tFunction(Param1 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN Param1;
  END;
/

