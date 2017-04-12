-- =============================================
-- Author:		DS
-- =============================================
CREATE PROCEDURE [dbo].[ServerUpTime]

AS
BEGIN

	SET NOCOUNT ON
	DECLARE @crdate DATETIME, @hr VARCHAR(50), @min VARCHAR(5)
	SELECT @crdate=crdate FROM master.dbo.sysdatabases WHERE NAME='tempdb'
	SELECT @hr=(DATEDIFF ( mi, @crdate,GETDATE()))/60
	IF ((DATEDIFF ( mi, @crdate,GETDATE()))/60)=0
	SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))
	ELSE
	SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))-((DATEDIFF( mi, @crdate,GETDATE()))/60)*60
	SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME')) [ServerName],
			(@hr + ':' + RIGHT(('00' + @min),2)) [UpTime] 

END

