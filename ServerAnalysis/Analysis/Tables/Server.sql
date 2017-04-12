CREATE TABLE [Analysis].[Server] (
    [ServerID] INT          IDENTITY (1, 1) NOT NULL,
    [ServerNm] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED ([ServerID] ASC)
);

