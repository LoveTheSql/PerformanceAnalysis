-- =============================================
-- Author:		DS
-- =============================================
CREATE PROCEDURE [dbo].[IndexAdvantageSuggestions]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT	index_advantage,
			unique_compiles,
			user_seeks,
			last_user_seek,
			mid.statement,
			mid.equality_columns,
			mid.inequality_columns,
			mid.included_columns
	FROM
		(SELECT user_seeks * avg_total_user_cost * (avg_user_impact * 0.01) AS index_advantage, 
				migs.unique_compiles,
				migs.user_seeks,
				migs.last_user_seek,
				migs.group_handle
			FROM sys.dm_db_missing_index_group_stats migs) AS migs_adv
		INNER JOIN sys.dm_db_missing_index_groups AS mig ON migs_adv.group_handle = mig.index_group_handle
		INNER JOIN sys.dm_db_missing_index_details AS mid ON mig.index_handle = mid.index_handle
	WHERE migs_adv.index_advantage > 1000
	ORDER BY migs_adv.index_advantage DESC;

END
