-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[ProcedureCacheRatio]  
@ServerName NVARCHAR(50),
@EndDate DATETIME = NULL,
@MinutesBack INT = 60
AS
BEGIN

	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

    SELECT @EndDate = (CASE WHEN @EndDate IS NULL THEN (GETDATE()) ELSE @EndDate END);
	DECLARE @TimeKey INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), @EndDate,108),':','')),3)+'000'));
    DECLARE @DateKey INT = CONVERT(INT,(CONVERT(VARCHAR(10), @EndDate,112)));
	DECLARE @TimeKeyPrevious INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), DATEADD(MINUTE,(0-@MinutesBack),@EndDate),108),':','')),3)+'000'));
	DECLARE @DateKeyPrevious INT = CONVERT(INT,(CONVERT(VARCHAR(10), DATEADD(MINUTE,(0-@MinutesBack),@EndDate),112)));
	DECLARE @RAMmb INT = ISNULL((SELECT ISNULL(RAMmb,1) FROM Analysis.Server WHERE ServerNm = @ServerName),1);

	SELECT	CONVERT(INT,(CASE	WHEN LEN(TimeKey) = 6 THEN LEFT(TimeKey,4)
					ELSE LEFT(TimeKey,3) END)) AS [TimeKey], 
			CONVERT(INT,ProcedureCacheRatio) [ProcedureCacheRatio]
	FROM Analysis.DiskMemoryStats
	WHERE	[ServerNm] = @ServerName
		AND DateKey BETWEEN @DateKeyPrevious AND @DateKey
		AND TimeKey BETWEEN @TimeKeyPrevious AND @TimeKey;

	SET TRAN ISOLATION LEVEL READ COMMITTED;

END
