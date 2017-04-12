
-- =============================================
-- Author:		David Speight
-- =============================================
CREATE PROCEDURE [dbo].[NightlyRestore]
	@DatabaseName varchar(200)
AS
BEGIN

	SET NOCOUNT ON;

    DECLARE @SQL VARCHAR(MAX);
	DECLARE @tSubject VARCHAR(50);
	DECLARE @tBody VARCHAR(500);
	DECLARE @DataLogicalName VARCHAR(100);
	DECLARE @LogLogicalName VARCHAR(100);

	SELECT @DataLogicalName = [name]
	FROM sys.master_files
	WHERE DB_NAME([database_id]) = @DatabaseName and [name] NOT LIKE '%log%';

	SELECT @LogLogicalName = [name]
	FROM sys.master_files
	WHERE DB_NAME([database_id]) = @DatabaseName and [name] LIKE '%log%';

    SET @SQL = 'RESTORE DATABASE [' + @DatabaseName + '] FROM  DISK = N''C:\MSSQL\Restore\' + @DatabaseName + '.bak'' WITH  FILE = 1,  MOVE N''' 
				+ @DataLogicalName
				-- + @DatabaseName + (CASE WHEN @DatabaseName = 'MGIS' THEN '_Data' ELSE '' END) 
				+ ''' TO N''C:\MSSQL\Data\' + @DatabaseName + '.mdf'',  MOVE N''' 
				+ @LogLogicalName
				-- + @DatabaseName +  (CASE WHEN @DatabaseName ='CBGEU' THEN '' WHEN @DatabaseName = 'CBGUS' THEN '' ELSE '_' END) + 'log'
				+ ''' TO N''C:\MSSQL\Data\' + @DatabaseName + '_log.ldf'',  NOUNLOAD,  REPLACE,  STATS = 10'
	begin try
		EXEC (@SQL)
	end try
	begin catch
		begin try
			SELECT	@tSubject	= 'IAD-REPORT-01.'+@DatabaseName+' Restore Failed',
					@tBody		= 'IAD-REPORT-01.'+@DatabaseName+' nightly restore job failed.';
			EXEC msdb.dbo.sp_send_dbmail
			@profile_name	= 'DEVOPS',
			@recipients		= 'devops@coventbridge.com',
			@subject		= @tSubject,
			@body			= @tBody;
		end try
		begin catch
			Print 'email failed'
		end catch
	end catch

END

