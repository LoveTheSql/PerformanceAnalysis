CREATE TABLE [Analysis].[InstanceStats] (
    [InstanceID] INT             IDENTITY (1, 1) NOT NULL,
    [ServerID]   INT             NOT NULL,
    [ServerNm]   VARCHAR (30)    NOT NULL,
    [InstanceNm] VARCHAR (30)    NOT NULL,
    [PerfDate]   DATETIME        NOT NULL,
    [FwdRecSec]  DECIMAL (10, 4) NOT NULL,
    [PgSpltSec]  DECIMAL (10, 4) NOT NULL,
    [BufCchHit]  DECIMAL (10, 4) NOT NULL,
    [PgLifeExp]  INT             NOT NULL,
    [LogGrwths]  INT             NOT NULL,
    [BlkProcs]   INT             NOT NULL,
    [BatReqSec]  DECIMAL (10, 4) NOT NULL,
    [SQLCompSec] DECIMAL (10, 4) NOT NULL,
    [SQLRcmpSec] DECIMAL (10, 4) NOT NULL,
    CONSTRAINT [PK_InstanceStats] PRIMARY KEY CLUSTERED ([InstanceID] ASC),
    CONSTRAINT [FX_InstanceStats] FOREIGN KEY ([ServerID]) REFERENCES [Analysis].[ServerStats] ([ServerID])
);


GO
CREATE NONCLUSTERED INDEX [AK_ServerStats]
    ON [Analysis].[InstanceStats]([ServerID] ASC);

