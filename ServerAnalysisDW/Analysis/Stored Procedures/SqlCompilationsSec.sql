-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[SqlCompilationsSec]
@ServerName NVARCHAR(50),
@EndDate DATETIME = NULL,
@MinutesBack INT = 60
AS
BEGIN
	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

    SELECT @EndDate = (CASE WHEN @EndDate IS NULL THEN (GETDATE()) ELSE @EndDate END);
	DECLARE @StartDate DATETIME = DATEADD(MINUTE, 0-@MinutesBack, @EndDate);


	SELECT	LEFT(REPLACE(CONVERT(VARCHAR(10), PerfDate, 108),':',''),4) AS [TimeKey], 
			CONVERT(INT,SQLCompSec) [SQLCompSec]
	FROM Analysis.InstanceStats
	WHERE	[ServerNm] = @ServerName
		AND PerfDate BETWEEN @StartDate AND @EndDate;

	SET TRAN ISOLATION LEVEL READ COMMITTED;
END
