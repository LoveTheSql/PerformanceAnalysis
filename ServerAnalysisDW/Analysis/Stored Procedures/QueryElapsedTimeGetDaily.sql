
-- =============================================
-- Author:		David Speight
-- =============================================
CREATE PROCEDURE [Analysis].[QueryElapsedTimeGetDaily] 
@ServerName NVARCHAR(50),
@DatabaseName NVARCHAR(50) = NULL,
@EndDate DATETIME = NULL,
@DaysBack INT = 10
AS
BEGIN

	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @EndDate = (CASE WHEN @EndDate IS NULL THEN (GETDATE()) ELSE @EndDate END);
	SELECT @DatabaseName = (CASE WHEN LEFT(@DatabaseName,3) = '---' THEN NULL ELSE @DatabaseName END);

	DECLARE @DateKey INT = CONVERT(INT,(CONVERT(VARCHAR(10), @EndDate,112)));
	DECLARE @DateKeyPrevious INT = CONVERT(INT,(CONVERT(VARCHAR(10), DATEADD(DAY,(0-@DaysBack),@EndDate),112)));
	
	WITH cteDATA AS (
									SELECT ([DatabaseName] +'..' + [Object_Name]) AS [Object_Name],  
									RANK() OVER (PARTITION BY [Object_Name] ORDER BY DateKey) [Rank],
									DateKey, 
									SUM(Total_Seconds) [Total_Seconds], 
									SUM(Execution_Count) [Execution_Count]
									FROM	ServerAnalysisDW.Analysis.QueryElapsedTime
									WHERE	[ServerName] = @ServerName
										AND	(@DatabaseName IS NULL OR [DatabaseName] = @DatabaseName)
										AND (DateKey BETWEEN @DateKeyPrevious AND @DateKey)
										AND ([Object_Name] <> 'QueryElapsedTimeRecord') -- Do not count this sproc
									GROUP BY [DatabaseName], [Object_Name], DateKey
									),

		cteDATAadd AS (
									SELECT TOP 10000 [Object_Name], Rank, DateKey, Total_Seconds, Execution_Count
											, LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], DateKey) AS [Total_Seconds_Lag]
											, [Analysis].[NegToZero]((Total_Seconds - LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], DateKey))) AS [Total_Seconds_Diff]
											, LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], DateKey) AS [Execution_Count_Lag]
											, [Analysis].[NegToZero]((Execution_Count - LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], DateKey))) AS [Total_Count]
											, ISNULL([Analysis].[NegToZero]((Total_Seconds - LAG(Total_Seconds,1,0) OVER (ORDER BY [Object_Name], DateKey))),0) / NULLIF([Analysis].[NegToZero]((Execution_Count - LAG(Execution_Count,1,0) OVER (ORDER BY [Object_Name], DateKey))),0) AS [Average_Seconds]
									FROM	cteDATA
									GROUP BY [Object_Name], [Rank], DateKey, Total_Seconds, Execution_Count
									ORDER BY 1,2,3
				)
	
		SELECT
				[Object_Name], DateKey, 
				CONVERT(INT,SUM(Total_Seconds_Diff)) AS TotalSeconds, SUM(Total_Count) AS TotalCount,
				(SUM(Total_Seconds_Diff)/SUM(Total_Count)) [Average_Seconds]
		FROM cteDATAadd
		WHERE Total_Count > 0 AND rank > 1
		GROUP BY [Object_Name], DateKey
		HAVING  CONVERT(INT,SUM(Total_Seconds_Diff)) > 0
		ORDER BY 1,2,3;

END