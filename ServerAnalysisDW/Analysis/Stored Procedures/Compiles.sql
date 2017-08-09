
-- =============================================
-- Author:		David Speight
-- =============================================
CREATE PROCEDURE [Analysis].[Compiles] 
@ServerName VARCHAR(50),
@EndDate DATETIME,
@MinutesBack INT = 60
AS
BEGIN
	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

    SELECT @EndDate = (CASE WHEN @EndDate IS NULL THEN (GETDATE()) ELSE @EndDate END);
	
	
		SELECT  
			SUM(SQLCompSec)/COUNT(*) AS SQLcompSec, 
			SUM(BatReqSec)/COUNT(*) AS BatReqSec,
			SUM(SQLRcmpSec)/COUNT(*) AS SQLRcmpSec,
			CONVERT(INT,( (SUM(BatReqSec)/COUNT(*)) / (SUM(SQLCompSec)/COUNT(*)) )) AS CompileRatio,
			CONVERT(INT,((SUM(SQLRcmpSec)/COUNT(*))/(SUM(SQLCompSec)/COUNT(*)))*100) AS ReCompileRatio
		FROM [Analysis].[InstanceStats]
		WHERE ServerNm = @ServerName
			AND PerfDate BETWEEN DATEADD(MINUTE,(0-@MinutesBack),@EndDate) AND @EndDate;

END