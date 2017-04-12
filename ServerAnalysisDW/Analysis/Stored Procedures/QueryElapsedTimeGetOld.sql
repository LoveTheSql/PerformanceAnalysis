-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[QueryElapsedTimeGetOld] 
@ServerName NVARCHAR(50),
@DatabaseName NVARCHAR(50) = NULL,
@EndDate DATETIME = NULL,
@MinutesBack INT = 60
AS
BEGIN

		SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @EndDate = (CASE WHEN @EndDate IS NULL THEN (GETDATE()) ELSE @EndDate END);
	SELECT @DatabaseName = (CASE WHEN LEFT(@DatabaseName,3) = '---' THEN NULL ELSE @DatabaseName END);

	DECLARE @TimeKey INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), @EndDate,108),':','')),3)+'000'));
    DECLARE @DateKey INT = CONVERT(INT,(CONVERT(VARCHAR(10), @EndDate,112)));
	-- Get data and time from 10 minutes ago.
	DECLARE @TimeKeyPrevious INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), DATEADD(MINUTE,(0-@MinutesBack),@EndDate),108),':','')),3)+'000'));
	DECLARE @DateKeyPrevious INT = CONVERT(INT,(CONVERT(VARCHAR(10), DATEADD(MINUTE,(0-@MinutesBack),@EndDate),112)));

	SELECT	[Object_Name], 
			[Rank]-1 AS [Rank],
			DateKey, 
			CONVERT(INT,(CASE	WHEN LEN(TimeKey) = 6 THEN LEFT(TimeKey,4)
					ELSE LEFT(TimeKey,3) END)) AS [TimeKey],
			SUM(ISNULL([Total_Seconds_Diff],0)) AS [Total_Seconds_Diff],
			SUM(ISNULL([Execution_Count_Diff],0)) AS [Total_Count],
			SUM(ISNULL([Total_Seconds_Diff],0)) / SUM(NULLIF([Execution_Count_Diff],0))
			--ISNULL([ElapsedTime],0) 
			AS [Average_Seconds]
	FROM (
	SELECT	([DatabaseName] +'..' + [Object_Name]) AS [Object_Name],  
	RANK() OVER (PARTITION BY [Object_Name], Query ORDER BY DateKey, TimeKey) [Rank],
	DateKey, TimeKey, Total_Seconds, Execution_Count, Query,
	LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], Query, DateKey, TimeKey) AS [Total_Seconds_Lag],	
	[Analysis].[NegToZero]((Total_Seconds - LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], Query, DateKey, TimeKey))) AS [Total_Seconds_Diff],
	LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], Query, DateKey, TimeKey) AS [Execution_Count_Lag],
	[Analysis].[NegToZero]((Execution_Count - LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], Query, DateKey, TimeKey))) AS [Execution_Count_Diff],
	([Analysis].[NegToZero]((Total_Seconds - LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], Query, DateKey, TimeKey)))) / NULLIF(([Analysis].[NegToZero]((Execution_Count - LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], Query, DateKey, TimeKey)))),0) AS [ElapsedTime]
	FROM	ServerAnalysisDW.Analysis.QueryElapsedTime
	WHERE	[ServerName] = @ServerName
		AND	(@DatabaseName IS NULL OR [DatabaseName] = @DatabaseName)
		AND (DateKey BETWEEN @DateKeyPrevious AND @DateKey)
		AND (TimeKey BETWEEN @TimeKeyPrevious AND @TimeKey)
		AND ([Object_Name] <> 'QueryElapsedTimeRecord') -- Do not count this sproc

	) a
	WHERE (a.[Rank] > 1) AND (a.Total_Seconds_Diff > 0.0001) 
	GROUP BY [Object_Name], 
			[Rank]-1,
			DateKey,
			CONVERT(INT,(CASE	WHEN LEN(TimeKey) = 6 THEN LEFT(TimeKey,4)
					ELSE LEFT(TimeKey,3) END))
	HAVING (SUM(ISNULL([Execution_Count_Diff],0)) > 100 OR SUM(ISNULL([Total_Seconds_Diff],0)) > 0.1) AND (SUM(ISNULL([Execution_Count_Diff],0)) > 0)
	ORDER BY [Object_Name], DateKey, TimeKey;

	SET TRAN ISOLATION LEVEL READ COMMITTED;

END


