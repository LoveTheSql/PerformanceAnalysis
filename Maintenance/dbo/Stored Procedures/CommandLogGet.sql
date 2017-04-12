-- =============================================
-- Author:		DS
-- =============================================
CREATE PROCEDURE [dbo].[CommandLogGet]
@StartDate DATETIME = NULL,
@FragmentationLimit INT = 0,
@ErrorOnly BIT = 0
AS
BEGIN

	SET NOCOUNT ON;

	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @StartDate = (CASE WHEN @StartDate IS NULL THEN DATEADD(WEEK, -1, (GETDATE())) ELSE @StartDate END);

	SELECT	@@SERVERNAME AS ServerName, 
			DatabaseName, 
			SchemaName, 
			ObjectName, 
			ObjectType, 
			IndexName, 
			IndexType, 
			StartTime, 
			ErrorNumber, 
            ExtendedInfo.value('(/ExtendedInfo/PageCount)[1]', 'varchar(15)') AS PageCount, 
			ExtendedInfo.value('(/ExtendedInfo/Fragmentation)[1]', 'varchar(15)') AS Fragmentation, 
            (CASE WHEN [Command] LIKE '%REBUILD%' THEN 'REBUILD' WHEN [Command] LIKE '%REORGANIZE%' THEN 'REORG' ELSE '' END) AS ActionType, 
			ErrorMessage
	FROM     CommandLog
	WHERE		(StartTime >= @StartDate)
			AND	(CONVERT(FLOAT, ExtendedInfo.value('(/ExtendedInfo/Fragmentation)[1]', 'varchar(15)')) > @FragmentationLimit)
			AND	(ErrorNumber > (CASE WHEN @ErrorOnly = 1 THEN 0 ELSE -1 END))
	ORDER BY Fragmentation DESC;

	SET TRAN ISOLATION LEVEL READ COMMITTED;

END
