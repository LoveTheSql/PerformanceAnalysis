CREATE PROCEDURE [Analysis].[insInstanceStats]
           (@InstanceID     int OUTPUT
           ,@ServerID       int = NULL
           ,@ServerNm       varchar(30) = NULL
           ,@InstanceNm     varchar(30) = NULL
           ,@PerfDate       datetime = NULL
           ,@FwdRecSec      decimal(10,4) = NULL
           ,@PgSpltSec      decimal(10,4) = NULL
           ,@BufCchHit      decimal(10,4) = NULL
           ,@PgLifeExp      int = NULL
           ,@LogGrwths      int = NULL
           ,@BlkProcs       int = NULL
           ,@BatReqSec      decimal(10,4) = NULL
           ,@SQLCompSec     decimal(10,4) = NULL
           ,@SQLRcmpSec     decimal(10,4) = NULL)
AS
    SET NOCOUNT ON
    
    DECLARE @InstanceOut table( InstanceID int);

    INSERT INTO [Analysis].[InstanceStats]
           ([ServerID]
           ,[ServerNm]
           ,[InstanceNm]
           ,[PerfDate]
           ,[FwdRecSec]
           ,[PgSpltSec]
           ,[BufCchHit]
           ,[PgLifeExp]
           ,[LogGrwths]
           ,[BlkProcs]
           ,[BatReqSec]
           ,[SQLCompSec]
           ,[SQLRcmpSec])
    OUTPUT INSERTED.InstanceID INTO @InstanceOut
    VALUES
           (@ServerID
           ,@ServerNm
           ,@InstanceNm
           ,@PerfDate
           ,@FwdRecSec
           ,@PgSpltSec
           ,@BufCchHit
           ,@PgLifeExp
           ,@LogGrwths
           ,@BlkProcs
           ,@BatReqSec
           ,@SQLCompSec
           ,@SQLRcmpSec)

    SELECT @InstanceID = InstanceID FROM @InstanceOut
    
    RETURN

