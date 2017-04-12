CREATE TABLE [Analysis].[InstanceMemory] (
    [MemoryID]                                     INT          IDENTITY (1, 1) NOT NULL,
    [MemoryAlternateKey]                           INT          NULL,
    [MemoryDate]                                   DATETIME     NULL,
    [DateKey]                                      INT          NULL,
    [TimeKey]                                      INT          NULL,
    [ServerName]                                   VARCHAR (30) NULL,
    [KbMemoryUsedByBufferPool]                     FLOAT (53)   NULL,
    [KbMemoryNeededPerCurrentWorkload]             FLOAT (53)   NULL,
    [KbMemoryDynamicUsedForConnections]            FLOAT (53)   NULL,
    [KbMemoryDynamicUsedForLocks]                  FLOAT (53)   NULL,
    [KbMemoryDynamicUsedForCache]                  FLOAT (53)   NULL,
    [KbMemoryDynamicUsedForQueryOptimization]      FLOAT (53)   NULL,
    [KbMemoryDynamicUsedForHashSortIndexOps]       FLOAT (53)   NULL,
    [KbMemoryConsumedByCursors]                    FLOAT (53)   NULL,
    [8kbPagesInBufferPool]                         FLOAT (53)   NULL,
    [8kbDataPagesInBufferPool]                     FLOAT (53)   NULL,
    [8kbFreePagesInBufferPool]                     FLOAT (53)   NULL,
    [8kbReservedPagesInBufferPool]                 FLOAT (53)   NULL,
    [8kbStolenPagesInBufferPool]                   FLOAT (53)   NULL,
    [8kbPlaCachePagesInBufferPool]                 FLOAT (53)   NULL,
    [PageLifeExpectancy]                           FLOAT (53)   NULL,
    [NumberRequestsSecWaitForFreePage]             FLOAT (53)   NULL,
    [NumberPagesFlushedDiskSec]                    FLOAT (53)   NULL,
    [NumberBuffersWrittenSecByBufferMgrLazyWriter] FLOAT (53)   NULL,
    [MemoryGrantsPending]                          FLOAT (53)   NULL,
    [MemoryGrantsOutstanding]                      FLOAT (53)   NULL,
    CONSTRAINT [PK_InstanceMemory] PRIMARY KEY CLUSTERED ([MemoryID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InstanceMemory_ServerName]
    ON [Analysis].[InstanceMemory]([ServerName] ASC)
    INCLUDE([MemoryAlternateKey]);

