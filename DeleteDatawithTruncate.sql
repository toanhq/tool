
--==========================================================================
--====1. Backup foreign key to Table T_FK_Xref =============================
--==========================================================================
Use eHospital_DongNai 
Go
IF  EXISTS (Select [name] from sys.tables where [name] = 'T_FK_Xref' and type = 'U') 
 truncate table T_FK_Xref
go
--Create Table to store constraint information
 IF  NOT EXISTS  (Select [name] from sys.tables where [name] = 'T_FK_Xref' and type = 'U')
 Create table eHospital_DongNai.dbo.T_FK_Xref (
 ID int identity (1,1),
 ConstraintName varchar (255),
 MasterTable varchar(255),
 MasterColumn varchar(255),
 ChildTable varchar(255),
 ChildColumn varchar(255),
 FKOrder int
 ) 
go
--Store Constraints 
insert into eHospital_DongNai.dbo.T_FK_Xref(ConstraintName,MasterTable,MasterColumn,ChildTable,ChildColumn,FKOrder)
  SELECT object_name(constid) as ConstraintName,object_name(rkeyid) MasterTable
      ,sc2.name MasterColumn
      ,object_name(fkeyid) ChildTable 
      ,sc1.name ChildColumn
      ,cast (sf.keyno as int) FKOrder
   FROM sysforeignkeys  sf
INNER JOIN syscolumns sc1 ON sf.fkeyid = sc1.id AND sf.fkey = sc1.colid
INNER JOIN syscolumns sc2 ON sf.rkeyid = sc2.id AND sf.rkey = sc2.colid
ORDER BY rkeyid,fkeyid,keyno

Go
Select * from T_FK_Xref
go


--==========================================================================
--====2. Generate Script Drop Foreign key =============================
--==========================================================================

use eHospital_DongNai --Database to removed constraints
go
---Ready to remove constraints

declare @ConstraintName varchar (max) -- Name of the Constraint
declare @ChildTable varchar (max) -- Name of Child Table
declare @MasterTable varchar (max)--Name of Parent Table
declare @ChildColumn varchar (max)--Column of Child Table FK
declare @MasterColumn varchar (max)-- Parent Column PK
declare @FKOrder smallint -- Fk order
declare @sqlcmd varchar (max) --Dynamic Sql String 


-- Create cursor to get constraint Information
declare drop_constraints cursor  
fast_forward 
for
SELECT object_name(constid) as ConstraintName,object_name(rkeyid) MasterTable
      ,sc2.name MasterColumn
      ,object_name(fkeyid) ChildTable 
      ,sc1.name ChildColumn
      ,cast (sf.keyno as int) FKOrder
   FROM sysforeignkeys  sf
INNER JOIN syscolumns sc1 ON sf.fkeyid = sc1.id AND sf.fkey = sc1.colid
INNER JOIN syscolumns sc2 ON sf.rkeyid = sc2.id AND sf.rkey = sc2.colid
ORDER BY rkeyid,fkeyid,keyno

open drop_constraints
fetch next from drop_constraints 
into
@ConstraintName
,@MasterTable
,@MasterColumn
,@ChildTable
,@ChildColumn
,@FKOrder
while @@Fetch_status = 0
begin

-- Create Dynamic Sql to drop constraint 

 select @sqlcmd = 'alter table '+@ChildTable+' drop constraint '+@ConstraintName--+' foreign key '+'('+@ChildColumn+')'+' references '+@MasterTable+' ('+@MasterColumn+')'+' on delete no action on update no action'
If EXISTs (select object_name(constid) from sysforeignkeys where object_name(constid) = @ConstraintName)
	--exec (@sqlcmd)
	print @sqlcmd
fetch next from drop_constraints 
into
@ConstraintName
,@MasterTable
,@MasterColumn
,@ChildTable
,@ChildColumn
,@FKOrder
end
close drop_constraints
deallocate drop_constraints
Go

--==========================================================================
--====3. Generate Truncate Table  =============================
--==========================================================================
go
--Removed CHECK Constraint-------------------------
--EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL' --NOCHECK Constraints
--print 'All Constraints Disable'
--go

--truncate All tables  if trying to empty the database 
 --- Ensure the T_X_ref database is located on a different database

-------------  Truncate All Tables from Model ----------------
-----To limit tables a table with sub model tables must be created  and used joins-----
--EXEC sp_MSForEachTable 'truncate TABLE ? '
--print 'All tables truncated'
go


	declare @str varchar(500), @TableName varchar(500)

	declare Cur cursor for
	select [name] from sysobjects where xtype = 'u'	order by Name
	
	open Cur 
	fetch next from cur into @TableName
		
	while @@fetch_status = 0
	begin
		set @str = 'Truncate Table ' + @TableName
		Print @Str
		fetch next from cur into @TableName
	end

	CLOSE Cur
	DEALLOCATE Cur



--==========================================================================
--====4. Generate Script create Foreign Key  =============================
--==========================================================================
go

Declare	@F_Name varchar(128)
	, @F_Table varchar(128)
	, @F_Column varchar(128)
	, @P_Table varchar(128)
	, @P_Column varchar(128)

Declare	@Str varchar(500)

Declare Cur Cursor For
	select 	ConstraintName,
			 ChildTable ,
			 ChildColumn,
			  MasterTable,
			 MasterColumn
	From	T_FK_Xref

	open cur
	fetch next from cur  into  	@F_Name
					, @F_Table
					, @F_Column
					, @P_Table
					, @P_Column
	while @@Fetch_status = 0
	Begin 

		set @str = 'ALTER TABLE ' + @F_Table + ' 
				ADD CONSTRAINT ' + @F_Name + ' 
				FOREIGN KEY (' + @F_Column + ') 
				REFERENCES ' + @P_Table +
				'(' + @P_Column + ')'
		print @Str


		fetch next from cur  into  	@F_Name
					, @F_Table
					, @F_Column
					, @P_Table
					, @P_Column
	End 
	close cur
	deallocate cur
	
	
	
	
--==========================================================================
--====5. Generate Script Reset Indentiy  =============================
--==========================================================================
go

	declare @str varchar(500), @TableName varchar(500)

	declare Cur cursor for
	select [name] from sysobjects where xtype = 'u'	order by Name
	
	open Cur 
	fetch next from cur into @TableName
		
	while @@fetch_status = 0
	begin
		set @str = 'DBCC CHECKIDENT (''' + @TableName +''', RESEED,1) ' -- Reset to 0
		Print @Str
		set @str = 'DBCC CHECKIDENT (''' + @TableName +''', RESEED) ' -- Reset về giá trị max
		Print @Str
		fetch next from cur into @TableName
	end

	CLOSE Cur
	DEALLOCATE Cur