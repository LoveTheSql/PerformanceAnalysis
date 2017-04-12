
CREATE PROCEDURE [dbo].[DBCount_IDENTITY]
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

	INSERT INTO Maintenance.dbo.DatabaseCount (DatabaseID,CountDate,DatabaseCount)
	VALUES (@DatabaseID,@Date,IDENT_CURRENT(@CountTable))
	'
	SET @Params = '
	@DatabaseID INT,
	@Date DATETIME,
	@CountTable VARCHAR(50)
	'

	EXEC sp_executesql @SQL, @Params, @DatabaseID, @Date, @CountTable
END

