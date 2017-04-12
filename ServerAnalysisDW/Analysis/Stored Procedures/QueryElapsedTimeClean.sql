-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[QueryElapsedTimeClean]
@MonthsToKeep INT = 2
AS
BEGIN

 DELETE 
 FROM [Analysis].[QueryElapsedTime]
 WHERE DateKey < CONVERT(INT,(CONVERT(VARCHAR(10), DATEADD(MONTH,(0-@MonthsToKeep),GETDATE()),112)));

 DELETE
 FROM [Analysis].[DatabaseUsage]
 WHERE PerfDate < DATEADD(MONTH,(0-@MonthsToKeep),GETDATE());

 DELETE 
 FROM [Analysis].[DiskMemoryStats]
 WHERE DateKey < CONVERT(INT,(CONVERT(VARCHAR(10), DATEADD(MONTH,(0-@MonthsToKeep),GETDATE()),112)));

 DELETE
 FROM [Analysis].[DiskUsage]
 WHERE PerfDate < DATEADD(MONTH,(0-@MonthsToKeep),GETDATE());

 DELETE 
 FROM [Analysis].[InstanceMemory]
 WHERE DateKey < CONVERT(INT,(CONVERT(VARCHAR(10), DATEADD(MONTH,(0-@MonthsToKeep),GETDATE()),112)));

 DELETE
 FROM [Analysis].[InstanceStats]
 WHERE PerfDate < DATEADD(MONTH,(0-@MonthsToKeep),GETDATE());

 DELETE
 FROM [Analysis].[ServerStats]
 WHERE PerfDate < DATEADD(MONTH,(0-@MonthsToKeep),GETDATE());

 
END
