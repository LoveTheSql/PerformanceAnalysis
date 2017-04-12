CREATE TABLE [Analysis].[DatabaseUsage] (
    [database_id]        INT          IDENTITY (1, 1) NOT NULL,
    [PerfDate]           DATETIME     NOT NULL,
    [ServerName]         VARCHAR (30) NULL,
    [DatabaseName]       VARCHAR (30) NULL,
    [Collation]          VARCHAR (30) NULL,
    [CompatibilityLevel] VARCHAR (30) NULL,
    [AutoShrink]         VARCHAR (5)  NULL,
    [RecoveryModel]      VARCHAR (30) NULL,
    [Size]               FLOAT (53)   NULL,
    [SpaceAvailable]     FLOAT (53)   NULL,
    CONSTRAINT [PK_DatabaseUsage] PRIMARY KEY CLUSTERED ([database_id] ASC)
);

