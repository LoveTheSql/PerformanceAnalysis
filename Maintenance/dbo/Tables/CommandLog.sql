CREATE TABLE [dbo].[CommandLog] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [DatabaseName]    [sysname]      NULL,
    [SchemaName]      [sysname]      NULL,
    [ObjectName]      [sysname]      NULL,
    [ObjectType]      CHAR (2)       NULL,
    [IndexName]       [sysname]      NULL,
    [IndexType]       TINYINT        NULL,
    [StatisticsName]  [sysname]      NULL,
    [PartitionNumber] INT            NULL,
    [ExtendedInfo]    XML            NULL,
    [Command]         NVARCHAR (MAX) NOT NULL,
    [CommandType]     NVARCHAR (60)  NOT NULL,
    [StartTime]       DATETIME       NOT NULL,
    [EndTime]         DATETIME       NULL,
    [ErrorNumber]     INT            NULL,
    [ErrorMessage]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CommandLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

