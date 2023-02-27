--CUSTOMER TABLE
CREATE TABLE CUSTOMERS
(
CUST_ID VARCHAR2(5),
CUST_NAME VARCHAR2(30),
CUST_ADDRESS VARCHAR2(50),
CUST_MOBILE NUMBER(10),
CUST_MAIL VARCHAR2(30),
CUST_GENDER CHAR(1),
CUST_PAN VARCHAR2(20)
);
INSERT INTO CUSTOMERS VALUES('C0001','Rohan Dey','Asansol',9543198345,'Rohan@gmail.com','M','226778564321');


SELECT * FROM CUSTOMERS;

--ACCOUNT  TABLE
CREATE TABLE ACCOUNTS
(
ACC_ID NUMBER(10),
CUST_ID VARCHAR2(10),
ACC_OPEN_DT DATE,
ACC_BALANCE NUMBER(10),
ACC_TYPE VARCHAR2(10)
);
INSERT INTO ACCOUNTS VALUES(10001,'C0001','15-DEC-2012',5000,'SAVINGS');


SELECT * FROM ACCOUNTS;

--TRANSACTION TABLE
CREATE TABLE TRANSACTIONS
(
TRAN_NO NUMBER(10),
ACC_ID NUMBER(10),
TRAN_DT DATE,
TRAN_AMOUNT NUMBER(10),
TRAN_TYPE  VARCHAR2(15),
TRAN_STATUS VARCHAR2(15)
);


CREATE SEQUENCE TRANSACTIONS_SEQ
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE
 ;
 

SELECT * FROM TRANSACTIONS;


----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION CHECK_CURRENT_BALANCE(accID in NUMBER)
RETURN NUMBER
IS
result NUMBER := 0;
BEGIN
  declare
  querystr varchar2(2000) ;
  result NUMBER(10);
  begin
    querystr :='SELECT ACC_BALANCE FROM ACCOUNTS WHERE ACC_ID ='|| accID;
    EXECUTE IMMEDIATE querystr INTO result;
    RETURN result;
  end;
END ;


SELECT CHECK_CURRENT_BALANCE(10001) FROM dual;
-----------------------------------------------------------------------------------------------
DEPOSIT
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DEPOSIT(accID in NUMBER, amount in NUMBER, succ out NUMBER)
AS
curr_bal NUMBER;
BEGIN
succ:=0;
SELECT ACC_BALANCE into curr_bal FROM ACCOUNTS WHERE ACC_ID =accID;
succ:=1;
UPDATE ACCOUNTS SET ACC_BALANCE = curr_bal+amount WHERE ACC_ID = accID;
succ:=2;
INSERT INTO TRANSACTIONS VALUES(TRANSACTIONS_SEQ.nextval,accID,SYSDATE,amount,'DEPOSIT','SUCCESS');
succ:=3;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Customer not registered with our bank.');
    WHEN OTHERS THEN
        dbms_output.put_line('Something went wrong.');
END ;
/

DECLARE
  l_success_code NUMBER;
BEGIN
  DEPOSIT(10001, 2000, l_success_code);
END;

-----------------------------------------------------------------------------------------------
WITHDRAWAL
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE WITHDRAWAL(accID in NUMBER, amount in NUMBER, succ out NUMBER)
AS
curr_bal NUMBER;
insufficient_account_balance EXCEPTION;
BEGIN
succ:=0;
    SELECT ACC_BALANCE into curr_bal FROM ACCOUNTS WHERE ACC_ID =accID;
    succ:=1;
   
    IF amount <= curr_bal THEN
        UPDATE ACCOUNTS SET ACC_BALANCE = curr_bal-amount WHERE ACC_ID = accID;
        succ:=2;
    ELSE
        RAISE insufficient_account_balance;
        succ:=NULL;
    END IF;

INSERT INTO TRANSACTIONS VALUES(TRANSACTIONS_SEQ.nextval,accID,SYSDATE,amount,'WITHDRAWAL','SUCCESS');
succ:=3;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Customer not registered with our bank.');
    WHEN insufficient_account_balance THEN
        dbms_output.put_line('Insufficient Account Balance in your Account.');
    WHEN OTHERS THEN
        dbms_output.put_line('Something went wrong.');
END ;


DECLARE
  l_success_code NUMBER;
BEGIN
  WITHDRAWAL(10001, 2000, l_success_code);
END;


