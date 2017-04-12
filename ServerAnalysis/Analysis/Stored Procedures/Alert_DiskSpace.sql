-- =============================================
-- Author:           David Speight
-- Create date: 2017-01-11
-- =============================================
CREATE PROCEDURE [Analysis].[Alert_DiskSpace]
@Threshold INT = 11
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;
 
    DECLARE @tResults TABLE (ServerName VARCHAR(50), DriveName VARCHAR(5), Size INT, FreeSPace INT, PercentFree INT)
       INSERT INTO @tResults
              (      ServerName ,
                     DriveName ,
                     Size ,
                     FreeSPace ,
                     PercentFree)
       SELECT ServerName,
                     DriveName,
                     CONVERT(INT,Size),
                     CONVERT(INT,FreeSpace),
                     CONVERT(INT,PercentFree)
       FROM   [Analysis].[DiskUsage] (NOLOCK)
       WHERE  Perfdate > CONVERT(DATE,GETDATE())
              AND PercentFree < @Threshold;
 
 
       IF (SELECT COUNT(*) FROM @tResults) > 0
       BEGIN
 
              DECLARE @body varchar(max);
              DECLARE @Subject VARCHAR(50)=(@@SERVERNAME+' DISC ALERT ');
      
              -- Create HTML table output for email body.
              SET @body = cast( (
              SELECT td = tServerName + '</td><td>' + tDriveName+ '</td><td>' + tSize+ '</td><td>' + tFreeSPace+ '</td><td>' + tPercentFree
              FROM (
                           SELECT  tServerName = ServerName,
                                         tDriveName = DriveName,
                                         tSize = CONVERT(VARCHAR(12),Size)+' gb',
                                         tFreeSPace = CONVERT(VARCHAR(12),FreeSPace)+' gb',
                                         tPercentFree = CONVERT(VARCHAR(12),PercentFree)+'%'
                           FROM @tResults
                       ) as d
              for xml path( 'tr' ), type ) as varchar(max) )
      
              SET @body = '<table cellpadding="2" cellspacing="2" border="1">'
                             + '<tr><th>ServerName</th><th>DriveName</th><th>Size</th><th>Free Space</th><th>Percent Free</th></tr>'
                             + replace( replace( @body, '&lt;', '<' ), '&gt;', '>' )
                             + '</table>'
      
              -- SEND EMAIL
              EXEC msdb.dbo.sp_send_dbmail
                     @profile_name = 'LoveTheSql',
                     @recipients = 'Dave@LoveTheSql.com',
                     @body = @Body,
                     @subject = @Subject ,
                     @body_format = 'HTML'; 
 
       END;
END