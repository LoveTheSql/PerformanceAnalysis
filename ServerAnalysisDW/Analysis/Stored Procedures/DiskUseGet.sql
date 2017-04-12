-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[DiskUseGet] 
@Instance VARCHAR(30) = @@ServerName,
@SearchDate DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @SearchDate = (CASE WHEN @SearchDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @SearchDate END);

	SELECT 
		 [DriveName] 
					 --+ ' ' + [VolumeName] 
					 AS [DriveName]
		,[Size]
		,[FreeSpace]
	FROM [Analysis].[DiskUsage]
	WHERE [ServerName] = @Instance
	AND CONVERT(DATE, [PerfDate]) = @SearchDate
	ORDER BY DriveName ASC, PerfDate ASC;

	SET TRAN ISOLATION LEVEL READ COMMITTED;

END
