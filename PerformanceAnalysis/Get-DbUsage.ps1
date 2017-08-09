#get-dbusage.ps1
#
#This script gets database usage from the specified SQL Server instance.
#
# Deploy this script to a path like: C:\PsScripts\ServerAnalysis\
#
# Change log:
# October 30, 2010: Allen White
#   Initial Version

# Get the SQL Server instance name from the command line
param(
  [string]$inst=$null #'MyServerName'
  )

# Uncomment next two lines for WIN SERVER 2008R2 running SQL 2012
#Add-PSSnapin SqlServerCmdletSnapin100
#Add-PSSnapin SqlServerProviderSnapin100

# Comment out this entire section on WIN SERVER 2016 or PowerShell 5.0+
# Load SMO assembly, and if we're running SQL 2008 DLLs load the SMOExtended and SQLWMIManagement libraries
$v = [System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')
if ((($v.FullName.Split(','))[1].Split('='))[1].Split('.')[0] -ne '9') {
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SQLWMIManagement') | out-null
  }

# Handle any errors that occur
Trap {
  # Handle the error
  $err = $_.Exception
  write-output $err.Message
  while( $err.InnerException ) {
  	$err = $err.InnerException
  	write-output $err.Message
  	};
  # End the script.
  break
  }

$sqlsrv = 'MyDatabaseServer'
$destdb = 'ServerAnalysis'

# Connect to the requested instance
$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $inst

# Cycle through and record the size and space available data for each database
foreach ($db in $s.Databases) {
	if ($db.IsAccessible -eq $True) {
		$dt = get-date 
	
		#Send the disk usage values to our database
		$q = "exec [Analysis].[insDatabaseUsage]"
		$q += " @ServerNm='" + [string]$inst + "'"
		$q += ", @PerfDate='" + [string]$dt + "'"
		$q += ", @DBName='" + [string]$db.Name + "'"
		$q += ", @Collation='" + [string]$db.Collation + "'"
		$q += ", @Compat='" + [string]$db.CompatibilityLevel + "'"
		$q += ", @Shrink='" + [string]$db.AutoShrink + "'"
		$q += ", @Recovery='" + [string]$db.RecoveryModel + "'"
		$q += ", @Size=" + [string]$db.Size
		[float]$sa = $db.SpaceAvailable / 1024
		$q += ", @Available=" + [string]$sa

		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		}
	}
