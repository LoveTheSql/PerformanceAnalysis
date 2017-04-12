CREATE TABLE [Analysis].[DiskMemoryStats] (
    [DiskMonitorStatID]           INT             IDENTITY (1, 1) NOT NULL,
    [DiskMonitorStatAlternateKey] INT             NOT NULL,
    [ServerNm]                    VARCHAR (30)    NOT NULL,
    [DateKey]                     INT             NOT NULL,
    [TimeKey]                     INT             NOT NULL,
    [TransactionRateSec]          INT             NULL,
    [MemoryPagingRateSec]         INT             NULL,
    [LogFlushesSec]               INT             NULL,
    [LogBytesFlushedSec]          INT             NULL,
    [ProcedureCacheRatio]         DECIMAL (10, 4) NULL,
    [SignalWaitPercent]           DECIMAL (10, 4) NULL,
    CONSTRAINT [PK_DiskMemoryStats] PRIMARY KEY CLUSTERED ([DiskMonitorStatID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_DiskMemoryStats_ServerNm]
    ON [Analysis].[DiskMemoryStats]([ServerNm] ASC)
    INCLUDE([DiskMonitorStatAlternateKey]);

