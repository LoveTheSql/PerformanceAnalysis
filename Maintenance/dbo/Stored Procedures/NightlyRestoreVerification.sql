-- =============================================
-- Author:		David Speight
-- =============================================
CREATE PROCEDURE [dbo].[NightlyRestoreVerification]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Get all databases that were NOT restored last night.
	DECLARE @List VARCHAR(2000);  
	SELECT @List = COALESCE(@List + ', ', '') + [d].[name]
	FROM master.sys.databases d
		LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
	where [d].[name] in ('MyDB1','MyDB2')
	group by  [d].[name]
	having ( CONVERT(DATE, MAX(r.[restore_date])) <> CONVERT(DATE,getdate()));
	-- Create a message to send.
	SELECT @List =  (CASE WHEN LEN(@List) > 0 THEN ('RESTORE FAILURES include: ' + @List) ElSE '' END);
	SELECT @List 
	-- Send Email if any exist.
	if LEN(@List) > 1 
		begin try
			--EXEC msdb.dbo.sp_send_dbmail
			--@profile_name = 'DAVE',
			--@recipients = 'dave@lovethesql.com',
			--@subject = 'RESTORE FAILURES',
			--@body = @List 
			PRINT 'EMAIL ERROR'
		end try
		begin catch
			Print 'email failed'
		end catch;
END
