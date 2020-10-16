CREATE PACKAGE Test_jenkins AS
   
END Test_jenkins;
/
CREATE PACKAGE BODY Test_jenkins AS
-- the following parameter declaration raises an exception 
-- because 'DATE' does not match employees.hire_date%TYPE
-- PROCEDURE calc_bonus (date_hired DATE) IS
-- the following is correct because there is an exact match
   BEGIN
     DBMS_OUTPUT.PUT_LINE('Employees hired on ' || date_hired || ' get bonus.');
   END;
END Test_jenkins;
/
