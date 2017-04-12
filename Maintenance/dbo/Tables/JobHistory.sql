CREATE TABLE [dbo].[JobHistory] (
    [ID]        INT           IDENTITY (1, 1) NOT NULL,
    [JobName]   VARCHAR (128) NOT NULL,
    [JobDate]   INT           NOT NULL,
    [JobTime]   INT           NOT NULL,
    [JobFailed] BIT           NOT NULL,
    CONSTRAINT [PK_JobHistory] PRIMARY KEY CLUSTERED ([ID] ASC)
);

