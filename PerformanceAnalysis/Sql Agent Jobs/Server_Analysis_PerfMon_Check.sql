BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Server Analysis PerfMon Check', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This check to make sure the PerfMonitor stats have been written to the database in the past hour.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SSISuser', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Instance Stats Table', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @perfDate DATETIME;
DECLARE @ServerName NVARCHAR(50) = @@SERVERNAME;
DECLARE @eSubject NVARCHAR(50);
DECLARE @eBody NVARCHAR(500);
SET @perfDate = (SELECT TOP 1 perfDate
			FROM [ServerAnalysis].[Analysis].[InstanceStats]
			ORDER BY InstanceID DESC);

IF (SELECT Datediff(minute, (@perfDate), Getdate())) > 5
BEGIN
	SET @eSubject =''MONITOR ALERT: ''+@ServerName;
	SET @eBody =''MONITOR ALERT: ''+@ServerName + ''. The last PerfMon stats were written to the database '' 
				+ CONVERT(NVARCHAR(12),DATEDIFF(minute, (@perfDate), Getdate()))
				+ '' minutes past. Check to see that the PowerShell script and Scheduled Task are running.'';
	/* Send Email Alert */
    	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''LoveTheSql'',
		@recipients = ''YourName@YourDomainn.com'',
		@body = @eBody,
		@subject =@eSubject;

END;', 
		@database_name=N'ServerAnalysis', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 4 hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=4, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150515, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'17ef62ab-8d7f-4cc1-9cd7-30931df7488f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

