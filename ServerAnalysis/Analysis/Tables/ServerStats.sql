CREATE TABLE [Analysis].[ServerStats] (
    [ServerID]  INT             IDENTITY (1, 1) NOT NULL,
    [ServerNm]  VARCHAR (30)    NOT NULL,
    [PerfDate]  DATETIME        NOT NULL,
    [PctProc]   DECIMAL (10, 4) NOT NULL,
    [Memory]    BIGINT          NOT NULL,
    [PgFilUse]  DECIMAL (10, 4) NOT NULL,
    [DskSecRd]  DECIMAL (10, 4) NOT NULL,
    [DskSecWrt] DECIMAL (10, 4) NOT NULL,
    [ProcQueLn] INT             NOT NULL,
    CONSTRAINT [PK_ServerStats] PRIMARY KEY CLUSTERED ([ServerID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ServerStats_PerfDate]
    ON [Analysis].[ServerStats]([PerfDate] ASC);

