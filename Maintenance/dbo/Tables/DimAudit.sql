CREATE TABLE [dbo].[DimAudit] (
    [AuditKey]                INT              IDENTITY (1, 1) NOT NULL,
    [ParentAuditKey]          INT              NOT NULL,
    [TableName]               VARCHAR (50)     CONSTRAINT [DF__DimAudit__TableN__1DE57479] DEFAULT ('Unknown') NOT NULL,
    [PkgName]                 VARCHAR (50)     CONSTRAINT [DF__DimAudit__PkgNam__1ED998B2] DEFAULT ('Unknown') NOT NULL,
    [PkgGUID]                 UNIQUEIDENTIFIER NULL,
    [PkgVersionGUID]          UNIQUEIDENTIFIER NULL,
    [PkgVersionMajor]         SMALLINT         NULL,
    [PkgVersionMinor]         SMALLINT         NULL,
    [ExecStartDT]             DATETIME         CONSTRAINT [DF__DimAudit__ExecSt__1FCDBCEB] DEFAULT (getdate()) NOT NULL,
    [ExecStopDT]              DATETIME         NULL,
    [ExecutionInstanceGUID]   UNIQUEIDENTIFIER NULL,
    [ExtractRowCnt]           BIGINT           NULL,
    [InsertRowCnt]            BIGINT           NULL,
    [UpdateRowCnt]            BIGINT           NULL,
    [ErrorRowCnt]             BIGINT           NULL,
    [TableInitialRowCnt]      BIGINT           NULL,
    [TableFinalRowCnt]        BIGINT           NULL,
    [TableMaxDateTime]        DATETIME         NULL,
    [SuccessfulProcessingInd] CHAR (1)         CONSTRAINT [DF__DimAudit__Succes__20C1E124] DEFAULT ('N') NOT NULL,
    CONSTRAINT [PK_dbo.DimAudit] PRIMARY KEY CLUSTERED ([AuditKey] ASC),
    CONSTRAINT [FK_dbo_DimAudit_ParentAuditKey] FOREIGN KEY ([ParentAuditKey]) REFERENCES [dbo].[DimAudit] ([AuditKey])
);

