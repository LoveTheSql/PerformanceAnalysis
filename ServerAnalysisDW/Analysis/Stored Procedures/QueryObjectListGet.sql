-- =============================================
-- Author:		David Speight
-- Create date: August 15, 2016
-- Description:	Pull performance stats on an individual object
-- =============================================
CREATE PROCEDURE [Analysis].[QueryObjectListGet] 
@ServerName varchar(50),
@DatabaseName varchar(50),
@DateStart date,
@DateEnd date
AS
BEGIN

	SET NOCOUNT ON;

    set transaction isolation level read uncommitted;

	declare @DateKeyStart int=CONVERT(VARCHAR(10), @DateStart,112);
	declare @DateKeyEnd int=CONVERT(VARCHAR(10), @DateEnd,112);

	select  DISTINCT [Object_Name]
	from [Analysis].[QueryElapsedTime]
	where	ServerName=@ServerName
		and	DatabaseName=@DatabaseName
		and Datekey between @DateKeyStart and  @DateKeyEnd
	order by [Object_Name]

	set transaction isolation level read committed;

END
