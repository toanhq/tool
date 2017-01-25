-------- 1. Create table

Drop  TABLE "BACKUP_FK";

CREATE TABLE "BACKUP_FK"
(
  "TABLENAME"   VARCHAR2(500 CHAR),
  "COLUMNNAME"  VARCHAR2(500 CHAR),
  "TABLENAME1"  VARCHAR2(500 CHAR),
  "COLUMNNAME1" VARCHAR2(500 CHAR),
  "FK_NAME"     VARCHAR2(500 CHAR)
)
SEGMENT CREATION IMMEDIATE PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING STORAGE
(
  INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
)
TABLESPACE "USERS" ;

-------- 2. BackUp FK

insert into backup_fk(tablename, columnname, tablename1, columnname1, fk_name)

SELECT a.table_name, a.column_name, uc.table_name, uc.column_name, a.constraint_name 
FROM all_cons_columns a
JOIN all_constraints c ON a.owner = c.owner
    AND a.constraint_name = c.constraint_name
JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
       AND c.r_constraint_name = c_pk.constraint_name
join USER_CONS_COLUMNS uc on uc.constraint_name = c.r_constraint_name
WHERE  C.R_OWNER = 'NhiTW'
order by a.Table_name
;

-------- 3. Disable Foreign Key
set serveroutput on 
begin 
  declare cursor c_fk is 
  select * from backup_fk; 

  v_fk c_fk%rowtype; 
begin 
    DBMS_OUTPUT.ENABLE(1000000);
  open c_fk; 
  loop 
    fetch c_fk into v_fk;
  dbms_output.put_line('alter table '|| v_fk.tablename ||' DISABLE constraint ' || v_fk.fk_name || ';');
--   dbms_output.put_line('alter table '|| ';');
    exit when c_fk%notfound; 
  end loop; 
  close c_fk; 
end; 
end;
-------- 4. Truncate Data

set serveroutput on 
begin 
  declare cursor c_table is 
  select * from user_tables; 
  v_table c_table%rowtype; 
begin 
     DBMS_OUTPUT.ENABLE(1000000);
  open c_table; 
  loop 
    fetch c_table into v_table;
    dbms_output.put_line('truncate table '|| v_table.table_name || ';');
    exit when c_table%notfound; 
  end loop; 
  close c_table; 
end; 
end;

-------- 5. Enable Foreign Key

set serveroutput on 
begin 
  declare cursor c_fk is 
  select * from backup_fk; 

  v_fk c_fk%rowtype; 
begin 
     DBMS_OUTPUT.ENABLE(1000000);
  open c_fk; 
  loop 
    fetch c_fk into v_fk;
    dbms_output.put_line('alter table '|| v_fk.tablename ||' ENABLE constraint ' || v_fk.fk_name || ';');
    exit when c_fk%notfound; 
  end loop; 
  close c_fk; 
end; 
end;

-------- 6. Drop & Create Sequences

set serveroutput on 
begin 
  declare cursor c_seq is 
  select * from USER_SEQUENCES; 

  v_seq c_seq%rowtype; 
begin 
 DBMS_OUTPUT.ENABLE(1000000);
  open c_seq; 
  loop 
    fetch c_seq into v_seq;
    dbms_output.put_line('drop sequence '|| v_seq.sequence_name || ';');
    dbms_output.put_line('CREATE SEQUENCE "'|| v_seq.sequence_name || '" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE ;');
    exit when c_seq%notfound; 
  end loop; 
  close c_seq; 
end; 
end;
------------
