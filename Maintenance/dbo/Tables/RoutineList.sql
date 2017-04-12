CREATE TABLE [dbo].[RoutineList] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [RoutineName] VARCHAR (255) NULL,
    [RoutineType] VARCHAR (50)  NULL,
    CONSTRAINT [PK__RoutineL__3214EC27E4BF2434] PRIMARY KEY CLUSTERED ([ID] ASC)
);

