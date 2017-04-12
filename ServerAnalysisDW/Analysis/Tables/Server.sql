CREATE TABLE [Analysis].[Server] (
    [ServerID]   INT              IDENTITY (1, 1) NOT NULL,
    [ServerNm]   VARCHAR (50)     NOT NULL,
    [IsActive]   BIT              CONSTRAINT [DF_Server_IsActive] DEFAULT ((1)) NOT NULL,
    [connString] VARBINARY (1500) NULL,
    [RAMmb]      INT              NULL,
    CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED ([ServerID] ASC)
);

