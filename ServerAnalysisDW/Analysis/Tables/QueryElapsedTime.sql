CREATE TABLE [Analysis].[QueryElapsedTime] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [IDAlternateKey]  INT           NULL,
    [ServerName]      VARCHAR (50)  NULL,
    [DatabaseName]    VARCHAR (50)  NULL,
    [DateKey]         INT           NULL,
    [TimeKey]         INT           NULL,
    [Object_Name]     VARCHAR (50)  NULL,
    [Total_Seconds]   FLOAT (53)    NULL,
    [Execution_Count] INT           NULL,
    [Query]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK_QueryElapsedTime] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_QueryElapsedTime_ServerName]
    ON [Analysis].[QueryElapsedTime]([ServerName] ASC)
    INCLUDE([IDAlternateKey]);


GO
CREATE NONCLUSTERED INDEX [IX_QueryElapsedTime_DateKey_TimeKey_Object_Name]
    ON [Analysis].[QueryElapsedTime]([DateKey] ASC, [TimeKey] ASC, [Object_Name] ASC)
    INCLUDE([DatabaseName], [Execution_Count], [ServerName], [Total_Seconds]);

