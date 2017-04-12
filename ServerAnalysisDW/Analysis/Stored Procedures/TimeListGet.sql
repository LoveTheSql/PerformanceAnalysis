-- =============================================
-- Author:		David Speight
-- Create date: August 15, 2016
-- Description:	Pull performance stats on an individual object
-- =============================================
CREATE PROCEDURE [Analysis].[TimeListGet] 
AS
BEGIN

	SET NOCOUNT ON;

    declare @timeTable TABLE (TimeKey int, TimeHour int, TimeText varchar(12))
	insert into @timeTable (TimeKey,TimeHour,TimeText)
	values	(0,0,'12:00 AM'),
			(10000,1,'1:00 AM'),
			(20000,2,'2:00 AM'),
			(30000,3,'3:00 AM'),
			(40000,4,'4:00 AM'),
			(50000,5,'5:00 AM'),
			(60000,6,'6:00 AM'),
			(70000,7,'7:00 AM'),
			(80000,8,'8:00 AM'),
			(90000,9,'9:00 AM'),
			(100000,10,'10:00 AM'),
			(110000,11,'11:00 AM'),
			(120000,12,'12:00 PM'),
			(130000,13,'1:00 PM'),
			(140000,14,'2:00 PM'),
			(150000,15,'3:00 PM'),
			(160000,16,'4:00 PM'),
			(170000,17,'5:00 PM'),
			(180000,18,'6:00 PM'),
			(190000,19,'7:00 PM'),
			(200000,20,'8:00 PM'),
			(210000,21,'9:00 PM'),
			(220000,22,'10:00 PM'),
			(230000,23,'11:00 PM'),
			(235959,23,'11:59 PM');

	select TimeKey,TimeHour,TimeText
	from @timeTable
	order by TimeKey;


END
