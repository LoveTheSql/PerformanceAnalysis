
-- =============================================
-- Author:		David Speight
-- =============================================
CREATE PROCEDURE [Analysis].[PLE] 
@ServerName VARCHAR(50),
@EndDate DATETIME,
@MinutesBack INT = 60
AS
BEGIN
	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

    SELECT @EndDate = (CASE WHEN @EndDate IS NULL THEN (GETDATE()) ELSE @EndDate END);
	DECLARE @TimeKey INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), @EndDate,108),':','')),3)+'000'));
    DECLARE @DateKey INT = CONVERT(INT,(CONVERT(VARCHAR(10), @EndDate,112)));
	DECLARE @TimeKeyPrevious INT = CONVERT(INT,(SELECT LEFT((REPLACE(CONVERT(VARCHAR(10), DATEADD(MINUTE,(0-@MinutesBack),@EndDate),108),':','')),3)+'000'));
	
	SELECT	SUM(CONVERT(INT,((KbMemoryUsedByBufferPool/128)/4000)*300))/COUNT(*) AS SuggestedPLE
		, CONVERT(INT,SUM(PageLifeExpectancy)/COUNT(*)) AS PLE
		, CONVERT(INT,(SUM(PageLifeExpectancy) - SUM(CONVERT(INT,((KbMemoryUsedByBufferPool/128)/4000)*300)))/COUNT(*)) AS Diff
		, CONVERT(INT,(((SUM(PageLifeExpectancy) - SUM(CONVERT(INT,((KbMemoryUsedByBufferPool/128)/4000)*300)))/COUNT(*))  / (SUM(PageLifeExpectancy)/COUNT(*)))*100) AS Pcnt
	FROM Analysis.InstanceMemory
	WHERE ServerName = @ServerName
		AND DATEKEY=@DateKey	
		AND TimeKey BETWEEN @TimeKeyPrevious AND @TimeKey;
END