CREATE TABLE [dbo].[FileLists] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [ListID]       INT            NULL,
    [FullFilePath] NVARCHAR (500) NULL,
    [IsActive]     BIT            CONSTRAINT [DF_FileLists_IsActive] DEFAULT ((1)) NOT NULL,
    [DatabaseName] NVARCHAR (50)  NULL,
    [InstanceName] NVARCHAR (50)  NULL,
    CONSTRAINT [PK_FileLists] PRIMARY KEY CLUSTERED ([ID] ASC)
);

