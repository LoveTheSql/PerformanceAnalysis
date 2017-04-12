-- =============================================
-- Author:		DS
-- =============================================
CREATE PROCEDURE [Analysis].[ServerStatsProcPercent] 
@ServerName NVARCHAR(50),
@EndDate DATETIME = NULL,
@MinutesBack INT = 60
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @EndDate = (CASE WHEN @EndDate IS NULL THEN (GETDATE()) ELSE @EndDate END);

	SELECT	CONVERT(INT,CONVERT(VARCHAR(10), PerfDate, 112)) [PerfCalendar],
			CONVERT(INT,LEFT(REPLACE(CONVERT(VARCHAR(10), PerfDate, 108),':',''),4)) [PerfClock],
			[PctProc]
	FROM [ServerAnalysisDW].[Analysis].[ServerStats]
	WHERE PerfDate BETWEEN DATEADD(minute, 0-@MinutesBack, @EndDate) AND @EndDate
	AND ServerNm = @ServerName;

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

END
