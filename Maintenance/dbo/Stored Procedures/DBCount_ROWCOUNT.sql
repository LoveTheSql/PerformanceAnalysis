
CREATE PROCEDURE [dbo].[DBCount_ROWCOUNT]
	@DatabaseID INT,
	@DatabaseName VARCHAR(50),
	@CountTable VARCHAR(50),
	@CountColumn VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX), @Params NVARCHAR(MAX), @Date DATETIME;
	
	SET @Date = CONVERT(char(10), GETDATE(), 120);

	SET @SQL = '
	USE ' + @DatabaseName + ';

	DECLARE @Cnt BIGINT
	SELECT @Cnt = rowcnt
	FROM sys.sysindexes (NOLOCK)
	WHERE indid < 2
	AND id = OBJECT_ID(@CountTable)	

	INSERT INTO Maintenance.dbo.DatabaseCount (DatabaseID,CountDate,DatabaseCount)
	VALUES (@DatabaseID,@Date,@Cnt)
	'
	SET @Params  = '
	@DatabaseID INT,
	@Date DATETIME,
	@CountTable VARCHAR(50)
	'

	EXEC sp_executesql @SQL, @Params, @DatabaseID, @Date, @CountTable
END

