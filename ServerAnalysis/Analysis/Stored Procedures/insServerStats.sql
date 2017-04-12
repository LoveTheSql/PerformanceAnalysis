CREATE PROCEDURE [Analysis].[insServerStats]
           (@ServerID       int OUTPUT
           ,@ServerNm       varchar(30) = NULL
           ,@PerfDate       datetime = NULL
           ,@PctProc        decimal(10,4) = NULL
           ,@Memory     bigint = NULL
           ,@PgFilUse       decimal(10,4) = NULL
           ,@DskSecRd       decimal(10,4) = NULL
           ,@DskSecWrt      decimal(10,4) = NULL
           ,@ProcQueLn      int = NULL)
AS
    SET NOCOUNT ON
    
    DECLARE @ServerOut table( ServerID int);

    INSERT INTO [Analysis].[ServerStats]
           ([ServerNm]
           ,[PerfDate]
           ,[PctProc]
           ,[Memory]
           ,[PgFilUse]
           ,[DskSecRd]
           ,[DskSecWrt]
           ,[ProcQueLn])
    OUTPUT INSERTED.ServerID INTO @ServerOut
        VALUES
           (@ServerNm
           ,@PerfDate
           ,@PctProc
           ,@Memory
           ,@PgFilUse
           ,@DskSecRd
           ,@DskSecWrt
           ,@ProcQueLn)

    SELECT @ServerID = ServerID FROM @ServerOut
    
    RETURN

