CREATE PROCEDURE [dbo].[JobSave] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Date INT
	SET @Date = CAST(REPLACE(CONVERT(VARCHAR(10),DATEADD(DAY,-1,GETDATE()),120),'-','') AS INT)
	DECLARE @Failed INT
	;
	WITH T AS (SELECT	@Date AS JobDate,
						COUNT(1) AS Counter,
						SUM(CASE WHEN run_status = 0 THEN 1 ELSE 0 END) AS Failed,
						SUM(CASE WHEN run_status = 1 THEN 1 ELSE 0 END) AS Succeeded,
						SUM(CASE WHEN run_status = 2 THEN 1 ELSE 0 END) AS Retry,
						SUM(CASE WHEN run_status = 3 THEN 1 ELSE 0 END) AS Canceled
				FROM msdb..sysjobhistory H (NOLOCK)
				LEFT JOIN dbo.JobCounter C (NOLOCK)
				ON C.JobDate = @Date
				WHERE step_id = 0
				AND run_date = @Date
				)
	INSERT INTO JobCounter (JobDate, JobCount, JobFailed, JobSucceeded, JobRetry, JobCanceled)
	SELECT T.JobDate,
			T.Counter,
			T.Failed,
			T.Succeeded,
			T.Retry,
			T.Canceled
	FROM T
	LEFT JOIN dbo.JobCounter C (NOLOCK)
	ON C.JobDate = T.JobDate
	WHERE C.JobDate IS NULL

	SELECT @Failed = COUNT(1)
	FROM dbo.JobHistory
	WHERE JobDate = @Date
	;
	WITH JL AS (SELECT job_id
				FROM msdb..sysjobhistory (NOLOCK)
				WHERE step_id = 0
				AND run_status = 0
				)
	INSERT INTO dbo.JobHistory (JobName,JobDate,JobTime,JobFailed)
	SELECT	J.name AS JobName,
			H.run_date AS JobDate,
			H.run_time AS JobTime,
			CASE WHEN H.run_status = 0 THEN 1 ELSE 0 END
	FROM msdb..sysjobs J (NOLOCK)
	INNER JOIN JL
	ON J.job_id = jl.job_id
	INNER JOIN msdb..sysjobhistory H
	ON J.job_id = H.job_id
	AND H.step_id = 0
	AND @Failed = 0
	ORDER BY 2 DESC, 1, 3 DESC
END

