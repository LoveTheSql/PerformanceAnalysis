-- =============================================
-- Author:		David Speight
-- Create date: August 15, 2016
-- Description:	Pull performance stats on an individual object
-- =============================================
CREATE PROCEDURE [Analysis].[QueryStatsGetOnObject] 
@ServerName varchar(50),
@DatabaseName varchar(50),
 @Object_Name varchar(50),
@DateStart date,
@DateEnd date,
@HourStart int=90000,
@HourEnd int = 170000,
@ExcludeWeekend int =1
AS
BEGIN

	SET NOCOUNT ON;

    set transaction isolation level read uncommitted;

	declare @DateKeyStart int=CONVERT(VARCHAR(10), @DateStart,112);
	declare @DateKeyEnd int=CONVERT(VARCHAR(10), @DateEnd,112);

	select  qt.DateKey, CONVERT(DATE,CONVERT(varchar(8),qt.DateKey)) [StatDate],
			(Convert(varchar(50),qt.DateKey) + ' (' + Convert(varchar(50),SUM(qt.Execution_Count)) + ') ') [DateKeyText],
			SUM(qt.Execution_Count) [Executions], 			
			CONVERT(INT,(SUM(qt.Total_Seconds)/60)) [TotalWaitTime]
	from [Analysis].[QueryElapsedTime] qt
		INNER JOIN [Maintenance].[dbo].[DimDate] dt ON qt.Datekey = dt.Datekey
	where	qt.ServerName=@ServerName
		and	qt.DatabaseName=@DatabaseName
		and qt.[Object_Name]=@Object_Name
		and qt.Datekey between @DateKeyStart and  @DateKeyEnd
		and qt.Timekey between @HourStart and  @HourEnd
		and (@ExcludeWeekend=0 OR dt.IsWeekday=1)
	Group By qt.DateKey
	order by qt.Datekey;

	set transaction isolation level read committed;

END
