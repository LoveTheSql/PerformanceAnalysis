CREATE TABLE [Analysis].[ServerStats] (
    [ServerID]           INT             IDENTITY (1, 1) NOT NULL,
    [ServerAlternateKey] INT             NULL,
    [ServerNm]           VARCHAR (30)    NULL,
    [PerfDate]           DATETIME        NULL,
    [PctProc]            DECIMAL (10, 4) NULL,
    [Memory]             BIGINT          NULL,
    [PgFilUse]           DECIMAL (10, 4) NULL,
    [DskSecRd]           DECIMAL (10, 4) NULL,
    [DskSecWrt]          DECIMAL (10, 4) NULL,
    [ProcQueLn]          INT             NULL,
    CONSTRAINT [PK_ServerStats] PRIMARY KEY CLUSTERED ([ServerID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ServerStats_ServerNm]
    ON [Analysis].[ServerStats]([ServerNm] ASC)
    INCLUDE([ServerAlternateKey]);

