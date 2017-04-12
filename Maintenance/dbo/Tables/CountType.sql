CREATE TABLE [dbo].[CountType] (
    [CountTypeID]      INT           IDENTITY (1, 1) NOT NULL,
    [CountType]        VARCHAR (50)  NOT NULL,
    [CountDescription] VARCHAR (MAX) NULL,
    [CountShort]       VARCHAR (50)  NULL,
    CONSTRAINT [PK_CountType] PRIMARY KEY CLUSTERED ([CountTypeID] ASC)
);

