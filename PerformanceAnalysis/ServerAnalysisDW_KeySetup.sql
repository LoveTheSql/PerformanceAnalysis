/*  SCRIPTING TO SET UP KEYS on the ServerAnalysisDW database */


-- Do this ONCE on each server instance.
use master;
BACKUP SERVICE MASTER KEY TO FILE = 'c:\MSSQL\keys\SSRS2016_ServiceMaster.key'     ENCRYPTION BY PASSWORD = 'LoveTheSql123!';

	

-- Master key at the database level
use ServerAnalysisDW;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'LoveTheSql123!';



-- Backup key
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'LoveTheSql123!'; 
BACKUP MASTER KEY TO FILE = 'c:\MSSQL\Keys\SSRS2016_ServerAnalysisDW_Master_DB.key'     ENCRYPTION BY PASSWORD = 'LoveTheSql123!'; 



-- create the certificate
CREATE CERTIFICATE [cert_keyAnalysis] WITH SUBJECT = 'Key Protection';



-- create the symmetric key
CREATE SYMMETRIC KEY [key_Analysis] WITH
    KEY_SOURCE = 'My key generation bits. This is a shared secret!',
    ALGORITHM = AES_256, 
    IDENTITY_VALUE = 'Key Identity generation bits. Also a shared secret'
    ENCRYPTION BY CERTIFICATE [cert_keyAnalysis];


	

-- INSERT/UPDATE Connection Strings
DECLARE @conString varchar(150);

OPEN SYMMETRIC KEY [key_Analysis] 
			DECRYPTION BY CERTIFICATE cert_keyAnalysis;

SET @conString = 'Data Source=SQL2014;Initial Catalog=ServerAnalysis;Provider=SQLNCLI11.1;Integrated Security=SSPI;';

INSERT INTO ServerAnalysisDW.Analysis.Server
(ServerNm, IsActive, connString, RAMmb)
VALUES
('MyServer',1,ENCRYPTBYKEY(key_guid('key_Analysis'), CONVERT(VARCHAR(150),@conString)),3200)

--SET @conString = 'Data Source=SQL2014;Initial Catalog=ServerAnalysis;Provider=SQLNCLI11.1;Integrated Security=SSPI;';

--UPDATE ServerAnalysisDW.Analysis.Server
--SET connString =
--	ENCRYPTBYKEY(key_guid('key_Analysis'), CONVERT(VARCHAR(150),@conString))
--WHERE ServerID = 6;

-- Test

exec [Analysis].[ServerListGet]



