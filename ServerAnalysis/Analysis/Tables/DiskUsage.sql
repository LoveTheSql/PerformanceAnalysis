CREATE TABLE [Analysis].[DiskUsage] (
    [disk_id]     INT          IDENTITY (1, 1) NOT NULL,
    [PerfDate]    DATETIME     NOT NULL,
    [ServerName]  VARCHAR (30) NULL,
    [VolumeName]  VARCHAR (30) NULL,
    [DriveName]   VARCHAR (5)  NULL,
    [Size]        FLOAT (53)   NULL,
    [FreeSpace]   FLOAT (53)   NULL,
    [PercentFree] FLOAT (53)   NULL,
    CONSTRAINT [PK_DiskUsage] PRIMARY KEY CLUSTERED ([disk_id] ASC)
);

