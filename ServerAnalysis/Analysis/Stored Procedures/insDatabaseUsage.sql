
CREATE PROCEDURE [Analysis].[insDatabaseUsage]
		   (@ServerNm	varchar(30)=NULL
		   ,@PerfDate	DATETIME = NULL
		   ,@DBName	varchar(30)=NULL
		   ,@Collation	varchar(30)=NULL
		   ,@Compat	varchar(30)=NULL
		   ,@Shrink	varchar(5)=NULL
		   ,@Recovery	varchar(30)=NULL
		   ,@Size	float=NULL
		   ,@Available	float=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[DatabaseUsage]
           ([PerfDate]
           ,[ServerName]
           ,[DatabaseName]
           ,[Collation]
           ,[CompatibilityLevel]
           ,[AutoShrink]
           ,[RecoveryModel]
           ,[Size]
           ,[SpaceAvailable])
     VALUES
           (@PerfDate
           ,@ServerNm
           ,@DBName
           ,@Collation
           ,@Compat
           ,@Shrink
           ,@Recovery
           ,@Size
           ,@Available)


