
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [Analysis].[NegToZero]
(
@inNumber FLOAT
)
RETURNS FLOAT 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @outNumber FLOAT 

	SELECT @outNumber = (CASE WHEN @inNumber < 0 THEN 0 ELSE @inNumber END);
	-- Return the result of the function
	RETURN @outNumber

END

