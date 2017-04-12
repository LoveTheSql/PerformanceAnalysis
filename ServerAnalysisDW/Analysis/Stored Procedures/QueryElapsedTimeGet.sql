-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[QueryElapsedTimeGet] 
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
										AND ([Object_Name] <> 'QueryElapsedTimeRecord') -- Do not count this sproc
										--AND (([Object_Name] <> 'GetCaseActivities') OR ([Object_Name] = 'GetCaseActivities' AND Execution_Count > 2) ) -- Hack for 2015-01-21 where 2 plans were in cache
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
		
		SELECT
				[Object_Name], DateKey, 
				(Case when CONVERT(INT,LEFT((TimeKey/100),2)) > 19 THEN '0' + LEFT((TimeKey/100),1)
							Else LEFT((TimeKey/100),2) END) 
							+':'+RIGHT((TimeKey/100),2) [TimeKey], 
				Total_Seconds_Diff, Total_Count,
				(Total_Seconds_Diff/Total_Count) [Average_Seconds]
		FROM cteDATAadd
		WHERE [Rank] > 1 AND Total_Seconds_Diff > 0.01 AND Total_Count > 0
		ORDER BY 1,2,3;
		
	SET TRAN ISOLATION LEVEL READ COMMITTED;

END


