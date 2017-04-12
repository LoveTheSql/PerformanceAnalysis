CREATE PROCEDURE [dbo].[DBRestoreSplit]
	@DatabaseName VARCHAR(100), 
	@RestoreFromPath varchar(250),		-- 'D:\MSSQL\Backup\'  Backup Location. 
	@RestoreToPathData varchar(250),	-- 'D:\MSSQL\Data\'    Path where the database will be restored
	@RestoreToPathLog varchar(250),		-- 'D:\MSSQL\Log\'
	@DropExistingDatabase bit = 0		-- Set to 1 if multiple files is expected
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query VARCHAR(4000);
	DECLARE @curFileName VARCHAR(100);
	DECLARE @FileCount INT;
	DECLARE @FileGroupCount INT;
	DECLARE @LoopCount1 INT=0;
	DECLARE @LoopCount2 INT=0;
	DECLARE @isLog BIT = 0;

	-- Get list of files for the backup. This assumes ALL backup files are in the same directory.
	declare @cmdPath varchar(280) = 'dir ' + @RestoreFromPath + ' /b'
	declare @files table (ID int IDENTITY, FileName varchar(100))
	declare @files2 table (ID int IDENTITY, FileName varchar(100))
	insert into @files execute xp_cmdshell @cmdPath;
	delete from @files
	where ([FileName] not like @DatabaseName+'_'+'%' or [FileName] <> @DatabaseName+'.bak') or ([FileName] is null);
	
	-- Reset ID counter for remaining entries
	insert into @files2 (FileName)
	SELECT filename
	From @files
	Order by ID;

	select  @FileCount = count(*)
	from @files2;
	
	-- Drop Database if it already exists in the destination.
	IF @DropExistingDatabase =1 and EXISTS(SELECT * FROM master.dbo.sysdatabases WHERE name = @DatabaseName) 
	BEGIN
		SET @Query = 'DROP DATABASE ' + @DatabaseName
		EXEC (@Query)
	END;

	-- Peek into first Backup file to get paramaters needed.
	DECLARE @Backup VARCHAR(500);
	SELECT @Backup = @RestoreFromPath + FileName
	From @files2
	Where ID = 1;

	SET @Query = 'RESTORE FILELISTONLY FROM DISK = ' + QUOTENAME(@Backup , '''')

	DECLARE @Temp as TABLE
	(ID int IDENTITY(1,1),
	LogicalName VARCHAR(100),
	PhysicalName VARCHAR(100),
	Type VARCHAR(1),
	FileGroupName VARCHAR(50) ,
	Size BIT ,
	MaxSize BIGINT,
	FileID INT,
	CreateLSN VARCHAR(100),
	DropLSN VARCHAR(100),
	UniqueID UNIQUEIDENTIFIER,
	ReadOnlyLSN BIT,
	ReadWriteLSN BIT,
	BackupSizeInBytes BIGINT,
	SourceBlockSize INT,
	FileGroupID INT,
	LogGroupGUID UNIQUEIDENTIFIER,
	DifferentialBaseLSN VARCHAR(100),
	DifferentialBaseGUID UNIQUEIDENTIFIER,
	IsReadOnly BIT,
	IsPresent BIT,
	TDEThumbprint VARCHAR(100)
	,SnapshotURL VARCHAR(100)		-- UNCOMMENT for SQL 2016
	)

	INSERT @Temp EXEC (@Query)
	select * from @Temp;

	select @FileGroupCount = COUNT(*) FROM @Temp;

	-- Complie the RESTORE query with multiple files and multiple filegroups as required.
	SET @Query = 'RESTORE DATABASE [' + @DatabaseName + '] FROM '
	
	WHILE @LoopCount1 < @FileCount
	BEGIN
		set  @LoopCount1 = @LoopCount1 + 1;
		select @curFileName = [FileName]
		FROM @files2 
		WHERE ID = @LoopCount1;
		SET @Query = @Query + 'DISK = ' + QUOTENAME((@RestoreFromPath+@curFileName), '''')
		SET @curFileName = ''
		SET @Query = @Query + (SELECT CASE WHEN @LoopCount1 < @FileCount THEN ', ' ELSE ' ' END);
	END;
	SET @Query = @Query + ' WITH ';

	WHILE @LoopCount2 < @FileGroupCount
	BEGIN
		set		@LoopCount2 = @LoopCount2 + 1;
		select	@curFileName = LogicalName,
				@isLog  = (Case when Type='L' Then 1 else 0 end)
		from @temp
		where ID = @LoopCount2;
		SELECT @Query = @Query	+ 'MOVE ' + QUOTENAME(@curFileName, '''') + ' TO '
								+ (CASE WHEN @isLog=1 THEN QUOTENAME((@RestoreToPathLog+@curFileName+'.ldf'), '''')
										ELSE QUOTENAME((@RestoreToPathData+@curFileName+'.mdf'), '''')
										END)
								+ ', ';
		SET @curFileName = '';
	END;
	SET @Query = @Query + ' REPLACE, NOUNLOAD, STATS = 10;';
	-- Executequery
	EXEC (@Query);
END

