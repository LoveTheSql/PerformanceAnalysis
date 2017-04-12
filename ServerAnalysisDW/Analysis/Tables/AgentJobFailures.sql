CREATE TABLE [Analysis].[AgentJobFailures] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [IDAlternateKey] INT           NULL,
    [ServerName]     VARCHAR (50)  NULL,
    [DateKey]        INT           NULL,
    [TimeKey]        INT           NULL,
    [Job_Name]       VARCHAR (150) NULL,
    [Step_Name]      VARCHAR (150) NULL,
    [Step_ID]        INT           NULL,
    [Severity]       INT           NULL,
    [Message]        VARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentJobFailures] PRIMARY KEY CLUSTERED ([ID] ASC)
);

