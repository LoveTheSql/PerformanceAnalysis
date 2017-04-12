-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[KPI_QueryElapsedTimeGet] 
@ServerName NVARCHAR(50),
@DatabaseName NVARCHAR(50),
@MinutesBack INT = 60,
@Goal INT = 600
AS
BEGIN

	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @EndDate DATETIME = (getdate());
	SELECT @MinutesBack = (CASE WHEN @MinutesBack > 10 then @MinutesBack+10 else 0 end);
	SELECT @DatabaseName = (CASE WHEN LEFT(@DatabaseName,3) = '---' THEN NULL ELSE @DatabaseName END); -- Get stats for all databases
	SELECT @Goal = (@Goal/(@MinutesBack/10)); 
	DECLARE @TimeKey INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), @EndDate,108),':','')),3)+'000'));
    DECLARE @DateKey INT = CONVERT(INT,(CONVERT(VARCHAR(10), @EndDate,112)));
	-- Get data and time from 10 minutes ago.
	DECLARE @TimeKeyPrevious INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), DATEADD(MINUTE,(0-@MinutesBack),@EndDate),108),':','')),3)+'000'));
	DECLARE @DateKeyPrevious INT = CONVERT(INT,(CONVERT(VARCHAR(10), DATEADD(MINUTE,(0-@MinutesBack),@EndDate),112)));

	WITH cteDATA AS (
									SELECT ([DatabaseName] +'..' + [Object_Name]) AS [Object_Name],  
									RANK() OVER (PARTITION BY [Object_Name] ORDER BY DateKey, TimeKey) [Rank],
									DateKey, 
									TimeKey, 
									SUM(Total_Seconds) [Total_Seconds], 
									SUM(Execution_Count) [Execution_Count]
									FROM	ServerAnalysisDW.Analysis.QueryElapsedTime
									WHERE	[ServerName] = @ServerName
										AND	(@DatabaseName IS NULL OR [DatabaseName] = @DatabaseName)
										AND (DateKey BETWEEN @DateKeyPrevious AND @DateKey)
										AND (TimeKey BETWEEN @TimeKeyPrevious AND @TimeKey)
									GROUP BY [DatabaseName], [Object_Name], DateKey, TimeKey
									),

		cteDATAadd AS (
									SELECT TOP 10000 [Object_Name], Rank, DateKey, TimeKey, Total_Seconds, Execution_Count
											, LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], DateKey, TimeKey) AS [Total_Seconds_Lag]
											, [Analysis].[NegToZero]((Total_Seconds - LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], DateKey, TimeKey))) AS [Total_Seconds_Diff]
											, LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], DateKey, TimeKey) AS [Execution_Count_Lag]
											, [Analysis].[NegToZero]((Execution_Count - LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], DateKey, TimeKey))) AS [Total_Count]
											, ISNULL([Analysis].[NegToZero]((Total_Seconds - LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], DateKey, TimeKey))),0) / NULLIF([Analysis].[NegToZero]((Execution_Count - LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], DateKey, TimeKey))),0) AS [Average_Seconds]
									FROM	cteDATA
									GROUP BY [Object_Name], [Rank], DateKey, TimeKey, Total_Seconds, Execution_Count
									ORDER BY 1,2,3
				)
		
		SELECT TOP ((@MinutesBack-10)/10)
				DateKey, 
				TimeKey, 
				CONVERT(INT,SUM(Total_Seconds_Diff)) TotalSeconds,
				(CASE	WHEN	(SUM(Total_Seconds_Diff)) > @GOAL+10 THEN -1
						WHEN	(SUM(Total_Seconds_Diff)) < @GOAL-10 THEN 1
						ELSE 0 END) AS KPIStatus
		FROM cteDATAadd
		WHERE [Rank] > 1 AND Total_Seconds_Diff > 0.01 AND Total_Count > 0
		GROUP BY DateKey,TimeKey
		ORDER BY DateKey DESC, 
				TimeKey DESC	
		
	SET TRAN ISOLATION LEVEL READ COMMITTED;

END
