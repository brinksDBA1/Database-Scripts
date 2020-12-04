USE [msdb]
GO

/****** Object:  Job [DBA_CycleSQLErrorLog]    Script Date: 11/30/2020 5:03:48 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA]    Script Date: 11/30/2020 5:03:48 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_CycleSQLErrorLog', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'cycles the sql error log weekly on Sunday mornings', 
		@category_name=N'DBA', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [cycle error log]    Script Date: 11/30/2020 5:03:49 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'cycle error log', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC master.dbo.sp_cycle_errorlog ', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [cycle agent error log]    Script Date: 11/30/2020 5:03:49 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'cycle agent error log', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec sp_cycle_agent_errorlog', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20091019, 
		@active_end_date=99991231, 
		@active_start_time=1, 
		@active_end_time=235959, 
		@schedule_uid=N'58252631-c646-4f04-ba47-bd7a3995d766'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_AGDatabases (Primary Replica)]    Script Date: 11/30/2020 5:03:50 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:03:50 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Backup_AGDatabases (Primary Replica)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'backs up all databases including system dbs with native sql using compression.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Older Backups]    Script Date: 11/30/2020 5:03:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Older Backups', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
$root  = (Get-ItemProperty -path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer'').BackupDirectory
$root = $root.replace($env:COMPUTERNAME, "ODSPROD")
$Hoursback = "-24"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}
# Keep 2 days of transaction logs
$Hoursback = "-48"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Databases in an Availability Group from a primary replica. (ENCRYPTED)]    Script Date: 11/30/2020 5:03:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Databases in an Availability Group from a primary replica. (ENCRYPTED)', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC proc_BackupPrimaryDatabasesEncrypted ''ODSPROD''
', 
		@database_name=N'DBAAdmin', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'nightly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100118, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959, 
		@schedule_uid=N'c2428e53-850f-4c04-8566-2947e79d4a9b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_AGTransactionLogs (Primary Replica)]    Script Date: 11/30/2020 5:03:51 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:03:51 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Backup_AGTransactionLogs (Primary Replica)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Transaction log backup of primary replica databases.  Compressed and Encypted.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Transaction Logs]    Script Date: 11/30/2020 5:03:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Transaction Logs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.proc_BackupPrimaryReplicaLogsEncrypted ''ODSPROD''', 
		@database_name=N'DBAAdmin', 
		@output_file_name=N'\\wp1sqlbk02\d$\WP1ODSINST01\Backup\JobLog\proc_DBAAdmin_Backup_TransactionLogs_PrimaryReplica.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180207, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c816b310-f339-40fc-8a01-671a4172e2d3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_Databases (Local)]    Script Date: 11/30/2020 5:03:51 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:03:51 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Backup_Databases (Local)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Backs up databases the are not part of an availability group and are in the full recovery mode', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Local Databases]    Script Date: 11/30/2020 5:03:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Local Databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBAAdmin.dbo.proc_BackupLocalDatabases', 
		@database_name=N'DBAAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180109, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'd41b4aae-cd1a-4777-b962-cd554c4c0100'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_RemoveOlderBackups]    Script Date: 11/30/2020 5:03:52 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:03:52 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Backup_RemoveOlderBackups', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Older Backups of Local Databases]    Script Date: 11/30/2020 5:03:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Older Backups of Local Databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
$root  = (Get-ItemProperty -path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer'').BackupDirectory

$Hoursback = "-24"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}
# Keep 2 days of transaction logs
$Hoursback = "-48"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Older Backups of AG Databases]    Script Date: 11/30/2020 5:03:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Older Backups of AG Databases', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
# $root  = (Get-ItemProperty -path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer'').BackupDirectory
$root  = "\\wp1sqlbk03\d$\ODSPROD\backup"

$Hoursback = "-24"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}
# Keep 2 days of transaction logs
$Hoursback = "-48"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Older Backups for VERTEXPRODA]    Script Date: 11/30/2020 5:03:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Older Backups for VERTEXPRODA', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
# $root  = (Get-ItemProperty -path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer'').BackupDirectory
$root  = "\\wp1sqlbk03\d$\VERTEXPRODA\backup"

$Hoursback = "-24"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}
# Keep 2 days of transaction logs
$Hoursback = "-48"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Older Backups of SQL3]    Script Date: 11/30/2020 5:03:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Older Backups of SQL3', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
# $root  = (Get-ItemProperty -path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer'').BackupDirectory
$root  = "\\wp1sqlbk03\d$\SQL3\backup"

$Hoursback = "-24"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.bak | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}
# Keep 2 days of transaction logs
$Hoursback = "-48"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddHours($Hoursback)
 try
 {
Set-Location c:
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete } | Write-Host
Get-ChildItem -Path $root -Recurse -include *.trn | Where-Object { $_.CreationTime -lt $DatetoDelete }  | Remove-Item -ErrorAction ''Stop'' 
 }
catch
 {
throw
}', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180207, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'0d889536-dd6a-4e1c-9474-ae7925eb4808'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_TransactionLogs (Local)]    Script Date: 11/30/2020 5:03:53 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:03:53 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Backup_TransactionLogs (Local)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'backs up all local database logs that are not in SIMPLE recovery mode', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Logs]    Script Date: 11/30/2020 5:03:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Logs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBAAdmin.dbo.proc_BackupLocalDatabaseLogs', 
		@database_name=N'DBAAdmin', 
		@output_file_name=N'\\wp1sqlbk03\d$\WP1ODSINST01\Backup\JobLog\proc_BackupLocalDatabaseLogs.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180109, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c0ddd2e0-2a79-4a7b-a1c3-d9e8796695fc'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100215, 
		@active_end_date=99991231, 
		@active_start_time=11500, 
		@active_end_time=235959, 
		@schedule_uid=N'97a27e22-74e7-4f77-9d64-a4e55a1ffeea'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_BlockingMonitoring]    Script Date: 11/30/2020 5:03:54 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:03:54 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_BlockingMonitoring', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitor Blocking]    Script Date: 11/30/2020 5:03:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitor Blocking', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
declare @NumBlocks_1 int
declare @NumBlocks_2 int
declare @threshold_1 int = 100
declare @threshold_2 int = 100
declare @wait char(8) = ''00:00:15''
declare @mail_recipients varchar(1000) = ''dbateam@brinkshome.com''
declare @mail_subject varchar(100) = ''BLOCKING!!!''
declare @mail_body varchar(1000)

select spid, blocked, dbid, sql_handle into #t1 from master.sys.sysprocesses where blocked > 0
select distinct blocked into #t2 from #t1
--delete a from #t2 a, #t1 b where a.blocked = b.spid
--select a.blocked, b.login_name, db_name(c.dbid) database_name, d.text sql_text from #t2 a,
--	sys.dm_exec_sessions b, master.sys.sysprocesses c 
--	cross apply sys.dm_exec_sql_text(c.sql_handle) d 
--	where a.blocked = b.session_id and a.blocked = c.spid
select @NumBlocks_1 = count(1) from #t1

if @NumBlocks_1 >= @threshold_1
begin
	waitfor delay @wait				
	select spid, blocked, dbid, sql_handle into #t3 from master.sys.sysprocesses where blocked > 0
	select distinct blocked into #t4 from #t3
	delete a from #t4 a, #t3 b where a.blocked = b.spid
	select a.blocked, b.login_name, db_name(c.dbid) database_name, d.text sql_text into #t5 from #t4 a,
		sys.dm_exec_sessions b, master.sys.sysprocesses c 
		cross apply sys.dm_exec_sql_text(c.sql_handle) d 
		where a.blocked = b.session_id and a.blocked = c.spid
	select @NumBlocks_2 = count(1) from #t1
	if @NumBlocks_2 >= @threshold_2
	begin
		select @mail_body = ''Blocking SPID: '' + convert(varchar(10), blocked) + CHAR(13)+CHAR(10) +
			''Login Name: '' + login_name + CHAR(13)+CHAR(10) +
			''Database Name: '' + database_name + CHAR(13)+CHAR(10) +
			''SQL Text: '' + sql_text + CHAR(13)+CHAR(10)
			from #t5
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = @mail_recipients,  
			@body = @mail_body,  
			@subject = @mail_subject;  
	end
end

drop table #t1
drop table #t2


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190314, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1619dfe8-8075-4114-a0c7-0a037589e7b4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_CHECKDB]    Script Date: 11/30/2020 5:03:55 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:03:55 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_CHECKDB', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Weekly consistency checks of databases in the MASPROD and ODSPROD Availability Groups.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Database Consistency]    Script Date: 11/30/2020 5:03:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Database Consistency', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC DBAAdmin.dbo.proc_DBCC_CheckDBs', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180416, 
		@active_end_date=99991231, 
		@active_start_time=130000, 
		@active_end_time=235959, 
		@schedule_uid=N'52ee6cd7-76c4-41af-bfa1-b57e19719f45'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Compare_ODS_SQL_Agent_Jobs]    Script Date: 11/30/2020 5:03:56 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:03:56 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Compare_ODS_SQL_Agent_Jobs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Compare SQL Agent Jobs]    Script Date: 11/30/2020 5:03:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Compare SQL Agent Jobs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @mail_body varchar(1000)
declare @mail_recipients varchar(1000) = ''dbateam@brinkshome.com''
declare @mail_subject varchar(100) = ''SQL Agent Jobs Comparison''

if object_id(''jobname_WP1ODSINST01'') > 0
	drop table jobname_WP1ODSINST01
select * into jobname_WP1ODSINST01 from MASF.DBAAdmin.dbo.jobname_WP1ODSINST01

if object_id(''jobname_VV1ODSINST01'') > 0
	drop table jobname_VV1ODSINST01
select * into jobname_VV1ODSINST01 from MASF.DBAAdmin.dbo.jobname_VV1ODSINST01

if object_id(''jobname_core'') > 0
	drop table jobname_core
select name into jobname_core from jobname_WP1ODSINST01 a where
	exists (select b.name from jobname_VV1ODSINST01 b where a.name=b.name)
	
if object_id(''extra_WP1ODSINST01'') > 0
	drop table extra_WP1ODSINST01
select name into extra_WP1ODSINST01 from jobname_WP1ODSINST01 a where
	not exists (select b.name from jobname_core b where a.name = b.name)

if object_id(''extra_VV1ODSINST01'') > 0
	drop table extra_VV1ODSINST01
select name into extra_VV1ODSINST01 from jobname_VV1ODSINST01 a where
	not exists (select b.name from jobname_core b where a.name = b.name)

select @mail_body = ''WP1ODSINAT01 extra jobs: '' 
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = @mail_recipients,  
			@body = @mail_body,  
			@subject = @mail_subject,
			@query = ''select name from SSISDB.dbo.extra_WP1ODSINST01'' 

select @mail_body = ''VV1ODSINAT01 extra jobs: '' 
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = @mail_recipients,  
			@body = @mail_body,  
			@subject = @mail_subject, 
			@query = ''select name from SSISDB.dbo.extra_VV1ODSINST01'' 


', 
		@database_name=N'SSISDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190508, 
		@active_end_date=99991231, 
		@active_start_time=221500, 
		@active_end_time=235959, 
		@schedule_uid=N'449371b6-7622-4093-998f-d715fe0ea501'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Fix_Blowfish_Error]    Script Date: 11/30/2020 5:03:56 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:03:56 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Fix_Blowfish_Error', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Fix Blowfish Errors]    Script Date: 11/30/2020 5:03:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fix Blowfish Errors', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @mas_name varchar(50)
declare @cmd_user varchar(100)
declare @cmd_role varchar(100)

select a.name into #t from master.dbo.syslogins a where a.name like ''mas!_%'' escape ''!'' and not exists 
	(select b.name from master.dbo.sysusers b where a.name = b.name) and exists
	(select c.name from mi_mondb.dbo.sysusers c where a.name = c.name) and exists
	(select d.name from mi_masdb.dbo.sysusers d where a.name = d.name) and exists
	(select e.name from mi_custom.dbo.sysusers e where a.name = e.name)

declare mas cursor for select name from #t
open mas
fetch mas into @mas_name

while (@@fetch_status = 0)
begin
	select @cmd_user = ''CREATE USER '' + @mas_name + '' FOR LOGIN '' + @mas_name
	select @cmd_role = ''ALTER ROLE mas_user ADD MEMBER '' + @mas_name
	--print @cmd_user
	--print @cmd_role
	exec(@cmd_user)
	exec(@cmd_role)
	fetch mas into @mas_name
end
drop table #t
close mas
deallocate mas

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200109, 
		@active_end_date=99991231, 
		@active_start_time=5500, 
		@active_end_time=235959, 
		@schedule_uid=N'2bd6bccd-aacc-4998-b861-09603e944a67'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Login_Update_Exec]    Script Date: 11/30/2020 5:03:57 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:03:57 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Login_Update_Exec', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If So Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If So Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')<>0 RAISERROR (''This is the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exec Login Updates]    Script Date: 11/30/2020 5:03:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exec Login Updates', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @cmd varchar(8000)
select * into #login_cmd from ODSPROD.[AARP_Import].[dbo].[login_cmd]
declare l_cmd cursor for select cmd from #login_cmd
open l_cmd
fetch next from l_cmd into @cmd
while @@FETCH_STATUS = 0  
    begin
		exec(@cmd)
		fetch next from l_cmd into @cmd 
    end;
close l_cmd
deallocate l_cmd
drop table #login_cmd

GO

', 
		@database_name=N'AARP_Import', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200109, 
		@active_end_date=99991231, 
		@active_start_time=5500, 
		@active_end_time=235959, 
		@schedule_uid=N'2bd6bccd-aacc-4998-b861-09603e944a67'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Login_Update_Save]    Script Date: 11/30/2020 5:03:58 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:03:58 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Login_Update_Save', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:03:58 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Save Login Updates]    Script Date: 11/30/2020 5:03:58 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Save Login Updates', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec AARP_Import.dbo.ods_sync_logins_save 2
', 
		@database_name=N'AARP_Import', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200109, 
		@active_end_date=99991231, 
		@active_start_time=5500, 
		@active_end_time=235959, 
		@schedule_uid=N'2bd6bccd-aacc-4998-b861-09603e944a67'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_ODSPROD_Post_Failover_Tasks]    Script Date: 11/30/2020 5:03:58 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:03:58 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_ODSPROD_Post_Failover_Tasks', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Availability Group Role]    Script Date: 11/30/2020 5:03:58 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Availability Group Role', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @AgName VARCHAR(64),
        @AgRole VARCHAR(64),
		@PrintMessage VARCHAR(128),
		@DatabaseCount INT,
	    @DatabasesAvailable INT

SET @AgName = ''ODSPROD''
SET @AgRole = ''PRIMARY''

SET @DatabasesAvailable = 0


	SELECT @DatabaseCount = COUNT(*) FROM sys.dm_hadr_database_replica_states AS drs
	  LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
      LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
	  LEFT JOIN sys.dm_hadr_availability_replica_cluster_states AS rcs ON drs.replica_id = rcs.replica_id
    WHERE ag.name = @AgName
	  AND rcs.replica_server_name = @@SERVERNAME

-- Get the number of databases in the availabity group
WHILE @DatabasesAvailable != @DatabaseCount
  BEGIN
	SELECT @DatabaseCount = COUNT(*) FROM sys.dm_hadr_database_replica_states AS drs
	  LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
      LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
	  LEFT JOIN sys.dm_hadr_availability_replica_cluster_states AS rcs ON drs.replica_id = rcs.replica_id
    WHERE ag.name = @AgName
	  AND rcs.replica_server_name = @@SERVERNAME

--  SET @DatabaseCount = 4

	SELECT @DatabasesAvailable = COUNT(*) FROM sys.dm_hadr_database_replica_states AS drs
	  LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
      LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
	  LEFT JOIN sys.dm_hadr_availability_replica_cluster_states AS rcs ON drs.replica_id = rcs.replica_id
    WHERE ag.name = @AgName
	  AND rcs.replica_server_name = @@SERVERNAME
      AND ars.role_desc =  @AgRole
	  AND ars.recovery_health_desc = ''ONLINE''
      AND ars.synchronization_health_desc = ''HEALTHY''
      AND ars.operational_state_desc = ''ONLINE''
	   AND ars.synchronization_health_desc = ''HEALTHY''
	  AND database_state_desc = ''ONLINE''
	WAITFOR DELAY ''00:00:01''
	END
	PRINT N''Server ['' + @@SERVERNAME + ''] availability group ['' + RTRIM(CAST(@AgName AS nvarchar(30))) + ''] Status ['' + @AgRole + ''], '' + 
	     RTRIM(CAST(@DatabasesAvailable AS nvarchar(30))) + '' out of '' + RTRIM(CAST(@DatabaseCount AS nvarchar(30))) + '' are available.''

', 
		@database_name=N'master', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1ODSINST01\JobLog\DBAAdmin_ODSPROD_Post_Failover_Tasks.txt', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Reporting Services Jobs]    Script Date: 11/30/2020 5:03:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Reporting Services Jobs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @TSQL NVARCHAR(MAX) = '''';
SELECT
@TSQL = @TSQL + ''EXEC msdb.dbo.sp_delete_job @job_name = N'''''' + j.name + '''''''' + CHAR(13)
FROM msdb.dbo.sysjobs AS j
JOIN msdb.dbo.syscategories AS c
ON j.category_id = c.category_id
WHERE c.name = N''Report Server'';
EXEC sp_executesql @TSQL;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restart Reporting Services]    Script Date: 11/30/2020 5:03:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restart Reporting Services', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ServiceName = "SQL Server Reporting Services (MSSQLSERVER)"

Get-Service -Name $ServiceName

Get-Service -Name $ServiceName | Where-Object {$_.Status -eq "Running"} | Stop-Service
Get-Service -Name $ServiceName | Where-Object {$_.Status -eq "Stopped"} | Start-Service
Get-Service -Name $ServiceName', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Selected Jobs]    Script Date: 11/30/2020 5:03:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Selected Jobs', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @job_name  VARCHAR(128),
	  @primary_enabled	BIT,
                  @secondary_enabled	BIT,
		@start_immediately	BIT
DECLARE C1 CURSOR READ_ONLY FORWARD_ONLY LOCAL FOR SELECT [job_name], [primary_enabled], [secondary_enabled], [start_immediately] FROM DBAAdmin.dbo.AGJobManagement
OPEN C1;
FETCH C1 INTO @job_name, @primary_enabled, @secondary_enabled, @start_immediately;
WHILE @@FETCH_STATUS = 0
	BEGIN
	  IF @primary_enabled = 1 AND @secondary_enabled = 0
	    BEGIN
		  PRINT ''Job ['' + @job_name + ''] enabled.''
		  BEGIN TRY
		    EXECUTE msdb.dbo.sp_update_job  @job_name = @job_name, @enabled = 1;
		  END TRY
		  BEGIN CATCH
		      SELECT ERROR_NUMBER() AS ErrorNumber,ERROR_MESSAGE() AS ErrorMessage; 
		  END CATCH
		  IF @start_immediately = 1
		    BEGIN
			  
				IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs J JOIN msdb.dbo.sysjobactivity A ON A.job_id=J.job_id WHERE J.name= @job_name AND A.run_requested_date IS NOT NULL AND A.stop_execution_date IS NULL)
					BEGIN
					BEGIN TRY
						PRINT ''Job ['' + @job_name + ''] started.''
						EXECUTE msdb.dbo.sp_start_job @job_name = @job_name;
  					END TRY
					BEGIN CATCH
						SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage; 
					END CATCH
					END
			END		  
		END
      FETCH C1 INTO @job_name, @primary_enabled, @secondary_enabled, @start_immediately;
	END;
CLOSE C1;
DEALLOCATE C1;', 
		@database_name=N'msdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1ODSINST01\JobLog\DBAAdmin_ODSPROD_Post_Failover_Tasks.txt', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Report Post Failover Tasks Complete]    Script Date: 11/30/2020 5:03:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Report Post Failover Tasks Complete', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @mail_profile VARCHAR(64),
		@MailMessage  VARCHAR(1024),
		@MailSubject  VARCHAR(128),
		@MailRecipients VARCHAR(128)

-- Set the mail profile name
SET @mail_profile = @@SERVERNAME + ''Mail''
-- SET @MailRecipients = ''mbrundige@mymoni.com; dmokkala@mymoni.com''
SET @MailRecipients = ''mbrundige@mymoni.com''

SET @MailSubject = N'''' + @@SERVERNAME + ''Post AG Failover COMPLETE''
SET @MailMessage = N''SERVER '' + @@SERVERNAME + '' has completed availability group post failover tasks.''


EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @mail_profile,
			@recipients = @MailRecipients, 
			@body = @MailMessage, @subject = @MailSubject', 
		@database_name=N'master', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1ODSINST01\JobLog\DBAAdmin_ODSPROD_Post_Failover_Tasks.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_ODSPROD_Turn_Down]    Script Date: 11/30/2020 5:03:59 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:03:59 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_ODSPROD_Turn_Down', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'During a PLANNED FAILOVER this job should be run on the ACTIVE PRIMARY for ODSPROD Availability Group.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Reporting Services Jobs]    Script Date: 11/30/2020 5:04:00 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Reporting Services Jobs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @TSQL NVARCHAR(MAX) = '''';
SELECT
@TSQL = @TSQL + ''EXEC msdb.dbo.sp_delete_job @job_name = N'''''' + j.name + '''''''' + CHAR(13)
FROM msdb.dbo.sysjobs AS j
JOIN msdb.dbo.syscategories AS c
ON j.category_id = c.category_id
WHERE c.name = N''Report Server'';
EXEC sp_executesql @TSQL;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stop Selected SQL Server Agent Jobs]    Script Date: 11/30/2020 5:04:00 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stop Selected SQL Server Agent Jobs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @job_name			VARCHAR(128),
	    @primary_enabled	BIT,
		@secondary_enabled	BIT,
		@start_immediately	BIT
DECLARE C1 CURSOR READ_ONLY FORWARD_ONLY LOCAL FOR SELECT [job_name], [primary_enabled], [secondary_enabled], [start_immediately] FROM DBAAdmin.dbo.AGJobManagement WHERE [ag_name] = ''ODSPROD''
OPEN C1;
FETCH C1 INTO @job_name, @primary_enabled, @secondary_enabled, @start_immediately;
WHILE @@FETCH_STATUS = 0
	BEGIN
	  IF @primary_enabled = 1 AND @secondary_enabled = 0
	    BEGIN
                                  IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs J INNER JOIN msdb.dbo.sysjobactivity A ON A.job_id=J.job_id WHERE J.name= @job_name AND A.run_requested_date != NULL AND A.stop_execution_date = NULL)
	                      BEGIN
                                          PRINT ''Job ['' + @job_name + ''] stopped.''
                  BEGIN TRY
  		          EXECUTE msdb.dbo.sp_stop_job @job_name = @job_name;
				  END TRY
				  BEGIN CATCH
				  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage; 
				  END CATCH
                                      END
                                  PRINT ''Job ['' + @job_name + ''] disabled.''
		  BEGIN TRY
		  EXECUTE msdb.dbo.sp_update_job  @job_name = @job_name, @enabled = 0; 
		  END TRY
		  BEGIN CATCH
		  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage; 
		  END CATCH
		END
	  ELSE
	    BEGIN
		  IF @secondary_enabled = 1
		    BEGIN
			  PRINT ''Job ['' + @job_name + ''] enabled.''
			  BEGIN TRY
			  EXECUTE msdb.dbo.sp_update_job  @job_name = @job_name, @enabled = 1;
			  END TRY
			  BEGIN CATCH
			  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage; 
			  END CATCH
			  IF @start_immediately = 1
			    BEGIN

			  IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs J JOIN msdb.dbo.sysjobactivity A ON A.job_id=J.job_id WHERE J.name= @job_name AND A.run_requested_date IS NOT NULL AND A.stop_execution_date IS NULL)
			    BEGIN
				  PRINT ''Job ['' + @job_name + ''] started.''
				  BEGIN TRY
				  EXECUTE msdb.dbo.sp_start_job @job_name = @job_name;
				  END TRY
				  BEGIN CATCH
				  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage; 
				  END CATCH
                                                    END
				END
			END
		END
      FETCH C1 INTO @job_name, @primary_enabled, @secondary_enabled, @start_immediately;
	END;
CLOSE C1;
DEALLOCATE C1;


', 
		@database_name=N'msdb', 
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1ODSINST01\JOBLOG\DBAAdmin_ODSPROD_Turn_Down.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_OnSQLAgentRestart]    Script Date: 11/30/2020 5:04:00 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:04:00 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_OnSQLAgentRestart', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'send alert that agent has restarted, also, add Vince and Stacy back as users in tempdb', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [add users to tempdb]    Script Date: 11/30/2020 5:04:00 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'add users to tempdb', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [tempdb]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\srogers'')
DROP USER [PMS\srogers]
GO
CREATE USER [PMS\srogers] FOR LOGIN [PMS\srogers]
GO
EXEC sp_addrolemember N''db_owner'', N''PMS\srogers''
GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\ogalindo'')
DROP USER [PMS\ogalindo]
GO
CREATE USER [PMS\ogalindo] FOR LOGIN [PMS\ogalindo] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N''db_owner'', N''PMS\ogalindo''
GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\DB_RptgDataReaderOnly_MI_JRORD'')
DROP USER [PMS\DB_RptgDataReaderOnly_MI_JRORD]
GO
CREATE USER [PMS\DB_RptgDataReaderOnly_MI_JRORD] FOR LOGIN [PMS\DB_RptgDataReaderOnly_MI_JRORD]
GO
GRANT SHOWPLAN TO [PMS\DB_RptgDataReaderOnly_MI_JRORD]
GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\Business Support Server Access'')
DROP USER [PMS\Business Support Server Access]
GO
CREATE USER [PMS\Business Support Server Access] FOR LOGIN [PMS\Business Support Server Access]
GO
EXEC sp_addrolemember N''db_owner'', [PMS\Business Support Server Access]
GO', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [send alert]    Script Date: 11/30/2020 5:04:00 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'send alert', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @msg varchar(50)
select @msg=@@SERVERNAME+'':  SQLAgent Restarted''
exec msdb.dbo.sp_send_dbmail 
	@profile_name=null
	 , @subject=@msg
	,  @body=''Stacy added back as db_owner into tempdb; turned deadlock capture trace flag 1222 on'' 
	 , @recipients=''dbateam@monitronics.com''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'on sql agent restart', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100713, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'95918dac-84b8-471a-a808-39dbb5b43cb8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Save_ODS_SQL_Agent_Jobs]    Script Date: 11/30/2020 5:04:00 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:00 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Save_ODS_SQL_Agent_Jobs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Save ODS SQL Agent Jobs]    Script Date: 11/30/2020 5:04:01 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Save ODS SQL Agent Jobs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'


if @@servername = ''WP1ODSINST01''
begin
	delete from openquery(MASF, ''select name from DBAAdmin.dbo.jobname_WP1ODSINST01'')
end

if @@servername = ''VV1ODSINST01''
begin
	delete from openquery(MASF, ''select name from DBAAdmin.dbo.jobname_VV1ODSINST01'')
end

if @@servername = ''WP1ODSINST01''
	insert into openquery(MASF, ''select name from DBAAdmin.dbo.jobname_WP1ODSINST01'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		order by name

if @@servername = ''VV1ODSINST01''
	insert into openquery(MASF, ''select name from DBAAdmin.dbo.jobname_VV1ODSINST01'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		order by name
', 
		@database_name=N'DBAAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190503, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'e1ea38dc-63c6-454f-a3e6-2f692fb9c4d5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Save_Passwords]    Script Date: 11/30/2020 5:04:01 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:01 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Save_Passwords', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary]    Script Date: 11/30/2020 5:04:01 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Save_Passwords]    Script Date: 11/30/2020 5:04:01 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Save_Passwords', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
if master.dbo.svf_AgReplicaState(''MASPROD'') > 0
begin
begin tran
delete mi_custom.dbo.login_pwd_cmds
insert mi_custom.dbo.login_pwd_cmds SELECT N''ALTER LOGIN [''+sp.[name]+''] WITH PASSWORD=0x''+
       CONVERT(nvarchar(max), l.password_hash, 2)+N'' HASHED, CHECK_POLICY=OFF''+N'';''
FROM master.sys.server_principals AS sp
INNER JOIN master.sys.sql_logins AS l ON sp.[sid]=l.[sid]
WHERE sp.[type]=''S'' AND sp.is_disabled=0 AND sp.[name] like ''mas!_%'' ESCAPE ''!'' order by sp.[name];
commit tran
end
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180919, 
		@active_end_date=99991231, 
		@active_start_time=5000, 
		@active_end_time=235000, 
		@schedule_uid=N'ee507480-45a2-4de7-8ee2-9ec963e22bdf'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Sync_ODSPROD_Logins]    Script Date: 11/30/2020 5:04:02 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 5:04:02 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Sync_ODSPROD_Logins', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job that will sync logins from the PRIMARY to secondary REPLICAS.  This is for the ODSPROD availability group ONLY.  Scheduled to run hourly.  It is recommended that this job be run prior to a scheduled failover.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sync Logins via PowerShell]    Script Date: 11/30/2020 5:04:02 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sync Logins via PowerShell', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -ExecutionPolicy Bypass \\wp1nas01\SQLBackup\WP1ODSINST01\Scripts\SyncLogins.ps1', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1ODSINST01\JobLog\SyncLogins.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180227, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'dcdbd647-a11d-475d-adef-d461ff016440'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Sync_Passwords]    Script Date: 11/30/2020 5:04:02 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:02 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Sync_Passwords', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'BRINKS\gMtMSQL_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Secondary]    Script Date: 11/30/2020 5:04:03 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Secondary', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')>0 RAISERROR (''This is not a secondary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sync Passweords]    Script Date: 11/30/2020 5:04:03 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sync Passweords', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'if master.dbo.svf_AgReplicaState(''MASPROD'') = 0
begin
declare @cmd nvarchar(2000)
declare cmd_list cursor for
select cmd from mi_custom.dbo.login_pwd_cmds
open cmd_list
fetch next from cmd_list into @cmd
while @@fetch_status = 0
begin
exec(@cmd)
fetch next from cmd_list into @cmd
end
close cmd_list
deallocate cmd_list
end
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_UpdateStats]    Script Date: 11/30/2020 5:04:03 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:03 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_UpdateStats', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:03 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [UpdStats]    Script Date: 11/30/2020 5:04:03 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'UpdStats', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_custom
GO
exec sp_updatestats
GO
use mi_masdb
GO
exec sp_updatestats
GO
use mi_mondb
GO
exec sp_updatestats
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200109, 
		@active_end_date=99991231, 
		@active_start_time=5500, 
		@active_end_time=235959, 
		@schedule_uid=N'2bd6bccd-aacc-4998-b861-09603e944a67'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DbObjects_Archive]    Script Date: 11/30/2020 5:04:04 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:04 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DbObjects_Archive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:04 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Arive the sysobjects table for the three MAS databases]    Script Date: 11/30/2020 5:04:04 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Arive the sysobjects table for the three MAS databases', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use SSISDB

if object_id(''DbObjects_Archive'') is NULL
begin
	select getdate() as archive_date, ''                    '' as dbname, * into DbObjects_Archive from mi_custom.dbo.sysobjects where 0=1
end

insert DbObjects_Archive select getdate() as archive_date, ''mi_custom'' as db_bame, * from mi_custom.dbo.sysobjects
insert DbObjects_Archive select getdate() as archive_date, ''mi_masdb'' as db_bame, * from mi_masdb.dbo.sysobjects
insert DbObjects_Archive select getdate() as archive_date, ''mi_mondb'' as db_bame, * from mi_mondb.dbo.sysobjects

', 
		@database_name=N'SSISDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190211, 
		@active_end_date=99991231, 
		@active_start_time=210000, 
		@active_end_time=235959, 
		@schedule_uid=N'e2e92a60-981e-47f2-a13d-3872d9daa8ba'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [InsertLTEJobLine]    Script Date: 11/30/2020 5:04:04 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:04 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'InsertLTEJobLine', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Insert LTE Upgrade job line', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [InsertLTEJobLine]    Script Date: 11/30/2020 5:04:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'InsertLTEJobLine', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_ap_add_lte_job_line', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'LTE job line insert', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190731, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'69c9af27-698b-4e9a-8d42-44de436bc30f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [JobManagementDQCleanUp]    Script Date: 11/30/2020 5:04:06 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 5:04:06 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JobManagementDQCleanUp', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'closes or cancel sjobs that have been in D or Q status for more than 90 days.', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:06 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [mi_cp_Job_Management_Update_AgedDQJobs]    Script Date: 11/30/2020 5:04:06 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_cp_Job_Management_Update_AgedDQJobs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_masdb.dbo.mi_cp_Job_Management_Update_AgedDQJobs 1, 997', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST01\BackupWP1MASINST01\JobLog\mi_cp_Job_Management_Update_AgedDQJobs.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1am daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100810, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'dde04b93-0b87-456c-9a00-0e88a6c1e131'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [JobManagementRuleEngine]    Script Date: 11/30/2020 5:04:07 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 5:04:07 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JobManagementRuleEngine', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update job status level as business rules have been violated', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'PMS\SVC_SQL2K8_Prod', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:08 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [UpdateJobStatusLevel]    Script Date: 11/30/2020 5:04:08 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'UpdateJobStatusLevel', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_cp_job_management_rule_engine 997', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'E:\JobLogs\JobManagementRuleEngine.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'JobManagementDaily15Min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20080707, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'6f7c39c6-037e-4724-af19-faebb9b37d23'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Load_BW_2G]    Script Date: 11/30/2020 5:04:08 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 5:04:08 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Load_BW_2G', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute_mi_ap_load_bw_2g]    Script Date: 11/30/2020 5:04:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute_mi_ap_load_bw_2g', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_ap_load_bw_2g', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST01\BackupWP1MASINST01\JobLog\mi_ap_load_bw_2g.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Nightly at 3am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150928, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'7668c52f-ab1f-443a-b925-274bf657242d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [LoadLTESitesTable]    Script Date: 11/30/2020 5:04:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:09 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'LoadLTESitesTable', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Load table containing LTE upgrade eligible sites', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LoadLTESitesTable]    Script Date: 11/30/2020 5:04:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LoadLTESitesTable', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_load_lte_sites', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Evening', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190731, 
		@active_end_date=99991231, 
		@active_start_time=210000, 
		@active_end_time=235959, 
		@schedule_uid=N'bc544f75-4d7c-4509-b872-3c686844d297'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Morning', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190731, 
		@active_end_date=99991231, 
		@active_start_time=90000, 
		@active_end_time=235959, 
		@schedule_uid=N'3cae22e8-9974-4d82-ad99-4fb09df45cc9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [LoadMPSTables]    Script Date: 11/30/2020 5:04:10 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:11 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'LoadMPSTables', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Load tables in MPS databases', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:11 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LoadMPSTables]    Script Date: 11/30/2020 5:04:11 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LoadMPSTables', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'"D:\MI-SSIS\Commands\LoadMPSTables.bat"', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily2AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20090422, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'ef1cd607-a7e5-43af-a39b-f305ba854618'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [mi_custom replfast purge]    Script Date: 11/30/2020 5:04:11 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Replication]    Script Date: 11/30/2020 5:04:11 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Replication' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Replication'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'mi_custom replfast purge', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_custom replfast purge', 
		@category_name=N'Replication', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step #1]    Script Date: 11/30/2020 5:04:12 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step #1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.ap__repl_keeprunning purge, @repl_type=''fast''', 
		@database_name=N'mi_custom', 
		@output_file_name=N'\\srvalch01\MASout\JobLogs\WP1MASINST01_replfast_purge.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Regular', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161201, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'42eb5fe2-4dd9-4fa2-89a4-4fe49fd71d03'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [mi_jrord_JurisdictionsApplicationProcess_LicenseUpdates]    Script Date: 11/30/2020 5:04:12 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:12 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'mi_jrord_JurisdictionsApplicationProcess_LicenseUpdates', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Nightly process to automatically update: Licenses with Expired or Planned Termination Status', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'reporter', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXEC jur.sp_auto_license_status_update]    Script Date: 11/30/2020 5:04:12 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC jur.sp_auto_license_status_update', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC jur.sp_auto_license_status_update', 
		@database_name=N'mi_jrord', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'mi_jrord Application Process Updates', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180827, 
		@active_end_date=99991231, 
		@active_start_time=30, 
		@active_end_time=235959, 
		@schedule_uid=N'0d4b031a-5058-44e6-9706-f2afc1235ecb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [mi_jrord_JurisdictionsApplicationProcess_MASActivityUpdates]    Script Date: 11/30/2020 5:04:13 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:13 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'mi_jrord_JurisdictionsApplicationProcess_MASActivityUpdates', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Nightly process to automatically update alarm_response_credits, guard_billing, and agency_summary tables with recent activity', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'reporter', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXEC jur.sp_jurisdiction_alarm_response_credits_update]    Script Date: 11/30/2020 5:04:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC jur.sp_jurisdiction_alarm_response_credits_update', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC jur.sp_jurisdiction_alarm_response_credits_update', 
		@database_name=N'mi_jrord', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXEC jur.sp_jurisdiction_guard_billing_update]    Script Date: 11/30/2020 5:04:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC jur.sp_jurisdiction_guard_billing_update', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC jur.sp_jurisdiction_guard_billing_update', 
		@database_name=N'mi_jrord', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXEC jur.sp_jurisdiction_agency_summary_update]    Script Date: 11/30/2020 5:04:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC jur.sp_jurisdiction_agency_summary_update', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC jur.sp_jurisdiction_agency_summary_update', 
		@database_name=N'mi_jrord', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'mi_jrord Update Alarm Response Credits', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180827, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959, 
		@schedule_uid=N'cfd0c8d1-7a77-4df4-b849-19154f29688d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [mi_masdb Task #975 (q_prod01)]    Script Date: 11/30/2020 5:04:14 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS_BUS]    Script Date: 11/30/2020 5:04:14 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS_BUS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS_BUS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'mi_masdb Task #975 (q_prod01)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_masdb Task #975 (q_prod01)', 
		@category_name=N'MAS_BUS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Task #975]    Script Date: 11/30/2020 5:04:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #975', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec ap_start_task 975', 
		@database_name=N'mi_masdb', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Regular', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20090311, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c2e7903a-c03f-4dbf-bc8b-7d4ba847cea3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [mi_process_amarev_actions]    Script Date: 11/30/2020 5:04:15 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:15 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'mi_process_amarev_actions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Processes open AMAREV actions that fall under certain criteria. This includes AMAREV actions for contracts that are currently M2M, Renewal, INIT, or EXT and have 60 months or less being added to them', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary]    Script Date: 11/30/2020 5:04:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process M2M/Renewal AMAREV Actions]    Script Date: 11/30/2020 5:04:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process M2M/Renewal AMAREV Actions', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[mi_cp_process_open_amarev_m2m_renewal] 997', 
		@database_name=N'mi_masdb', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process INIT/EXT AMAREV Actions]    Script Date: 11/30/2020 5:04:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process INIT/EXT AMAREV Actions', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[mi_cp_process_open_amarev_init_ext] 997', 
		@database_name=N'mi_masdb', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process System Move M2M/Renewal AMAREV Actions]    Script Date: 11/30/2020 5:04:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process System Move M2M/Renewal AMAREV Actions', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[mi_cp_process_open_amarev_sysmove_m2m_renewal] 997', 
		@database_name=N'mi_masdb', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process System Move INIT/EXT AMAREV Actions]    Script Date: 11/30/2020 5:04:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process System Move INIT/EXT AMAREV Actions', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[mi_cp_process_open_amarev_sysmove_init_ext] 997', 
		@database_name=N'mi_masdb', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'NightlyProcessActions', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190122, 
		@active_end_date=99991231, 
		@active_start_time=170000, 
		@active_end_time=235959, 
		@schedule_uid=N'11197db0-5386-4f85-9dc6-3bb016174e9e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Monitor - Log Files]    Script Date: 11/30/2020 5:04:16 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Instance Monitor]    Script Date: 11/30/2020 5:04:16 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Instance Monitor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Instance Monitor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Monitor - Log Files', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Check for databases whose transaction logs are nearing capacity.', 
		@category_name=N'Instance Monitor', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check for databases whose transaction logs are nearing capacity.]    Script Date: 11/30/2020 5:04:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check for databases whose transaction logs are nearing capacity.', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.MonitorLogFiles', 
		@database_name=N'DBAADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monitor - Log Files', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=19900101, 
		@active_end_date=99991231, 
		@active_start_time=1200, 
		@active_end_time=235959, 
		@schedule_uid=N'c6b94e66-0117-4fba-b1e3-ea8ca901a6ed'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [NEST FULFILLMENT FILE GENERATOR]    Script Date: 11/30/2020 5:04:16 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:16 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'NEST FULFILLMENT FILE GENERATOR', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RUN_PACKAGE]    Script Date: 11/30/2020 5:04:17 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RUN_PACKAGE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Fulfillment CSV File Gen.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily execution', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20171203, 
		@active_end_date=99991231, 
		@active_start_time=180000, 
		@active_end_time=235959, 
		@schedule_uid=N'f0b573c6-8a6b-45eb-ba3a-f3c1312cb300'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Populate_PMSOLD_tblrecurringcostrecon]    Script Date: 11/30/2020 5:04:17 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:17 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Populate_PMSOLD_tblrecurringcostrecon', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'moves data from mi_mondb to PMSOLD on SQL3', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'PMS\sqlmanjob', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:17 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run SSIS pkg]    Script Date: 11/30/2020 5:04:17 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run SSIS pkg', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/SQL "\"\Recurring Cost Recon\"" /SERVER "\"MASPROD,4275\"" /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@output_file_name=N'D:\JOBS\Populate_PMSOLD_tblrecurringcostrecon.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily @ 11pm', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100202, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, 
		@schedule_uid=N'7e8b2333-06c8-44ca-bfed-9b954aeaaaa8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [PopulatepmsoldSAMFinalizeBPPArchiveList]    Script Date: 11/30/2020 5:04:17 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:17 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PopulatepmsoldSAMFinalizeBPPArchiveList', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Runn SSIS]    Script Date: 11/30/2020 5:04:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Runn SSIS', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\Populate pmsold FinalizeBPPArchiveList.dtsx\"" /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'on demand', 
		@enabled=0, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20200723, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e8de2f29-ef4f-45aa-989b-923dce0dcbd8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Powershell Sox]    Script Date: 11/30/2020 5:04:18 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:18 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Powershell Sox', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Script 1]    Script Date: 11/30/2020 5:04:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Script 1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$script_path = Split-Path $script:MyInvocation.MyCommand.Path
$output_path = "$script_path\Output\$(Get-Date -Format MM_dd_yy)"
New-Item -ItemType Directory -Force -Path $output_path | Out-Null

$log = "$output_path\sql_database_audit_error.log"
$input = Import-Csv "$script_path\sql_database_audit_input.csv"
$servers = $input | group-object -Property Server

$output = @()

foreach ($server in $servers) {
    $databases = $server.Group | group-object -Property Database
    foreach($database in $databases) {
        $script = "
        -- Declare some variables
        DECLARE @sql_version NVARCHAR(128),
	    @sql_major_version int;

        -- Get the sql version string from server properties
        SELECT @sql_version = CAST(SERVERPROPERTY(''productversion'') AS NVARCHAR(128));

        -- Break off the sql major version from the start of the version
        SELECT @sql_major_version = LEFT(@sql_version, CHARINDEX(''.'', @sql_version)-1)
    
        IF @sql_major_version < 10
        BEGIN
            SELECT 
            a.name as MemberName, 
            USER_NAME(b.groupuid) AS ''RoleName''
            from sysusers a 
            LEFT OUTER JOIN sysmembers b 
                ON a.uid=b.memberuid 
            WHERE USER_NAME(b.groupuid) IN (''$($server.Group.''Group/Role'' -join '''''','''''')'')  
            ORDER BY a.name
        END
        ELSE
        BEGIN
            SELECT 
            DP1.name AS RoleName,   
            DP2.name AS MemberName   
            FROM sys.database_role_members AS DRM  
            RIGHT OUTER JOIN sys.database_principals AS DP1  
                ON DRM.role_principal_id = DP1.principal_id  
            LEFT OUTER JOIN sys.database_principals AS DP2  
                ON DRM.member_principal_id = DP2.principal_id  
            WHERE DP1.type = ''R'' and DP1.name IN (''$($server.Group.''Group/Role'' -join '''''','''''')'') and DP2.name IS NOT NULL
            ORDER BY DP1.name;

        END
        "
        try {

            $output += Invoke-Sqlcmd $script `
            -ServerInstance $server.Name `
            -Database $database.Name |
            select  @{l="Type"; e={$database.Group[0].Type}}, 
                    @{l="Server"; e={$server.Name}}, 
                    @{l="Database"; e={$database.Name}}, 
                    RoleName, 
                    MemberName,  
                    @{l="CurrentTime"; e={Get-Date}}
        } catch {
            Add-Content $log -value "Server=''$($server.Name)''  Database=''$($database.Name)'' Error=''$($_|Out-String)''"
            $output += '''' | select @{l="Type"; e={$database.Group[0].Type}}, 
                        @{l="Server"; e={$server.Name}}, 
                        @{l="Database"; e={$database.Name}}, 
                        @{l="RoleName"; e={''ERROR''}}, 
                        @{l="MemberName"; e={''ERROR''}}, 
                        @{l="CurrentTime"; e={Get-Date}}
        }
    }
}

$output | Export-Csv -NoTypeInformation "$output_path\sql_database_audit.csv"
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [script 2]    Script Date: 11/30/2020 5:04:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'script 2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$script_path = Split-Path $script:MyInvocation.MyCommand.Path
$output_path = "$script_path\Output\$(Get-Date -Format MM_dd_yy)"
New-Item -ItemType Directory -Force -Path $output_path | Out-Null

$log = "$output_path\sql_server_audit_error.log"
$input = Import-Csv "$script_path\sql_server_audit_input.csv"
$servers = $input | group-object -Property Server

$output = @()
foreach ($server in $servers) {
    $script = "
    -- Declare some variables
    DECLARE @sql_version NVARCHAR(128),
	@sql_major_version int;

    -- Get the sql version string from server properties
    SELECT @sql_version = CAST(SERVERPROPERTY(''productversion'') AS NVARCHAR(128));

    -- Break off the sql major version from the start of the version
    SELECT @sql_major_version = LEFT(@sql_version, CHARINDEX(''.'', @sql_version)-1)
    
    IF @sql_major_version < 10
    BEGIN
        CREATE TABLE #ServerRoles (
          ServerRole VARCHAR(20),
          MemberName sysname,
          sid VARBINARY(85)
        ); 

        INSERT INTO #ServerRoles
        (ServerRole, MemberName, sid)
        EXEC sp_helpsrvrolemember;

        SELECT SL.name AS MemberName, SR.ServerRole AS RoleName
        FROM syslogins SL
          JOIN #ServerRoles SR
            ON SL.sid = SR.sid
        WHERE SR.ServerRole in (''$($server.Group.''Group/Role'' -join '''''','''''')'')
        ORDER BY SL.name, SR.ServerRole;
    
        DROP TABLE #ServerRoles;
    END
    ELSE
    BEGIN
        SELECT role.name AS RoleName,   
        member.name AS MemberName  
        FROM sys.server_role_members  
        JOIN sys.server_principals AS role  
            ON sys.server_role_members.role_principal_id = role.principal_id  
        JOIN sys.server_principals AS member  
            ON sys.server_role_members.member_principal_id = member.principal_id 
        WHERE role.name in (''$($server.Group.''Group/Role'' -join '''''','''''')'')
    END

    "
    try {
        $output += Invoke-Sqlcmd $script `
        -ServerInstance $server.Name |
        select  @{l="Type"; e={$server.Group[0].Type}}, 
                @{l="Server"; e={$server.Name}}, 
                RoleName, 
                MemberName,  
                @{l="CurrentTime"; e={Get-Date}}

    } catch {
        Add-Content $log -value "Server=''$($server.Name)'' Error=''$($_|Out-String)''"

        $output += '''' | select @{l="Type"; e={$server.Group[0].Type}}, 
                    @{l="Server"; e={$server.Name}}, 
                    @{l="RoleName"; e={''ERROR''}}, 
                    @{l="MemberName"; e={''ERROR''}}, 
                    @{l="CurrentTime"; e={Get-Date}}
    }
}

$output | Export-Csv -NoTypeInformation "$output_path\sql_server_audit.csv"', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Refresh_qa_completed_detail]    Script Date: 11/30/2020 5:04:18 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:18 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Refresh_qa_completed_detail', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Refresh]    Script Date: 11/30/2020 5:04:19 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Refresh', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'delete qa_completed_detail
insert qa_completed_detail select * from openquery(WP1SQL02, ''select * from Uptivity.dbo.qa_completed_detail'')
', 
		@database_name=N'Uptivity', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200225, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'e231b8f2-f91d-4e4d-ac25-8e9669e829bd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Reinitialize subscriptions having data validation failures]    Script Date: 11/30/2020 5:04:19 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [REPL-Alert Response]    Script Date: 11/30/2020 5:04:19 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'REPL-Alert Response' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Alert Response'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Reinitialize subscriptions having data validation failures', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Reinitializes all subscriptions that have data validation failures.', 
		@category_name=N'REPL-Alert Response', 
		@owner_login_name=N'PMS\cntr_mokkadi', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run agent.]    Script Date: 11/30/2020 5:04:19 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run agent.', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec sys.sp_MSreinit_failed_subscriptions @failure_level = 1', 
		@server=N'WP1ODSINST01', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Replication agents checkup]    Script Date: 11/30/2020 5:04:19 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [REPL-Checkup]    Script Date: 11/30/2020 5:04:20 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'REPL-Checkup' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Checkup'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Replication agents checkup', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Detects replication agents that are not logging history actively.', 
		@category_name=N'REPL-Checkup', 
		@owner_login_name=N'PMS\cntr_mokkadi', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run agent.]    Script Date: 11/30/2020 5:04:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run agent.', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'sys.sp_replication_agent_checkup @heartbeat_interval = 10', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Replication agent schedule.', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=1, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200710, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd01ea2b9-a4b6-4b0a-8b3d-348fe3fca27f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Replication monitoring refresher for distribution.]    Script Date: 11/30/2020 5:04:20 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [REPL-Alert Response]    Script Date: 11/30/2020 5:04:20 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'REPL-Alert Response' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Alert Response'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Replication monitoring refresher for distribution.', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Replication monitoring refresher for distribution.', 
		@category_name=N'REPL-Alert Response', 
		@owner_login_name=N'PMS\cntr_mokkadi', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run agent.]    Script Date: 11/30/2020 5:04:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run agent.', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=2147483647, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.sp_replmonitorrefreshjob  ', 
		@server=N'WP1ODSINST01', 
		@database_name=N'distribution', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Replication agent schedule.', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200710, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'01cd23f8-3992-4068-a66f-ff8119d566cd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM Mapback TBD]    Script Date: 11/30/2020 5:04:21 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:21 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM Mapback TBD', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step_1]    Script Date: 11/30/2020 5:04:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step_1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/SQL "\SAM Mapback ODSPROD\Mapback" /SERVER SRVSSIS01 /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180828, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'71f53452-0821-4f6e-b036-9feeb3f78528'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_2', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180829, 
		@active_end_date=99991231, 
		@active_start_time=190000, 
		@active_end_time=235959, 
		@schedule_uid=N'be7daf05-5369-49d3-8759-73064a59f986'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_Appared_SQL3_to_CHAPLIN]    Script Date: 11/30/2020 5:04:22 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:22 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_Appared_SQL3_to_CHAPLIN', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute SSIS package to migrate Appar data from SQL3 to CHAPLIN.SAM', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE - Appared]    Script Date: 11/30/2020 5:04:22 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE - Appared', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Appared.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'RUN SCHEDULE - Appared_SQL3_to_CHAPLIN', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150529, 
		@active_end_date=99991231, 
		@active_start_time=15900, 
		@active_end_time=235959, 
		@schedule_uid=N'bea59ed7-8445-4b35-b2b2-cbc06f57c495'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_Billing_Recon]    Script Date: 11/30/2020 5:04:22 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:22 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_Billing_Recon', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Loads SAM to MAS Detail and MAS to SAM Detail tables with AR numbers to match Billing Recon report.  F0124016.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RUN SSIS Package - BillingReconDataBuild]    Script Date: 11/30/2020 5:04:23 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RUN SSIS Package - BillingReconDataBuild', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Billing Recon Data Build.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule - BillingReconDataBuild', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150820, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'77a9fb31-ea1a-42d1-b372-6b33cf228536'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_Holdback_2501]    Script Date: 11/30/2020 5:04:23 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:23 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_Holdback_2501', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute SSIS Package for SAM Holdback 2501', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE]    Script Date: 11/30/2020 5:04:23 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Holdback Reconciliation 2501.dtsx\"" /CONNECTION "\"CHAPLIN,4275.SAM\"";"\"Data Source=CHAPLIN,4275;Initial Catalog=SAM;Provider=SQLOLEDB.1;Integrated Security=SSPI;Application Name=SSIS-Holdback Reconciliation - Rerun Load-{A7ACCF00-E9E8-4B62-BED9-F402AD7D5D7D}CHAPLIN,4275.SAM;\"" /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Schedule - Holdback_2501', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150528, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'ea2b3136-ef7b-44f4-b6f9-6b2ad710362d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_Holdback_Recon_DataLoad]    Script Date: 11/30/2020 5:04:24 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:24 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_Holdback_Recon_DataLoad', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute SSIS Packages for SAM Holdback Recon DataLoad process.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE - DataLoad]    Script Date: 11/30/2020 5:04:24 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE - DataLoad', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Holdback Reconciliation Data Load.dtsx\"" /CONNECTION "\"CHAPLIN,4275.SAM\"";"\"Data Source=CHAPLIN,4275;Initial Catalog=SAM;Provider=SQLOLEDB;Integrated Security=SSPI;Auto Translate=False;Application Name=SSIS-Holdback Reconciliation Data Load-{8BEF6B72-9C8D-41C0-AA77-F38E748F0879}CHAPLIN,4275.SAM;\"" /CONNECTION "\"SAMUATODS1.SAMUAT_REPORTING\"";"\"Data Source=ODSPROD,4275;Initial Catalog=SAM;Provider=SQLOLEDB;Integrated Security=SSPI;Auto Translate=False;Application Name=SSIS-Package2-{B4B732D0-7BB3-48FA-BB0C-11306B5805A3}SAMUATODS1.SAMUAT_REPORTING;\"" /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Schedule - Holdback_Recon_DataLoad', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150528, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'819ca339-9037-4372-8d85-b0cded78c9bd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_Holdback_Rerun_Load]    Script Date: 11/30/2020 5:04:24 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:24 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_Holdback_Rerun_Load', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute SSIS Package for the SAM Holdback Rerun Load process', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE]    Script Date: 11/30/2020 5:04:25 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Holdback Reconciliation - Rerun Load.dtsx\"" /CONNECTION "\"CHAPLIN,4275.SAM\"";"\"Data Source=CHAPLIN,4275;Initial Catalog=SAM;Provider=SQLOLEDB;Integrated Security=SSPI;Auto Translate=False;Application Name=SSIS-Holdback Reconciliation Data Load-{8BEF6B72-9C8D-41C0-AA77-F38E748F0879}CHAPLIN,4275.SAM;\"" /CONNECTION "\"SAMUATODS1.SAMUAT_REPORTING\"";"\"Data Source=ODSPROD,4275;Initial Catalog=SAM;Provider=SQLOLEDB;Integrated Security=SSPI;Auto Translate=False;Application Name=SSIS-Package2-{B4B732D0-7BB3-48FA-BB0C-11306B5805A3}SAMUATODS1.SAMUAT_REPORTING;\"" /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Schedule - Holdback_Rerun_load', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150528, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'c31f4a62-dec9-400f-ace6-6b7608be0eda'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_PMS_SLX_Daily_Update]    Script Date: 11/30/2020 5:04:25 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:25 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_PMS_SLX_Daily_Update', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute SAM Appar, CoCompare, SalesLogix Tables and SurveyLogs SSIS packages.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE - Appared]    Script Date: 11/30/2020 5:04:25 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE - Appared', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Appared.dtsx\"" /CONNECTION "\"CHAPLIN.PMSOLD\"";"\"Data Source=ODSPROD,4275;Initial Catalog=pmsold;Provider=SQLOLEDB.1;Integrated Security=SSPI;Application Name=SSIS-Appared-{29023D2A-31C8-45B4-81DF-DD6A092EC40A}CHAPLIN.PMSOLD;\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE - CoCompare]    Script Date: 11/30/2020 5:04:25 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE - CoCompare', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\CoCompare.dtsx\"" /CONNECTION "\"CHAPLIN.PMSOLD\"";"\"Data Source=ODSPROD,4275;Initial Catalog=pmsold;Provider=SQLOLEDB.1;Integrated Security=SSPI;Application Name=SSIS-Appared-{29023D2A-31C8-45B4-81DF-DD6A092EC40A}CHAPLIN.PMSOLD;\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE - SalesLogix Tables]    Script Date: 11/30/2020 5:04:25 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE - SalesLogix Tables', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\SalesLogix Tables.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE - SurveyLog]    Script Date: 11/30/2020 5:04:26 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE - SurveyLog', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\SurveyLogs.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Schedule - PMS_SLX_Daily_Update', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150528, 
		@active_end_date=99991231, 
		@active_start_time=12500, 
		@active_end_time=235959, 
		@schedule_uid=N'343c6ee2-261a-4716-9a01-342c7ba0ad20'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_PushCMAccts]    Script Date: 11/30/2020 5:04:26 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:26 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_PushCMAccts', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute PushCMAccts SSIS package in support of SAM.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE - PushCMAccts]    Script Date: 11/30/2020 5:04:26 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE - PushCMAccts', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\PushCMAcctsPackage.dtsx\"" /CONNECTION "\"MI_CUSTOM\"";"\"Data Source=MASPROD,4275;Initial Catalog=mi_custom;Provider=SQLOLEDB.1;Integrated Security=SSPI;Auto Translate=False;Application Name=SSIS-Package-{0975B48A-7A35-4F77-AD8F-950BD3342621}PREDATOR.SAM_custom.samdev;\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'RUN Schedule - PushCMAccts', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150531, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'f7249913-809b-4e0b-ac5c-ff967a79e543'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_TO_PMS]    Script Date: 11/30/2020 5:04:26 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:26 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_TO_PMS', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'NT AUTHORITY\SYSTEM', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXEC PACKAGE]    Script Date: 11/30/2020 5:04:27 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC PACKAGE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Packages\MAPBACK FRESH\Mapback.dtsx" /CONNECTION Audit;"\"Data Source=ODSPROD,4275;Initial Catalog=Audit;Provider=SQLNCLI10.1;Integrated Security=SSPI;Application Name=SSIS-Mapback-{0A610CA4-9B88-45B6-96C7-5496785736D0}Audit;\"" /CONNECTION PMS;"\"Data Source=SQL3;Initial Catalog=pmsold;Provider=SQLNCLI10.1;Integrated Security=SSPI;Auto Translate=False;Application Name=SSIS-Mapback-{1CE8F0F8-B585-4BA9-8986-699832FCD2E1}sql3.pmsold;\"" /CONNECTION PMSStaging;"\"Data Source=SQL3;Initial Catalog=pmsold;Provider=SQLNCLI10.1;Integrated Security=SSPI;Application Name=SSIS-Mapback-{FBD4A7AF-7F2A-40E4-9496-879FDE15DBA0}PMSStaging;\"" /CONNECTION Revshare;"\"Data Source=\\krypton\E\DBE\Revshare.mdb;Provider=Microsoft.Jet.OLEDB.4.0;\"" /CONNECTION SalesLogix;"\"Data Source=SQL3;Initial Catalog=SalesLogix;Provider=SQLNCLI10.1;Integrated Security=SSPI;Application Name=SSIS-Mapback-{989B28F5-DC6B-4AA6-A0C7-883B03992D8C}SalesLogix;\"" /CONNECTION SAM;"\"Data Source=CHAPLIN,4275;Initial Catalog=SAM;Provider=SQLNCLI10.1;Integrated Security=SSPI;Application Name=SSIS-Mapback-{DFA0EB58-DFE7-4713-822C-0370DF9CBFD1}SAM;\"" /CONNECTION SAMStaging;"\"Data Source=ODSPROD,4275;Initial Catalog=SAM_MapbackStg;Provider=SQLNCLI10.1;Integrated Security=SSPI;Application Name=SSIS-Mapback-{F508937C-CE7E-426F-A895-FDD6F87F6C90}SAMStaging;\"" /CONNECTION SSIS;"\"Data Source=SRVSSIS01,4275;Provider=SQLNCLI10.1;Integrated Security=SSPI;Application Name=SSIS-Mapback-{33A326F5-1C18-4094-A560-8797FEF6802D}SSIS;\"" /CONNECTION TablesForMigration;"\"Data Source=\\krypton\e\SAMDataMigration\TablesForMigration.mdb;Provider=Microsoft.Jet.OLEDB.4.0;\"" /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule', 
		@enabled=0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180829, 
		@active_end_date=20180901, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'7b14937f-356d-40a3-995c-5167e86763e5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAM_UpdateDMSFromSAM]    Script Date: 11/30/2020 5:04:27 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:27 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAM_UpdateDMSFromSAM', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update DMS From SAM SSIS Package', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS Package - UpdateDMSFromSAM]    Script Date: 11/30/2020 5:04:27 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS Package - UpdateDMSFromSAM', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\UpdateDMSFromSAM.dtsx\"" /CONNECTION DealerManagement;"\"Data Source=CHAPLIN,4275;Initial Catalog=DealerManagement;Provider=SQLOLEDB.1;Integrated Security=SSPI;Application Name=SSIS-UpdateDMSFromSAM-{FD86455C-480D-4317-B0C2-2BB9A97E747F}DealerManagement;\"" /CONNECTION SAM;"\"Data Source=CHAPLIN,4275;Initial Catalog=SAM;Provider=SQLOLEDB.1;Integrated Security=SSPI;Application Name=SSIS-UpdateDMSFromSAM-{26AB8915-D12C-4AB3-B135-31065FF454AA}SAM;\"" /CONNECTION SLX;"\"Data Source=SQL3;Initial Catalog=saleslogix;Provider=SQLOLEDB.1;Integrated Security=SSPI;Application Name=SSIS-UpdateDMSFromSAM-{9947D217-BE96-4ACB-9F78-F8E07A957518}SLX;\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'RUN Schedule - UpdateDMSFromSAM', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150617, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=231500, 
		@schedule_uid=N'5fbc01b6-cbac-44a3-9955-c6c3e672aa6c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SAMMapback]    Script Date: 11/30/2020 5:04:28 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:28 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SAMMapback', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute the SAM Mapback SSIS package.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SAM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXECUTE SSIS PACKAGE]    Script Date: 11/30/2020 5:04:28 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXECUTE SSIS PACKAGE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"D:\SSIS backages\SSIS\Mapback_2020.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name=N'sa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SAM Mapback Run Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150529, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'7a8894f9-3333-4b8c-964d-058696e31c82'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SAM Mapback Run Schedule - Ad Hoc', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180919, 
		@active_end_date=99991231, 
		@active_start_time=190000, 
		@active_end_time=235959, 
		@schedule_uid=N'0726c850-5fb1-4985-b446-ac2d7c775807'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS Monthly Attrition Data Load]    Script Date: 11/30/2020 5:04:28 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:28 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS Monthly Attrition Data Load', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=1, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:28 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''ODSPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Attrition Data Load Run/ReRum]    Script Date: 11/30/2020 5:04:28 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Attrition Data Load Run/ReRum', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC SAM.[RPT].[Cp_SSRS_SAM_AttritionTrendingValidation_MonthlyLoad]', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monthly Once', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170501, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'05d02041-e700-42ee-9aa4-98af3ba721c5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS_Pop_JurisdictionandMailout]    Script Date: 11/30/2020 5:04:29 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 5:04:29 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SSRSData' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SSRSData'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS_Pop_JurisdictionandMailout', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'populates tables 
--Use this string on STARSKY
DTexec /FILE "D:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Binn\dtexec.exe" /DTS "\MSDB\ssrs_Pop_tblSSRSjurisdiction" /SERVER SRVODS03 /MAXCONCURRENT " -1 " /CHECKPOINTING OFF  /REPORTING V

--Use this string on HUTCH
--DTexec /FILE "D:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\dtexec.exe" /DTS "\MSDB\ssrs_Pop_tblSSRSjurisdiction" /SERVER SRVODS03 /MAXCONCURRENT " -1 " /CHECKPOINTING OFF  /REPORTING V

--Use this string on', 
		@category_name=N'SSRSData', 
		@owner_login_name=N'PMS\SVC_SQL2K8_Prod', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run ssis ssrs_Pop_tblSSRSjurisdiction]    Script Date: 11/30/2020 5:04:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run ssis ssrs_Pop_tblSSRSjurisdiction', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'T:\Batch\exec_ssrs_Pop_tblSSRSjurisdiction.bat', 
		@output_file_name=N'X:\JobLogs\ssrs_Pop_tblSSRSjurisdiction.txt', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run ssis ssrs_Pop_tblOpenCloseMailoutReports]    Script Date: 11/30/2020 5:04:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run ssis ssrs_Pop_tblOpenCloseMailoutReports', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'T:\Batch\exec_ssrs_Pop_tblOpenCloseMailoutReports.bat', 
		@output_file_name=N'X:\JobLogs\ssrs_Pop_tblOpenCloseMailoutReports.txt', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily at 4:15pm', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100119, 
		@active_end_date=99991231, 
		@active_start_time=161500, 
		@active_end_time=235959, 
		@schedule_uid=N'fa99960e-ef6f-4783-8455-5e97c3c56366'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Task #999 (Mon to Bus) mi_masdb]    Script Date: 11/30/2020 5:04:30 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS_BUS]    Script Date: 11/30/2020 5:04:30 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS_BUS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS_BUS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Task #999 (Mon to Bus) mi_masdb', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Mon to Bus Transactions mi_masdb:  This job should only be enabled to run on ONE server in the replication loop.  In general we run this job on the ''Batch Processing Server''.', 
		@category_name=N'MAS_BUS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not The Quit Reporting Success)]    Script Date: 11/30/2020 5:04:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not The Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Task #999]    Script Date: 11/30/2020 5:04:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #999', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec ap_start_task 999', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Regular', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20060420, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd2e7a259-f315-4c4d-8efc-e7ff73654b04'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Update LTE Info]    Script Date: 11/30/2020 5:04:31 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:31 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update LTE Info', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update site note and customer satisfaction for LTE update required', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 5:04:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check If AG Primary (If Not Then Quit Reporting Success)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update LTE Info]    Script Date: 11/30/2020 5:04:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update LTE Info', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_ap_update_lte_site_info', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Regular', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20191104, 
		@active_end_date=99991231, 
		@active_start_time=91500, 
		@active_end_time=235959, 
		@schedule_uid=N'7c7e200a-a23a-460b-8d54-f6d826d04912'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Update Pardot Email Treatment Group table]    Script Date: 11/30/2020 5:04:32 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 11/30/2020 5:04:32 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update Pardot Email Treatment Group table', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update Pardot email treatment group table based on what emails were sent - CLM Champion of Retention. Plust adding Brinkshome notification sweeping all archive tables.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'reporter', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [First Step - CLM treatment group]    Script Date: 11/30/2020 5:04:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'First Step - CLM treatment group', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC mi_datamart.cx.sp_UpdatePardotEmailTreatMentGroup_CLM_ChampionOfRetention', 
		@database_name=N'mi_datamart', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Second Step - Brinkshome Notification]    Script Date: 11/30/2020 5:04:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Second Step - Brinkshome Notification', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC mi_datamart.[cx].[sp_CampaignNoActionNotification_INSERT]
', 
		@database_name=N'mi_datamart', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200220, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'02734675-fc5f-4592-beb8-ded0099e9fff'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [UpdateGreenSkyJobs]    Script Date: 11/30/2020 5:04:33 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 5:04:33 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'UpdateGreenSkyJobs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update GreenSky jobs to billable or create error action', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update GreenSky jobs]    Script Date: 11/30/2020 5:04:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update GreenSky jobs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_cp_Job_Management_Update_Greensky_Jobs @change_user = 997', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'GreenSky Update', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190327, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'fc0d0064-3bcd-423b-a0d7-67d2c0cbc4a0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

