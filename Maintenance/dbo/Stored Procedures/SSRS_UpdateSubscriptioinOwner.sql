-- =============================================
-- Author:		David Speight
-- =============================================
CREATE PROCEDURE [dbo].[SSRS_UpdateSubscriptioinOwner]
AS
BEGIN

	DECLARE @NewUserID UNIQUEIDENTIFIER;
	SELECT @NewUserID=UserID FROM ReportServer.dbo.Users WHERE UserName = 'MyDomain\AD-SSRS-User';

	UPDATE ReportServer.dbo.Subscriptions 
	SET OwnerID = @NewUserID 
	WHERE OwnerID <> @NewUserID;

END
