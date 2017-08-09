# Get-PerformanceBaseline.ps1
#
# Deploy this script to a path like: C:\PsScripts\ServerAnalysis\
#
# Borrowed from Alan White
<#
.Synopsis
   Gets System and SQL Server Performance Counters for the specified server.
.DESCRIPTION
   This script will collect the standard baseline performance counters for the specified server
   and load them into the ServerAnalysis database for later evaluation.
.EXAMPLE
   D:\PSscripts\Get-PerformanceBaseline.ps1 MyDBServer 60 '2050-12-31 23:59:59.997' MyDBServer ServerAnalysis
#>

[CmdletBinding()]
param(
	[string]$srv=$null,
	[int]$interval=$null,
	[datetime]$endat=$null,
	[string]$destsrv=$null,
	[string]$destdb=$null
	)

# Uncomment next two lines for WIN SERVER 2008R2 running SQL 2012
#Add-PSSnapin SqlServerCmdletSnapin100
#Add-PSSnapin SqlServerProviderSnapin100

$m = New-Object ('Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer') $srv                              
$inst = $m.ServerInstances | select @{Name="SrvName"; Expression={$m.Name}}, Name

try {

    while ($endat -gt (get-date)) {
        $inst | ForEach-Object { 
		if ($_.Name -eq 'MSSQLSERVER') {
			$srvnm = $_.Name
			}
		else {
			$srvnm = 'MSSQL$' + $_.Name
			}
		$stat = get-service -name $srvnm | select Status
		if ($stat.Status -eq 'Running') {
			$iname = $srvnm
			if ($iname -eq 'MSSQLSERVER') {
				$iname = 'SQLServer'
				}
			
			# Define our list of counters
			$counters = @(
			    "\Processor(_Total)\% Processor Time",
			    "\Memory\Available MBytes",
			    "\Paging File(_Total)\% Usage",
			    "\PhysicalDisk(_Total)\Avg. Disk sec/Read",
			    "\PhysicalDisk(_Total)\Avg. Disk sec/Write",
			    "\System\Processor Queue Length",
			    "\$($iname):Access Methods\Forwarded Records/sec",
			    "\$($iname):Access Methods\Page Splits/sec",
			    "\$($iname):Buffer Manager\Buffer cache hit ratio",
			    "\$($iname):Buffer Manager\Page life expectancy",
			    "\$($iname):Databases(_Total)\Log Growths",
			    "\$($iname):General Statistics\Processes blocked",
			    "\$($iname):SQL Statistics\Batch Requests/sec",
			    "\$($iname):SQL Statistics\SQL Compilations/sec",
			    "\$($iname):SQL Statistics\SQL Re-Compilations/sec"
			)


        
			# Get performance counter data
			$ctr = Get-Counter -ComputerName $srv -Counter $counters -SampleInterval 1 -MaxSamples 1
			$dt = $ctr.Timestamp

			foreach ($ct in $ctr.CounterSamples) {
				if ($ct.Path -like '*% Processor Time') {
					$pptv = $ct.CookedValue
					}
				if ($ct.Path -like '*Available MBytes') {
					$mabv = $ct.CookedValue
					}
				if ($ct.Path -like '*% Usage') {
					$pfuv = $ct.CookedValue
					}
				if ($ct.Path -like '*Avg. Disk sec/Read') {
					$drsv = $ct.CookedValue
					}
				if ($ct.Path -like '*Avg. Disk sec/Write') {
					$dwsv = $ct.CookedValue
					}
				if ($ct.Path -like '*Processor Queue Length') {
					$pqlv = $ct.CookedValue
					}
				if ($ct.Path -like '*Forwarded Records/sec') {
					$frv = $ct.CookedValue
					}
				if ($ct.Path -like '*Page Splits/sec') {
					$psv = $ct.CookedValue
					}
				if ($ct.Path -like '*Buffer cache hit ratio') {
					$bchv = $ct.CookedValue
					}
				if ($ct.Path -like '*Page life expectancy') {
					$plev = $ct.CookedValue
					}
				if ($ct.Path -like '*Log Growths') {
					$lgv = $ct.CookedValue
					}
				if ($ct.Path -like '*Processes blocked') {
					$bpv = $ct.CookedValue
					}
				if ($ct.Path -like '*Batch Requests/sec') {
					$brsv = $ct.CookedValue
					}
				if ($ct.Path -like '*SQL Compilations/sec') {
					$csv = $ct.CookedValue
					}
				if ($ct.Path -like '*SQL Re-Compilations/sec') {
					$rcsv = $ct.CookedValue
					}
				}

			#Send the next set of machine counters to our database
			$q = "declare @ServerID int; exec [Analysis].[insServerStats]"
			$q = $q + " @ServerID OUTPUT"
			$q = $q + ", @ServerNm='" + [string]$srv + "'"
			$q = $q + ", @PerfDate='" + [string]$dt + "'"
			$q = $q + ", @PctProc=" + [string]$pptv
			$q = $q + ", @Memory=" + [string]$mabv
			$q = $q + ", @PgFilUse=" + [string]$pfuv
			$q = $q + ", @DskSecRd=" + [string]$drsv
			$q = $q + ", @DskSecWrt=" + [string]$dwsv
			$q = $q + ", @ProcQueLn=" + [string]$pqlv
			$q = $q + "; select @ServerID as ServerID"
			$res = invoke-sqlcmd -ServerInstance $destsrv -Database $destdb -Query $q
			$SrvID = $res.ServerID

			#Send the next set of instance counters to the database
			$q = "declare @InstanceID int; exec [Analysis].[insInstanceStats]"
			$q = $q + " @InstanceID OUTPUT"
			$q = $q + ", @ServerID=" + [string]$SrvID
			$q = $q + ", @ServerNm='" + [string]$srv + "'"
			$q = $q + ", @InstanceNm=$srvnm"
			$q = $q + ", @PerfDate='" + [string]$dt + "'"
			$q = $q + ", @FwdRecSec=" + [string]$frv
			$q = $q + ", @PgSpltSec=" + [string]$psv
			$q = $q + ", @BufCchHit=" + [string]$bchv
			$q = $q + ", @PgLifeExp=" + [string]$plev
			$q = $q + ", @LogGrwths=" + [string]$lgv
			$q = $q + ", @BlkProcs=" + [string]$bpv
			$q = $q + ", @BatReqSec=" + [string]$brsv
			$q = $q + ", @SQLCompSec=" + [string]$csv
			$q = $q + ", @SQLRcmpSec=" + [string]$rcsv
			$q = $q + "; select @InstanceID as InstanceID"
			$res = invoke-sqlcmd -ServerInstance $destsrv -Database $destdb -Query $q
			$InstID = $res.InstanceID
			}
		}

	Start-Sleep -s $interval
        }
    }
catch {
    # Handle the error
    $err = $_.Exception
    write-output $err.Message
    while( $err.InnerException ) {
	$err = $err.InnerException
	write-output $err.Message
	}
    }
finally {
	write-output "script completed"
	}

