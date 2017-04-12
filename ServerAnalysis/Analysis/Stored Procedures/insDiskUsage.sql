
CREATE PROCEDURE [Analysis].[insDiskUsage]
		   (@ServerNm	varchar(30)=NULL
		   ,@PerfDate	DATETIME = NULL
		   ,@VolName	varchar(30)=NULL
		   ,@Drive	varchar(5)=NULL
		   ,@Size	float=NULL
		   ,@Free	float=NULL
		   ,@Percent	float=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[DiskUsage]
           ([PerfDate]
           ,[ServerName]
           ,[VolumeName]
           ,[DriveName]
           ,[Size]
           ,[FreeSpace]
           ,[PercentFree])
     VALUES
           (@PerfDate
           ,@ServerNm
           ,@VolName
           ,@Drive
           ,@Size
           ,@Free
           ,@Percent)


