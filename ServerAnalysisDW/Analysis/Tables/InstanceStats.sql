CREATE TABLE [Analysis].[InstanceStats] (
    [InstanceID]           INT             IDENTITY (1, 1) NOT NULL,
    [InstanceAlternateKey] INT             NULL,
    [ServerID]             INT             NULL,
    [ServerNm]             VARCHAR (30)    NULL,
    [InstanceNm]           VARCHAR (30)    NULL,
    [PerfDate]             DATETIME        NULL,
    [FwdRecSec]            DECIMAL (10, 4) NULL,
    [PgSpltSec]            DECIMAL (10, 4) NULL,
    [BufCchHit]            DECIMAL (10, 4) NULL,
    [PgLifeExp]            INT             NULL,
    [LogGrwths]            INT             NULL,
    [BlkProcs]             INT             NULL,
    [BatReqSec]            DECIMAL (10, 4) NULL,
    [SQLCompSec]           DECIMAL (10, 4) NULL,
    [SQLRcmpSec]           DECIMAL (10, 4) NULL,
    CONSTRAINT [PK_InstanceStats] PRIMARY KEY CLUSTERED ([InstanceID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InstanceStats_ServerNm]
    ON [Analysis].[InstanceStats]([ServerNm] ASC)
    INCLUDE([InstanceAlternateKey]);

