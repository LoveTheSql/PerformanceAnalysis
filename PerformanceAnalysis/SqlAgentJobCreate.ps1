#
# SqlAgentJobCreate.ps1
#
# Thank you: http://stuart-moore.com/adding-sql-server-jobs-using-powershell/
#
#  TODO   Rewrite this script for INDIVIDUAL and DW Servers

$ServerList = Get-Content c:\ListOfServers.txt
foreach ($srv in $ServerList) {
    $SQLSvr = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server($srv)

    $SQLJob = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.Job -argumentlist    $SQLSvr.JobServer, "Example_Job"
    $SQLJob.Create()

    $SQLJobStep = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.JobStep -argumentlist $SQLJob, "Example_Job_Step"
    $SQLJobStep.Command = "select * from sys.databases"
    $SQLJobStep.DatabaseName = "master"
    $SQLJobStep.Create()

    $SQLJobSchedule =  New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.JobSchedule -argumentlist $SQLJob, "Example_Job_Schedule"

    $SQLJobSchedule.FrequencyTypes =  "Daily"
    $SQLJobSchedule.FrequencyInterval = 1

    $TimeSpan1 = New-TimeSpan -hours 13 -minutes 30
    $SQLJobSchedule.ActiveStartTimeofDay = $TimeSpan1

    $SQLJobSchedule.ActiveStartDate = get-date
    $SQLJobSchedule.create()
}
