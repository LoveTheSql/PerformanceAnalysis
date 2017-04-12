CREATE TABLE [dbo].[Servers] (
    [ServerID]           INT            IDENTITY (1, 1) NOT NULL,
    [ServerName]         NVARCHAR (50)  NULL,
    [ServerInstanceName] NVARCHAR (100) NULL,
    [IsProduction]       BIT            NULL,
    [DoAutoMaintenance]  BIT            NULL,
    CONSTRAINT [PK_Servers] PRIMARY KEY CLUSTERED ([ServerID] ASC)
);

