
CREATE PROCEDURE [dbo].[sp_dba_RemoveUser] 
@DatabaseName VARCHAR(75)= 'NoDatabase', 
@ExcludeList VARCHAR(4000)= ''
AS

DECLARE @UserNames TABLE  (DBUser varchar(75));
DECLARE @sql2 TABLE  (SqlCode varchar(4000));
DECLARE @sql1 VARCHAR(4500) = 'SELECT name from ' + @DatabaseName + '.dbo.sysusers where islogin=1;'
DECLARE @sql3 NVARCHAR(4000)

INSERT INTO @UserNames (DBUser) 
EXECUTE(@sql1);

DELETE FROM @UserNames
WHERE DBUser LIKE 'db_%'

DELETE FROM @UserNames
WHERE DBUser IN ('dbo','sa','guest','INFORMATION_SCHEMA','sys','NT AUTHORITY\SYSTEM','public');

DELETE FROM @UserNames
WHERE DBUser IN (SELECT item FROM dbo.fnGetTableFromCSV(@ExcludeList));

DECLARE @DatabaseUser VARCHAR (50)
        
DECLARE LoopThru CURSOR FOR SELECT DBUser FROM @UserNames

OPEN LoopThru
	FETCH NEXT FROM LoopThru INTO @DatabaseUser
	
	WHILE @@FETCH_STATUS = 0
		BEGIN

				SET @sql3= ('USE '+ @DatabaseName +''+';'+'EXEC sp_dropuser ['+ @DatabaseUser +']'+';')
				EXEC(@sql3)

				FETCH NEXT FROM LoopThru INTO @DatabaseUser
		END

CLOSE LoopThru
DEALLOCATE LoopThru

