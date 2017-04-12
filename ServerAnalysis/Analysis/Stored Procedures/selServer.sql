

CREATE PROCEDURE [Analysis].[selServer]
AS
SET NOCOUNT ON

SELECT [ServerNm]
FROM [Analysis].[Server]
ORDER BY [ServerNm]
