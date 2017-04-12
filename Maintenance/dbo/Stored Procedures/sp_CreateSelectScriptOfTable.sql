--sp_CreateSelectScriptOfTable 'TestDB','Test' 
CREATE PROCEDURE [dbo].[sp_CreateSelectScriptOfTable] 
	@DATABSE AS NVARCHAR(100)
	,@TABLENNAME AS NVARCHAR(100)
AS
BEGIN
	DECLARE @Script AS NVARCHAR(MAX);
	DECLARE @sql NVARCHAR(200);
	DECLARE @Results table (ScriptBlock NVARCHAR(MAX))

	SET @sql = 'USE'
	SELECT @sql = @sql + ' ' + @DATABSE + ';'
	EXEC (@sql);

	SELECT @Script = '  DECLARE @COLUMNNAME AS NVARCHAR(MAX) ; 	
	SELECT @COLUMNNAME = STUFF(( 
    SELECT ' + CHAR(39) + ',' + CHAR(39) + ' +QUOTENAME(C.column_name) 
    FROM information_schema.columns AS C 
    WHERE C.table_name = ' + CHAR(39) + @TABLENNAME + CHAR(39) + '
    FOR XML path(' + CHAR(39) + '' + CHAR(39) + ')
    ), 1, 1,' + CHAR(39) + '' + CHAR(39) + ')  ' + CHAR(13) + ' PRINT' + CHAR(39) + 'SELECT ' + CHAR(39) + '+@COLUMNNAME + CHAR(13) +' + CHAR(39) + 'FROM ' + @TABLENNAME + CHAR(39) + ' +CHAR(13) +' + CHAR(13) + CHAR(39) + 'GO' + CHAR(39);


	INSERT INTO @Results (ScriptBlock)
	EXEC (@Script);

	SELECT ScriptBlock FROM @Results;

END


