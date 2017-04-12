-- =============================================
/* Author:	 Script to report Memory usage details of a SQL Server instance 
 Author: Sakthivel Chidambaram, Microsoft http://blogs.msdn.com/b/sqlsakthi 
 
 Date: June 2012 
 Version: V2 
 
 V1: Initial Release 
 V2: Added PLE, Memory grants pending, Checkpoint, Lazy write,Free list counters 
 */

-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Analysis].[InstanceMemoryGet]
AS
BEGIN

	SET NOCOUNT ON;
	 -- Get size of SQL Server Page in bytes 
	 DECLARE @pg_size INT, @Instancename varchar(50) 
	 SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E' 
 
	 -- Extract perfmon counters to a temporary table 
	 IF OBJECT_ID('tempdb..#perfmon_counters') is not null DROP TABLE #perfmon_counters 
	 SELECT * INTO #perfmon_counters FROM sys.dm_os_performance_counters 

	  -- Get SQL Server instance name 
	SELECT @Instancename = LEFT([object_name], (CHARINDEX(':',[object_name]))) FROM #perfmon_counters WHERE counter_name = 'Buffer cache hit ratio' 
 
	INSERT INTO [Analysis].[InstanceMemory]
	SELECT
		GETDATE(),
		CONVERT(VARCHAR(10), GETDATE(),112) [DateKey],
		LEFT((REPLACE(CONVERT(VARCHAR(10), GETDATE(),108),':','')),3)+'000' [TimeKey],
		CONVERT(VARCHAR(30),@@SERVERNAME),
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'Total Server Memory (KB)'),				--[KbMemoryUsedByBufferPool]
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'Target Server Memory (KB)'),			--[KbMemoryNeededPerCurrentWorkload]
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'Connection Memory (KB)'),				--[KbMemoryDynamicUsedForConnections]
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'Lock Memory (KB)'),						--[KbMemoryDynamicUsedForLocks]
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'SQL Cache Memory (KB)'),				--[KbMemoryDynamicUsedForCache]
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'Optimizer Memory (KB) '),				--[KbMemoryDynamicUsedForQueryOptimization]
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'Granted Workspace Memory (KB) '),		--[KbMemoryDynamicUsedForHashSortIndexOps]
		(SELECT cntr_value FROM #perfmon_counters WHERE counter_name = 'Cursor memory usage' and instance_name = '_Total'),				--[KbMemoryConsumedByCursors]
		(SELECT cntr_value FROM #perfmon_counters WHERE object_name= @Instancename+'Buffer Manager' and counter_name = 'Total pages'),	--[8kbPagesInBufferPool]
		(SELECT cntr_value FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Database pages'),--[8kbDataPagesInBufferPool]
		(SELECT cntr_value FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free pages'),	--[8kbFreePagesInBufferPool]
		(SELECT cntr_value FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Reserved pages'),--[8kbReservedPagesInBufferPool]
		(SELECT cntr_value FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Stolen pages'),	--[8kbStolenPagesInBufferPool]
		(SELECT cntr_value FROM #perfmon_counters WHERE object_name=@Instancename+'Plan Cache' and counter_name = 'Cache Pages' and instance_name = '_Total'),	--[8kbPlaCachePagesInBufferPool]
		(SELECT cntr_value FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Page life expectancy'), --[PageLifeExpectancy]    CASE WHEN (cntr_value > 300) THEN 'PLE is Healthy' ELSE 'PLE is not Healthy' END as 'PLE Status'
		(SELECT cntr_value as [Free list stalls/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free list stalls/sec'),			--[NumberRequestsSecWaitForFreePage]
		(SELECT cntr_value as [Checkpoint pages/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Checkpoint pages/sec'),			--[NumberPagesFlushedDiskSec]
		(SELECT cntr_value as [Lazy writes/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Lazy writes/sec'),						--[NumberBuffersWrittenSecByBufferMgrLazyWriter]
		(SELECT cntr_value as [Memory Grants Pending] FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Pending'),			--[MemoryGrantsPending] 
		(SELECT cntr_value as [Memory Grants Outstanding] FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Outstanding')	--[MemoryGrantsOutstanding]

END
