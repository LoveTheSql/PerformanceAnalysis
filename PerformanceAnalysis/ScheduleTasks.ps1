#
# ScheduleTasks.ps1
# Compiled by David Speight  http://www.lovethesql.com
#

# DB Usage
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -nologo -file 'C:\PsScripts\ServerAnalysis\Get-DbUsage.ps1'"
$Trigger = New-ScheduledTaskTrigger -Daily -At 12:05am
$Username = 'SYSTEM'
#Modify task to set compatibility to Win8 aka 2012 / 2012 R2
# This part of script from http://blogs.technet.com/b/heyscriptingguy/archive/2015/01/14/use-powershell-to-configure-scheduled-task.aspx
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$params = @{
"TaskName"    = "DB Usage"
"Action"      = $action
"Trigger"     = $trigger
"User"        = $Username
"Settings"    = $settings
"RunLevel"    = "Highest"
"Description" =  "Get and store database usage stats."
}

Register-ScheduledTask  @Params

# Disk Usage
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -nologo -file 'C:\PsScripts\ServerAnalysis\Get-DiskUsage.ps1'"
$Trigger = New-ScheduledTaskTrigger -Daily -At 12:10am
$Username = 'SYSTEM'
#Modify task to set compatibility to Win8 aka 2012 / 2012 R2
# This part of script from http://blogs.technet.com/b/heyscriptingguy/archive/2015/01/14/use-powershell-to-configure-scheduled-task.aspx
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$params = @{
"TaskName"    = "Disk Usage"
"Action"      = $action
"Trigger"     = $trigger
"User"        = $Username
"Settings"    = $settings
"RunLevel"    = "Highest"
"Description" =  "Get and store disk usage stats."
}

Register-ScheduledTask  @Params

# Performance Baseline
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -nologo -file 'C:\PsScripts\ServerAnalysis\Get-PerformanceBaseline.ps1'"
$Trigger = (New-ScheduledTaskTrigger -AtStartup), (New-ScheduledTaskTrigger -Daily -At 12:01am)
$Username = 'SYSTEM'
#Modify task to set compatibility to Win8 aka 2012 / 2012 R2
# This part of script from http://blogs.technet.com/b/heyscriptingguy/archive/2015/01/14/use-powershell-to-configure-scheduled-task.aspx
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$params = @{
"TaskName"    = "Performance Baseline"
"Action"      = $action
"Trigger"     = $trigger
"User"        = $Username
"Settings"    = $settings
"RunLevel"    = "Highest"
"Description" =  "Get and store performance baseline stats."
}

Register-ScheduledTask  @Params

