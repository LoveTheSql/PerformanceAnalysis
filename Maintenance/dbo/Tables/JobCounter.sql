CREATE TABLE [dbo].[JobCounter] (
    [JobDate]      INT NOT NULL,
    [JobCount]     INT NOT NULL,
    [JobFailed]    INT NOT NULL,
    [JobSucceeded] INT NOT NULL,
    [JobRetry]     INT NOT NULL,
    [JobCanceled]  INT NOT NULL,
    CONSTRAINT [PK_JobCounter] PRIMARY KEY CLUSTERED ([JobDate] ASC)
);

