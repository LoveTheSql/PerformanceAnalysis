CREATE TABLE [dbo].[DatabaseCheckDBStatus] (
    [CheckDBStatusID] BIGINT   IDENTITY (1, 1) NOT NULL,
    [DatabaseID]      INT      NOT NULL,
    [CheckDate]       DATETIME CONSTRAINT [DF_DatabaseCheckDBStatus_CheckDate] DEFAULT (getdate()) NOT NULL,
    [IsSuccess]       BIT      NOT NULL,
    CONSTRAINT [PK_DatabaseCheckDBStatus] PRIMARY KEY CLUSTERED ([CheckDBStatusID] ASC),
    CONSTRAINT [FK_DatabaseCheckDBStatus_Databases] FOREIGN KEY ([DatabaseID]) REFERENCES [dbo].[Databases] ([DatabaseID])
);

