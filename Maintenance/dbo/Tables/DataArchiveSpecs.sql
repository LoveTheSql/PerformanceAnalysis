CREATE TABLE [dbo].[DataArchiveSpecs] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [TableName]        VARCHAR (150) NULL,
    [IDColumnName]     VARCHAR (150) NULL,
    [DateColumnName]   VARCHAR (150) NULL,
    [RetainDays]       INT           NULL,
    [SourceMaxID]      INT           NULL,
    [SourceMinID]      INT           NULL,
    [ArchivedMaxID]    INT           NULL,
    [ArchivedMinID]    INT           NULL,
    [LastDateArchived] DATETIME      NULL,
    [Success]          BIT           NULL,
    [GroupID]          INT           NULL,
    CONSTRAINT [PK_DataArchiveSpecs] PRIMARY KEY CLUSTERED ([ID] ASC)
);

