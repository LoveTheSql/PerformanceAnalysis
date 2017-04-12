-- =============================================
-- Modified by: David Speight
-- LoveTheSql.com
-- =============================================
CREATE PROCEDURE [Analysis].[ServerListGet]
@Version VARCHAR(50) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;
	OPEN SYMMETRIC KEY [key_Analysis] DECRYPTION BY CERTIFICATE cert_keyAnalysis;

		SELECT	ServerNm,
				(CASE	WHEN @Version = '2012' THEN REPLACE(CONVERT(VARCHAR(150), DECRYPTBYKEY(connString)),'SQLNCLI10.1','SQLNCLI11.1')
				
						ELSE CONVERT(VARCHAR(150), DECRYPTBYKEY(connString)) END) AS connString
		FROM [Analysis].[Server] 
		WHERE isActive=1;

	CLOSE SYMMETRIC KEY [key_Analysis];
	SET TRAN ISOLATION LEVEL READ COMMITTED;

END