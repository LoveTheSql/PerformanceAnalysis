-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Analysis].[QueryElapsedTimeRecord]
AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;
	SET DEADLOCK_PRIORITY LOW;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;
		INSERT INTO [ServerAnalysis].[Analysis].[QueryElapsedTime]
		([ServerName],[DatabaseName],[DateKey],[TimeKey],[Object_Name],[Total_Seconds],[Execution_Count],[Query])
		SELECT TOP 100
			@@SERVERNAME,
			DB_NAME(qt.dbid),
			CONVERT(VARCHAR(10), GETDATE(),112) [DateKey],
			LEFT((REPLACE(CONVERT(VARCHAR(10), GETDATE(),108),':','')),3)+'000' [TimeKey],
			o.name AS [object_name],
			qs.total_elapsed_time / 1000000.0 AS total_seconds,
			qs.execution_count,
			SUBSTRING (qt.text,qs.statement_start_offset/2, 
						(CASE	WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
								ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS individual_query
		FROM	sys.dm_exec_query_stats qs
				CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
				LEFT OUTER JOIN sys.objects o ON qt.objectid = o.object_id
		WHERE	qt.dbid = DB_ID()
			AND qs.last_execution_time > DATEADD(day, -1,GETDATE())
		ORDER BY (qs.total_elapsed_time / qs.execution_count / 1000000.0) DESC;
	COMMIT;
	SET TRAN ISOLATION LEVEL READ COMMITTED;
	RETURN 0;

END
