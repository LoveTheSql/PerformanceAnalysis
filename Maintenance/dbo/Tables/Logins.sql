CREATE TABLE [dbo].[Logins] (
    [ID]        INT           IDENTITY (1, 1) NOT NULL,
    [LoginDate] DATETIME      CONSTRAINT [DF_Logins_LoginDate] DEFAULT (getdate()) NOT NULL,
    [LoginInfo] VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Logins] PRIMARY KEY CLUSTERED ([ID] ASC)
);

