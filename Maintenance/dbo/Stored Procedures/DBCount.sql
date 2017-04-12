
CREATE PROCEDURE [dbo].[DBCount] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL VARCHAR(MAX), @Date DATETIME;
	
	SET @SQL = ''
	SET @Date = CONVERT(char(10), GETDATE(), 120);

	WITH DL AS (SELECT D.DatabaseID
				FROM dbo.Databases D (NOLOCK)
				INNER JOIN dbo.DatabaseCount C (NOLOCK)
					ON D.DatabaseID = C.DatabaseID
					AND C.CountDate = @Date
				)
	SELECT @SQL = @SQL + '
	EXEC dbo.DBCount_' + C.CountType + '
		@DatabaseID = ' + CAST(D.DatabaseID AS VARCHAR(20)) + ',
		@DatabaseName = ''' + D.DatabaseName + ''',
		@CountTable = ''' + D.CountTable + ''',
		@CountColumn = ''' + ISNULL(D.CountColumn,'') + ''';
	'
	FROM dbo.Databases D
	INNER JOIN dbo.CountType C
	ON D.CountTypeID = C.CountTypeID
	LEFT JOIN DL
	ON D.DatabaseID = DL.DatabaseID
	WHERE DL.DatabaseID IS NULL
	AND D.IsCounter = 1

	EXEC (@SQL)
END

