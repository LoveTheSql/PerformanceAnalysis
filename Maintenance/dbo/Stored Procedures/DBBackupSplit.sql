CREATE PROCEDURE [dbo].[DBBackupSplit]
@DB varchar(100), -- Database to be Backed Up
@Path varchar(500) = '', -- Path where the .BAK file will be stored
@CopyOnly BIT = 1,
@DoNotSplit BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FileSplitCount int;
	DECLARE @iCount int;
	DECLARE @upCount int=1;
	DECLARE @deletePath varchar(250);
	DECLARE @Backup VARCHAR(2000);
	DECLARE @Query VARCHAR(4000);
	DECLARE @CopyOption VARCHAR(50);
	SELECT  @CopyOption = (CASE WHEN @CopyOnly = 0 then ';' ELSE ', COPY_ONLY;' END);
	DECLARE @FileList TABLE (ID int IDENTITY(1,1), FilePath varchar(250))
	INSERT INTO  @FileList (FilePath)	
	SELECT 
	   B.physical_device_name
	FROM 
			(		SELECT   
					   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
					   msdb.dbo.backupset.database_name,  
					   MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date 
				   FROM    msdb.dbo.backupmediafamily  
					   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
				   WHERE   msdb..backupset.type = 'D' 
					AND  msdb..backupset.database_name = @DB
				   GROUP BY 
					   msdb.dbo.backupset.database_name  
			) AS A 
    
	   LEFT JOIN 
			(    SELECT   
				   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
				   msdb.dbo.backupset.database_name,  
				   msdb.dbo.backupset.backup_start_date,  
				   msdb.dbo.backupset.backup_finish_date, 
				   msdb.dbo.backupset.expiration_date, 
				   msdb.dbo.backupset.backup_size,  
				   msdb.dbo.backupmediafamily.logical_device_name,  
				   msdb.dbo.backupmediafamily.physical_device_name,   
				   msdb.dbo.backupset.name AS backupset_name, 
				   msdb.dbo.backupset.description 
				FROM   msdb.dbo.backupmediafamily  
				   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
				WHERE  msdb..backupset.type = 'D' 
			) AS B 
	   ON A.[server] = B.[server] AND A.[database_name] = B.[database_name] AND A.[last_db_backup_date] = B.[backup_finish_date] 
	ORDER BY A.database_name;

	-- Delete any old backup file first. This is needed in case we cahnge the number of files, buffer or block size.
	SELECT @iCount = COUNT(*) FROM @FileList;
	WHILE @iCount > 0
	BEGIN
		SELECT @deletePath = 'del ' + FilePath FROM @FileList WHERE ID = @iCount;
		exec master..xp_cmdshell @deletePath;
		SELECT @iCount = @iCount-1;
	END;

	-- Determine how many files to split database
	SELECT @FileSplitCount=		(CASE	WHEN @DoNotSplit = 1 THEN 1
										ELSE ( CONVERT(INT,(CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2)))/18000)+1) END) 
	FROM sys.master_files WITH(NOWAIT)
	WHERE database_id = DB_ID(@DB);

	SELECT @DoNotSplit = (CASE WHEN @FileSplitCount < 2 THEN 1 ELSE @DoNotSplit END);
	
	-- Create backup TSQL
	SET @Backup = @PATH + REPLACE(REPLACE(@DB,'[',''),']','') + '.bak';	
	SET @Query =	'BACKUP DATABASE [' + @DB + '] TO DISK = N' 
					+ (CASE	WHEN @DoNotSplit =1 then QUOTENAME(@Backup, '''')
							ELSE QUOTENAME((REPLACE(@Backup,'.bak','_split_1.bak')), '''')
							END); 
	WHILE @FileSplitCount > 1
	BEGIN
		SET @upCount = @upCount+1;
		SET @Query = @Query + ', DISK = N' + QUOTENAME((REPLACE(@Backup,'.bak',('_split_'+CONVERT(varchar(12),@upCount)+'.bak'))), '''') 
		SET @FileSplitCount = @FileSplitCount-1;
	END;
	SET @Query = @Query
					+ ' WITH FORMAT, INIT, NAME = N' + QUOTENAME((@DB+'-Full Database Backup'), '''') 
					+ ', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10'
					+ @CopyOption;

	-- Execute backup
	DBCC TRACEON (3605, -1);
	DBCC TRACEON (3213, -1);
	EXEC(@Query);
	DBCC TRACEOFF(3605, -1);
	DBCC TRACEOFF(3213, -1);

END

