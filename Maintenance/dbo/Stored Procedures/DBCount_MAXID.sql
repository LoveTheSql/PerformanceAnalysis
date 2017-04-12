
CREATE PROCEDURE [dbo].[DBCount_MAXID]
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

	DECLARE @Max BIGINT
	SELECT @Max = MAX(' + @CountColumn + ')
	FROM ' + @CountTable + ' (NOLOCK)

	INSERT INTO Maintenance.dbo.DatabaseCount (DatabaseID,CountDate,DatabaseCount)
	VALUES (@DatabaseID,@Date,@Max)
	'
	SET @Params  = '
	@DatabaseID INT,
	@Date DATETIME
	'

	EXEC sp_executesql @SQL, @Params, @DatabaseID, @Date
END

