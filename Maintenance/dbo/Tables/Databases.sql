CREATE TABLE [dbo].[Databases] (
    [DatabaseID]   INT           IDENTITY (1, 1) NOT NULL,
    [ServerDBID]   INT           NULL,
    [GlobalDBID]   INT           NULL,
    [DatabaseName] VARCHAR (200) NULL,
    [RestoreName]  VARCHAR (200) NULL,
    [IsCounter]    BIT           CONSTRAINT [DF_Databases_IsCounter] DEFAULT ((0)) NOT NULL,
    [CountTypeID]  INT           NULL,
    [CountTable]   VARCHAR (50)  NULL,
    [CountColumn]  VARCHAR (50)  NULL,
    [OrderBy]      INT           NULL,
    CONSTRAINT [PK_Databases] PRIMARY KEY CLUSTERED ([DatabaseID] ASC)
);

