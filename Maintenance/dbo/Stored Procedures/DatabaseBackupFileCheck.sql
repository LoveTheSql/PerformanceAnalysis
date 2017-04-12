-- =============================================
-- Author:		David Speight
-- =============================================
CREATE PROCEDURE [dbo].[DatabaseBackupFileCheck]
@DirectoryBase varchar(150) = ''
AS
BEGIN

	SET NOCOUNT ON;

	declare @Weekday varchar(20) = DATENAME(dw,GETDATE());
	declare @FileList table (ID int IDENTITY(1,1), DatabaseName varchar(50), InstanceName varchar(50), Found bit NULL);
	declare @DirectoryList table (ID int IDENTITY(1,1), Directory varchar(250));
	declare @PhysicalFileList table (ID int IDENTITY(1,1), Directory varchar(250),FileDate date, FileMetaData varchar(500));
	declare @temptable table (RawData nvarchar(400));
	declare @curDirectory varchar(250);
	declare @curDatabaseName varchar(50);
	declare @cmdPath varchar(600)
	declare @DirectoryCount int;
	declare @FileListCount int;
	declare @iDir int=0;
	declare @iFList int=0;

	-- Get list of active files on watch
	Insert into @FileList
	(DatabaseName,InstanceName,Found)
	Select DatabaseName,InstanceName,0
	From [dbo].[FileLists]
	where isactive=1
	Order by InstanceName, DatabaseName;

	select @FileListCount = count(*) from @FileList;

	-- Create a table of directories
	Insert into @DirectoryList
	(Directory)
	SELECT DISTINCT ( @DirectoryBase+@Weekday+'\'+InstanceName+'\')
	FROM @FileList;

	select @DirectoryCount= Count(*) FROM @DirectoryList;

	-- create a table with the physical files and their dates
	while @iDir < @DirectoryCount
	begin
		set @iDir = @iDir+1;
		select		@cmdPath = 'dir '+Directory,
					@curDirectory = Directory 
		from @DirectoryList
		where ID = @iDir;

		Insert into @temptable
		EXEC xp_cmdshell @cmdPath;

		delete from @temptable 
		where ISNUMERIC(left(RawData,2))=0;

		insert into @PhysicalFileList
		(Directory,FileDate,FileMetaData)
		Select	@curDirectory,
				CONVERT(Date,left(RawData,20)) [Date],
				RTRIM(LTRIM(RIGHT(RawData,LEN(RawData)-20))) [Line]
		from @temptable;	

		select @curDirectory = '', @cmdPath=''
		delete from @temptable ;
	end

	-- update valid file list
	while @iFList < @FileListCount
	begin
		set @iFList = @iFList+1;
		select	@curDatabaseName = DatabaseName,
				@curDirectory = InstanceName
		From @FileList
		where ID = @iFList;

		Update @FileList
		set Found = 	
						(Select COUNT(*) 
						from @PhysicalFileList 
						where		(Directory like '%'+@curDirectory+'%') 
								and (FileMetaData like '%'+@curDatabaseName+'%')
								and (FileDate = convert(Date,(getdate()))))
						
		where ID = @iFList;
	
		select @curDatabaseName='', @curDirectory='';
	end

	select 'Total file count' [InstanceName], CONVERT(varchar(50),COUNT(*)) [DatabaseName]
	from @FileList
	UNION
	select InstanceName, DatabaseName
	from @FileList where found <> 1;

END
