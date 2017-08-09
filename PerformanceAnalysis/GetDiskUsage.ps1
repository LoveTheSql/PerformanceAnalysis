#get-diskusage.ps1
#
#This script gets disk usage from the specified SQL Server instance.
#
# Deploy this script to a path like: C:\PsScripts\ServerAnalysis\
#
# Change log:
# October 30, 2010: Allen White
#   Initial Version

# Get the SQL Server instance name from the command line
param(
  [string]$srv=$null #'MyServerName'
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

$sqlsrv = $srv
$destdb = 'ServerAnalysis'

# Collect the drive info from the specified server
$dsk = gwmi -query "select * from Win32_LogicalDisk where DriveType=3" `
	-computername $sqlsrv | select VolumeName, DeviceID, Size, FreeSpace

# Cycle through and record the size and space available data for each database
foreach ($d in $dsk) {
	$dt = get-date 
	$size = ($d.Size / 1GB)
	$free = ($d.FreeSpace / 1GB)
	
	#Send the disk usage values to our database
	$q = "exec [Analysis].[insDiskUsage]"
	$q = $q + " @ServerNm='" + [string]$srv + "'"
	$q = $q + ", @PerfDate='" + [string]$dt + "'"
	$q = $q + ", @VolName='" + [string]$d.VolumeName + "'"
	$q = $q + ", @Drive='" + [string]$d.DeviceID + "'"
	$q = $q + ", @Size=" + [string]$size
	$q = $q + ", @Free=" + [string]$free 
	[float]$pct = ($d.FreeSpace / $d.Size) * 100
	$q = $q + ", @Percent=" + [string]$pct
	$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
	}

