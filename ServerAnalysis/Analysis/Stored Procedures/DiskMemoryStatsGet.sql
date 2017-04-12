-- =============================================
-- Author:		Compiled by David Speight from SQL Central Sources
-- =============================================
CREATE PROCEDURE [Analysis].[DiskMemoryStatsGet]
AS
BEGIN

	SET NOCOUNT ON;
	-- Transaction Rate, Paging Rate, LogFlushesSec, LogBytesFlushSec
	DECLARE @TransactionRate BIGINT,@PagingRate BIGINT,@LogBytesFlushedSec BIGINT,@LogFlushesSec BIGINT;
	DECLARE @signal_wait_time_ms BIGINT, @wait_time_ms BIGINT;
	DECLARE @ProcureCacheRatio DECIMAL(10,4);
	DECLARE @SignalWaits DECIMAL(10,4);

	-- Procedure Cache Ratio
	;
	WITH    cte1
          AS ( SELECT [dopc].[object_name] ,
                    [dopc].[instance_name] ,
                    [dopc].[counter_name] ,
                    [dopc].[cntr_value] ,
                    [dopc].[cntr_type] ,
                    ROW_NUMBER() OVER ( PARTITION BY [dopc].[object_name], [dopc].[instance_name] ORDER BY [dopc].[counter_name] ) AS r_n
                FROM [sys].[dm_os_performance_counters] AS dopc
                WHERE [dopc].[counter_name] LIKE '%Cache Hit Ratio%'
                    AND ( [dopc].[object_name] LIKE '%Plan Cache%'
                          OR [dopc].[object_name] LIKE '%Buffer Cache%'
                        )
                    AND [dopc].[instance_name] LIKE '%_Total%'
             )
	SELECT @ProcureCacheRatio = (	SELECT CONVERT(DECIMAL(16, 2), ( [c].[cntr_value] * 1.0 / [c1].[cntr_value] ) * 100.0) AS [hit_pct]
								FROM [cte1] AS c
									INNER JOIN [cte1] AS c1
										ON c.[object_name] = c1.[object_name]
										   AND c.[instance_name] = c1.[instance_name]
								WHERE [c].[r_n] = 1
									AND [c1].[r_n] = 2);

	------- First sampling at 0 seconds -------
		SELECT @TransactionRate = SUM(cntr_value)
			FROM sys.dm_os_performance_counters
			WHERE counter_name = 'transactions/sec'
				AND object_name = 'SQLServer:Databases'
				AND instance_name IN (select name from master.sys.databases)
				AND instance_name NOT IN ('master','tempdb','model','msdb','SSISDB','ReportServer','ReportServerTempDB');
;     -- Databases to monitor this could be revised to query a list from a table
		SELECT @PagingRate = SUM(io1.io_stall)
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) io1;
		SELECT @LogFlushesSec = SUM(cntr_value)
		FROM sys.dm_os_performance_counters
		WHERE counter_name ='Log Flushes/sec';
		SELECT @LogBytesFlushedSec = SUM(cntr_value)
		FROM sys.dm_os_performance_counters
		WHERE counter_name ='Log Bytes Flushed/sec';

		SELECT @signal_wait_time_ms = SUM(signal_wait_time_ms)
		FROM sys.dm_os_wait_stats
		SELECT @wait_time_ms = SUM(wait_time_ms)
		FROM sys.dm_os_wait_stats;

	WAITFOR DELAY '00:00:01';

	------- second sampling at 1 second -------
		SELECT @TransactionRate = SUM(cntr_value) - @TransactionRate
			FROM sys.dm_os_performance_counters
			WHERE counter_name = 'transactions/sec'
				AND object_name = 'SQLServer:Databases'
				AND instance_name IN ('MyDB1','MyDB2');     -- Databases to monitor this could be revised to query a list from a table
		SELECT @PagingRate = SUM(io1.io_stall) - @PagingRate
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) io1;
		SELECT @LogFlushesSec = SUM(cntr_value) - @LogFlushesSec
		FROM sys.dm_os_performance_counters
		WHERE counter_name ='Log Flushes/sec';
		SELECT @LogBytesFlushedSec = SUM(cntr_value)-@LogBytesFlushedSec
		FROM sys.dm_os_performance_counters
		WHERE counter_name ='Log Bytes Flushed/sec';

		SELECT @signal_wait_time_ms = SUM(signal_wait_time_ms) - @signal_wait_time_ms
		FROM sys.dm_os_wait_stats
		SELECT @wait_time_ms = SUM(wait_time_ms) - @wait_time_ms
		FROM sys.dm_os_wait_stats;

	SELECT @SignalWaits = (SELECT CAST(100.0 * @signal_wait_time_ms / NULLIF(@wait_time_ms,0) AS DECIMAL(10,4)));

	INSERT INTO [Analysis].[DiskMemoryStats]
	(ServerNm, DateKey, TimeKey, TransactionRateSec, MemoryPagingRateSec, LogFlushesSec, LogBytesFlushedSec, ProcedureCacheRatio, SignalWaitPercent)
	SELECT @@SERVERNAME [ServerNm],
			CONVERT(VARCHAR(10), GETDATE(),112) [DateKey],
			LEFT((REPLACE(CONVERT(VARCHAR(10), GETDATE(),108),':','')),3)+'000' [TimeKey],
			CONVERT(INT, @TransactionRate) [TransactionRate],
			CONVERT(INT, @PagingRate) [MemoryPagingRateSec],
			CONVERT(INT, @LogFlushesSec) [LogFlushesSec],
			CONVERT(INT, @LogBytesFlushedSec) [LogBytesFlushedSec],
			@ProcureCacheRatio [ProcedureCacheRatio],
			@SignalWaits [SignalWaitPercent];

END
