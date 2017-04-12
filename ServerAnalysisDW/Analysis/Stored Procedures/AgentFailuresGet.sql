-- =============================================
-- Author:		David SPeight
-- =============================================
CREATE PROCEDURE [Analysis].[AgentFailuresGet] 
@ServerName VARCHAR(50),
@DateStart DATETIME,
@DateEnd DATETIME
AS
BEGIN

	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

	SELECT 
			ServerName, DateKey, TimeKey, Job_Name, Step_Name, Step_ID, Severity, Message
	FROM	[Analysis].[AgentJobFailures]
	WHERE	(ServerName = @ServerName OR @ServerName = '--- All ---')
		AND	(DateKey BETWEEN CONVERT(INT,CONVERT(VARCHAR(10), @DateStart,112)) AND CONVERT(INT,CONVERT(VARCHAR(10), @DateEnd,112)))
	GROUP BY ServerName, DateKey, TimeKey, Job_Name, Step_Name, Step_ID, Severity, Message
	ORDER BY ServerName, DateKey, TimeKey;

	SET TRAN ISOLATION LEVEL READ COMMITTED;


END