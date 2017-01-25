	select
   c.owner,
   c.object_name,
   c.object_type,
   b.sid,
   b.serial#,
   b.status,
   b.osuser,
   b.machine
   ,LAST_CALL_ET
   ,ROW_WAIT_ROW#
   ,ROW_WAIT_BLOCK#
   ,BLOCKING_SESSION_STATUS
   ,BLOCKING_INSTANCE
   ,BLOCKING_SESSION
   ,COMMAND
from
   v$locked_object a ,
   v$session b,
   dba_objects c
where
   b.sid = a.session_id
and
   a.object_id = c.object_id;
   
   -----alter system kill session 'sid,serial#';
   
     --------------- B2. Thô bạo kill section ------------------------- 
--   ALTER SYSTEM KILL SESSION '1379,3141' ;



SELECT l.sid, s.blocking_session blocker, s.event, l.type, l.lmode, l.request, o.object_name, o.object_type 
FROM v$lock l, dba_objects o, v$session s 
WHERE UPPER(s.username) = UPPER('Nhitw') 
AND l.id1 = o.object_id (+) 
AND l.sid = s.sid 
and s.event like '%enq%'
ORDER BY sid, type;



----- Tim cac bang co khoa ngoai nhung ko tao index------
SELECT * FROM (
SELECT c.table_name, cc.column_name, cc.position column_position
FROM   user_constraints c, user_cons_columns cc
WHERE  c.constraint_name = cc.constraint_name
AND    c.constraint_type = 'R'
MINUS
SELECT i.table_name, ic.column_name, ic.column_position
FROM   user_indexes i, user_ind_columns ic
WHERE  i.index_name = ic.index_name
)
where column_name = 'CLSketqua_id'
ORDER BY table_name, column_position;


