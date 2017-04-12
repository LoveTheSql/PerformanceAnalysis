-- =============================================
-- Author:		DS
-- =============================================
CREATE PROCEDURE [dbo].[JobCountsGet]
@TopCount int = 30
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Date INT
		
	SET @Date = CAST(REPLACE(CONVERT(VARCHAR(10),GETDATE(),120),'-','') AS INT) 
		
	SELECT @Date AS JobDate,
			COUNT(1) AS Counter,
			SUM(CASE WHEN run_status = 0 THEN 1 ELSE 0 END) AS Failed,
			SUM(CASE WHEN run_status = 1 THEN 1 ELSE 0 END) AS Succeeded,
			SUM(CASE WHEN run_status = 2 THEN 1 ELSE 0 END) AS Retry,
			SUM(CASE WHEN run_status = 3 THEN 1 ELSE 0 END) AS Canceled
	FROM msdb..sysjobhistory H (NOLOCK)
	WHERE step_id = 0 AND run_date = @Date

	UNION ALL

	SELECT TOP(@TopCount) JobDate,JobCount,JobFailed,JobSucceeded,JobRetry,JobCanceled
	FROM dbo.JobCounter
	ORDER BY 1 DESC

END

