USE [msdb]
GO

/****** Object:  Job [Admin-SyncCustomMASUsersWithMASDB]    Script Date: 11/30/2020 4:56:43 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS_Admin]    Script Date: 11/30/2020 4:56:43 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS_Admin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS_Admin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Admin-SyncCustomMASUsersWithMASDB', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'adds users into mi_custom mas_user role if they are in mi_masdb mas_user role', 
		@category_name=N'MAS_Admin', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:43 PM ******/
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
/****** Object:  Step [cp_admin_sync_mas_dbusers]    Script Date: 11/30/2020 4:56:43 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'cp_admin_sync_mas_dbusers', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_custom.dbo.cp_admin_sync_mas_dbusers', 
		@database_name=N'mi_custom', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\Admin-SyncCustomMASUsersWithMASDB.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100127, 
		@active_end_date=99991231, 
		@active_start_time=12500, 
		@active_end_time=235959, 
		@schedule_uid=N'd542aa8a-2371-4f39-9d8b-a39b8f3a68f4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Alarm Dispatch Notify]    Script Date: 11/30/2020 4:56:43 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Processing]    Script Date: 11/30/2020 4:56:44 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Processing' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Processing'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Alarm Dispatch Notify', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This process will identify agencies that require written notification be mailed to customers in their jurisdiction when a dispatch is made to that agency.  The new procedure will create a new ALMNFY action that will add those customers to the action letter generation file for fulfillment.  The procedure will run daily and will only pick up dispatches for the previous 24 hours.', 
		@category_name=N'Processing', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:44 PM ******/
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
/****** Object:  Step [mi_ap_alarm_notifications]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_ap_alarm_notifications', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_masdb.dbo.mi_ap_alarm_notifications
', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST01\JOBLOG\mi_ap_alarm_notifications.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'11pm', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100809, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, 
		@schedule_uid=N'9469e38f-b5f7-480b-b5b8-8bf15ffa9718'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [AlwaysOn_Latency_Data_Collection]    Script Date: 11/30/2020 4:56:44 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:44 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AlwaysOn_Latency_Data_Collection', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'PMS\brundmi', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect AG Information]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect AG Information', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' USE tempdb
                  IF OBJECT_ID(''AGInfo'') IS NOT NULL
                      BEGIN
                        DROP TABLE AGInfo
                   END 
                  IF OBJECT_ID(''LatencyCollectionStatus'') IS NOT NULL
                      BEGIN
                        DROP TABLE LatencyCollectionStatus
                      END
                   CREATE TABLE LatencyCollectionStatus(
                        [collection_status] [NVARCHAR](60)  NULL,
                        [start_timestamp] [DATETIMEOFFSET] NULL,
                        [startutc_timestamp] [DATETIMEOFFSET] NULL
                    )
                  INSERT INTO LatencyCollectionStatus(collection_status, start_timestamp, startutc_timestamp) values (''Started'', GETDATE(), GETUTCDATE())
                  SELECT
                  AGC.name as agname
                  , RCS.replica_server_name as replica_name
                  , ARS.role_desc as agrole
                  INTO AGInfo
                  FROM
                      sys.availability_groups_cluster AS AGC
                      INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
                      ON
                      RCS.group_id = AGC.group_id
                      INNER JOIN sys.dm_hadr_availability_replica_states AS ARS
                      ON
                      ARS.replica_id = RCS.replica_id
                      where AGC.name =  N''MASPROD''', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create XE Session]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create XE Session', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (select * from sys.server_event_sessions 
                WHERE name = N''AlwaysOn_Data_Movement_Tracing'')
                    BEGIN
                    DROP EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER 
                    END
                CREATE EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER ADD EVENT sqlserver.hadr_apply_log_block, 
ADD EVENT sqlserver.hadr_capture_log_block, 
ADD EVENT sqlserver.hadr_database_flow_control_action, 
ADD EVENT sqlserver.hadr_db_commit_mgr_harden, 
ADD EVENT sqlserver.hadr_log_block_send_complete, 
ADD EVENT sqlserver.hadr_send_harden_lsn_message, 
ADD EVENT sqlserver.hadr_transport_flow_control_action, 
ADD EVENT sqlserver.log_flush_complete, 
ADD EVENT sqlserver.log_flush_start, 
ADD EVENT sqlserver.recovery_unit_harden_log_timestamps, 
ADD EVENT sqlserver.log_block_pushed_to_logpool, 
ADD EVENT sqlserver.hadr_transport_receive_log_block_message, 
ADD EVENT sqlserver.hadr_receive_harden_lsn_message, 
ADD EVENT sqlserver.hadr_log_block_group_commit, 
ADD EVENT sqlserver.hadr_log_block_compression, 
ADD EVENT sqlserver.hadr_log_block_decompression, 
ADD EVENT sqlserver.hadr_lsn_send_complete, 
ADD EVENT sqlserver.hadr_capture_filestream_wait, 
ADD EVENT sqlserver.hadr_capture_vlfheader ADD TARGET package0.event_file(SET filename=N''AlwaysOn_Data_Movement_Tracing.xel'',max_file_size=(25),max_rollover_files=(4))
                WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
                
                ALTER EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER STATE = START', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait For Collection]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait For Collection', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:2:00'' 
                                                       GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [End XE Session]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'End XE Session', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER STATE = STOP', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Extract XE Data]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Extract XE Data', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
                    BEGIN TRANSACTION
                    USE tempdb
                    IF OBJECT_ID(''#EventXml'') IS NOT NULL
                    BEGIN
                        DROP TABLE #EventXml
                    END 

                    SELECT 
                        xe.event_name, 
                        CAST(xe.event_data AS XML) AS event_data
                    INTO #EventXml
                    FROM
                    (
                    SELECT
                            object_name AS event_name,
                            CAST(event_data AS XML) AS event_data
                        FROM sys.fn_xe_file_target_read_file(
                                    ''AlwaysOn_Data_Movement_Tracing*.xel'', 
                                    NULL, NULL, NULL)
                        WHERE object_name IN (''hadr_log_block_group_commit'',
                                    ''log_block_pushed_to_logpool'',
                                    ''log_flush_start'',
                                    ''log_flush_complete'',
                                    ''hadr_log_block_compression'',
                                    ''hadr_capture_log_block'',
                                    ''hadr_capture_filestream_wait'',
                                    ''hadr_log_block_send_complete'',
                                    ''hadr_receive_harden_lsn_message'',
                                    ''hadr_db_commit_mgr_harden'',
                                    ''recovery_unit_harden_log_timestamps'',
                                    ''hadr_capture_vlfheader'',
                                    ''hadr_log_block_decompression'',
                                    ''hadr_apply_log_block'',
                                    ''hadr_send_harden_lsn_message'',
                                    ''hadr_log_block_decompression'',
                                    ''hadr_lsn_send_complete'',
                                    ''hadr_transport_receive_log_block_message'')
    
                    ) xe

                    IF OBJECT_ID(''DMReplicaEvents'') IS NOT NULL
                    BEGIN
                        DROP TABLE DMReplicaEvents
                    END 

                    SET ANSI_NULLS ON

                    SET QUOTED_IDENTIFIER ON

                    CREATE TABLE DMReplicaEvents(
                        [server_name] [NVARCHAR](128) NULL,
                        [event_name] [NVARCHAR](60) NOT NULL,
                        [log_block_id] [BIGINT] NULL,
                        [database_id] [INT] NULL,
                        [processing_time] [BIGINT] NULL,
                        [start_timestamp] [BIGINT] NULL,
                        [publish_timestamp] [DATETIMEOFFSET] NULL,
                        [log_block_size] [BIGINT] NULL,
                        [target_availability_replica_id] [UNIQUEIDENTIFIER] NULL,
                        [local_availability_replica_id] [UNIQUEIDENTIFIER] NULL,
                        [database_replica_id] [UNIQUEIDENTIFIER] NULL,
                        [mode] [BIGINT] NULL,
                        [availability_group_id] [UNIQUEIDENTIFIER] NULL,
                        [pending_writes]  [BIGINT] NULL
                    )

                    IF OBJECT_ID(''LatencyResults'') IS NOT NULL
                    BEGIN
                        DROP TABLE LatencyResults
                    END 
                    CREATE TABLE LatencyResults(
                       [event_name] [NVARCHAR](60) NOT NULL,
                       [processing_time] [BIGINT] NULL,
                       [publish_timestamp] [DATETIMEOFFSET] NULL,
                       [server_commit_mode] [NVARCHAR](60) NULL
                    )


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        NULL AS database_id,
                        AoData.value(''(data[@name="total_processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 75, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        AoData.value(''(data[@name="log_block_size"]/value)[1]'', ''BIGINT'') AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_log_block_send_complete''

                    GO


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''INT'') AS database_id,
                        AoData.value(''(data[@name="duration"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 65, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        AoData.value(''(data[@name="pending_writes"]/value)[1]'',''BIGINT'') AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''log_flush_complete''

                    GO

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        NULL AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="time_to_commit"]/value)[1]'', ''BIGINT'') AS processing_time,
                        NULL AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 72, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        AoData.value(''(data[@name="replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        AoData.value(''(data[@name="ag_database_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS database_replica_id,
                        NULL AS mode,
                        AoData.value(''(data[@name="group_id"]/value)[1]'',''UNIQUEIDENTIFIER'') AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_db_commit_mgr_harden''

                    GO


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 82, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''recovery_unit_harden_log_timestamps''

                    GO

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 73, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        AoData.value(''(data[@name="uncompressed_size"]/value)[1]'', ''INT'') AS log_block_size,
                        AoData.value(''(data[@name="availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_log_block_compression''

                    GO


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 75, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        AoData.value(''(data[@name="uncompressed_size"]/value)[1]'', ''BIGINT'') AS log_block_size,
                        AoData.value(''(data[@name="availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_log_block_decompression''

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        NULL AS database_id,
                        AoData.value(''(data[@name="total_sending_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 69, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_lsn_send_complete''

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        NULL AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 87, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        AoData.value(''(data[@name="target_availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        AoData.value(''(data[@name="local_availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS local_availability_replica_id,
                        AoData.value(''(data[@name="target_availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS database_replica_id,
                        AoData.value(''(data[@name="mode"]/value)[1]'', ''BIGINT'') AS mode,
                        AoData.value(''(data[@name="availability_group_id"]/value)[1]'',''UNIQUEIDENTIFIER'') AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_transport_receive_log_block_message''


                    DELETE
                    FROM DMReplicaEvents
                    WHERE CAST(publish_timestamp AS DATETIME) < DATEADD(minute, -2, CAST((SELECT MAX(publish_timestamp) from DMReplicaEvents) as DATETIME))
                    COMMIT
                    GO', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create Result Set]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Result Set', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
                    BEGIN TRANSACTION
                    USE tempdb
                    declare @ag_id as nvarchar(60) 
                    declare @event as nvarchar(60) 
                    set @ag_id = (select group_id from  sys.availability_groups_cluster where name = N''MASPROD'')
                    IF OBJECT_ID(''DbIdTable'') IS NOT NULL
                    BEGIN
                        DROP TABLE DbIdTable
                    END 
                    CREATE TABLE DbIdTable(
                        [database_id] [INT] NULL
                    )

                    INSERT INTO DbIdTable
                    select distinct database_id  from sys.dm_hadr_database_replica_states where group_id=@ag_id 

                    delete from tempdb.dbo.DMReplicaEvents where not (availability_group_id = @ag_id or availability_group_id is NULL) 

                    delete from tempdb.dbo.DMReplicaEvents where not (database_id in (select database_id from DbIdTable) or database_id is NULL)

                    set @event = ''availability_mode_desc''
                    INSERT INTO LatencyResults
                    select @event, NULL as processing_time, NULL as publish_timestamp, availability_mode_desc as server_commit_mode from sys.availability_replicas  A
                    inner join 
                    (select * from sys.dm_hadr_availability_replica_states) B
                    on A.replica_id = B.replica_id and A.group_id = @ag_id and A.replica_server_name = @@SERVERNAME

                    set @event = ''start_time''
                    INSERT INTO LatencyResults
                    select @event as event_name, NULL as processing_time, min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents

                    set @event = ''recovery_unit_harden_log_timestamps''
                    INSERT INTO LatencyResults
                    select @event, avg(processing_time), min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from DMReplicaEvents where event_name=''recovery_unit_harden_log_timestamps'' GROUP BY DATEPART(YEAR, publish_timestamp), DATEPART(MONTH, publish_timestamp), DATEPART(DAY, publish_timestamp), DATEPART(HOUR, publish_timestamp), DATEPART(MINUTE, publish_timestamp), DATEPART(SECOND, publish_timestamp) 

                    set @event = ''avg_recovery_unit_harden_log_timestamps''
                    INSERT INTO LatencyResults
                    select @event as event_name,AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''recovery_unit_harden_log_timestamps'' 

                    set @event = ''hadr_db_commit_mgr_harden''
                    INSERT INTO LatencyResults
                    select @event, avg(processing_time), min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from DMReplicaEvents where event_name=''hadr_db_commit_mgr_harden'' GROUP BY DATEPART(YEAR, publish_timestamp), DATEPART(MONTH, publish_timestamp), DATEPART(DAY, publish_timestamp), DATEPART(HOUR, publish_timestamp), DATEPART(MINUTE, publish_timestamp), DATEPART(SECOND, publish_timestamp)

                    set @event = ''avg_hadr_db_commit_mgr_harden''
                    INSERT INTO LatencyResults
                    SELECT @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_db_commit_mgr_harden''

                    set @event = ''avg_hadr_log_block_send_complete''
                    INSERT INTO LatencyResults
                    SELECT @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode FROM tempdb.dbo.DMReplicaEvents WHERE event_name = ''hadr_log_block_send_complete''

                    set @event = ''avg_hadr_log_block_compression''
                    INSERT INTO LatencyResults
                    SELECT @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_log_block_compression''

                    set @event = ''avg_hadr_log_block_decompression''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_log_block_decompression''

                    set @event = ''hadr_lsn_send_complete''
                    INSERT INTO LatencyResults
                    select @event, avg(processing_time), min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from DMReplicaEvents where event_name=''hadr_lsn_send_complete'' GROUP BY DATEPART(YEAR, publish_timestamp), DATEPART(MONTH, publish_timestamp), DATEPART(DAY, publish_timestamp), DATEPART(HOUR, publish_timestamp), DATEPART(MINUTE, publish_timestamp), DATEPART(SECOND, publish_timestamp) 

                    set @event = ''avg_hadr_lsn_send_complete''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_lsn_send_complete''

                    set @event = ''avg_hadr_transport_receive_log_block_message''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_transport_receive_log_block_message''


                    set @event = ''avg_log_flush_complete''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time*1000) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''log_flush_complete''
                    COMMIT

            ', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop XE Session]    Script Date: 11/30/2020 4:56:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop XE Session', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DROP EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER
                                                            UPDATE tempdb.dbo.LatencyCollectionStatus set collection_status =''Completed''', 
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

/****** Object:  Job [ASAPer - Truncate Table mi_asaper_alarm]    Script Date: 11/30/2020 4:56:44 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS_BUS]    Script Date: 11/30/2020 4:56:44 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS_BUS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS_BUS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ASAPer - Truncate Table mi_asaper_alarm', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job will truncate the mi_custom.dbo.mi_asaper_alarm table  ONLY on the MMM failover TARGET server PRIOR TO A FAILOVER.  The job will exist on each MtM production server as an enabled job with no schedule but is run MANUALLY only prior to a failover.  Prior to the truncate, the latest 100 rows of mi_asaper_alarm will be saved to tempdb.', 
		@category_name=N'MAS_BUS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check if AG Primary (If NOT then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check if AG Primary (If NOT then Quit Reporting Success)', 
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
/****** Object:  Step [Save the most recent 100 rows of mi_asaper_alarm table in tempdb]    Script Date: 11/30/2020 4:56:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Save the most recent 100 rows of mi_asaper_alarm table in tempdb', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'if object_id(''tempdb.dbo.mi_asaper_alarm'') > 0
	drop table tempdb.dbo.mi_asaper_alarm

select top 100 * into tempdb.dbo.mi_asaper_alarm from mi_custom.dbo.mi_asaper_alarm order by change_date desc

', 
		@database_name=N'mi_custom', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Truncate Table mi_custom.dbo.mi_asaper_alarm]    Script Date: 11/30/2020 4:56:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Truncate Table mi_custom.dbo.mi_asaper_alarm', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'truncate table mi_asaper_alarm
go', 
		@database_name=N'mi_custom', 
		@flags=4
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

/****** Object:  Job [Availability Group Post Failover Tasks]    Script Date: 11/30/2020 4:56:45 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:45 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Availability Group Post Failover Tasks', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Availability Group Role]    Script Date: 11/30/2020 4:56:45 PM ******/
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

SET @AgName = ''MAS''
SET @AgRole = ''PRIMARY''

SET @DatabasesAvailable = 0

	SELECT @DatabaseCount = COUNT(*)/2 FROM sys.dm_hadr_database_replica_states AS drs
	  LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
      LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
    WHERE ag.name = @AgName

-- Get the number of databases in the availabity group
WHILE @DatabasesAvailable != @DatabaseCount
  BEGIN
	SELECT @DatabaseCount = COUNT(*)/2 FROM sys.dm_hadr_database_replica_states AS drs
	  LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
      LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
    WHERE ag.name = @AgName

--  SET @DatabaseCount = 4

	SELECT @DatabasesAvailable = COUNT(*) FROM sys.dm_hadr_database_replica_states AS drs
      LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
      LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
    WHERE ag.name = @AgName
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

/*
DECLARE @AgName VARCHAR(64),
        @AgRole VARCHAR(64),
		@PrintMessage VARCHAR(128),
		@DatabaseCount INT,
	    @DatabasesAvailable INT

SET @AgName = ''MAS''
SET @AgRole = ''PRIMARY''
-- Get the number of databases in the availabity group
SELECT @DatabaseCount = COUNT(*)/2 FROM sys.dm_hadr_database_replica_states AS drs
  LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
  LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
  WHERE ag.name = @AgName

--  SET @DatabaseCount = 4

SELECT @DatabasesAvailable = COUNT(*) FROM sys.dm_hadr_database_replica_states AS drs
  LEFT JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
  LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON drs.replica_id = ars.replica_id AND drs.group_id = ars.group_id
  WHERE ag.name = @AgName
    AND ars.role_desc =  @AgRole
	AND ars.recovery_health_desc = ''ONLINE''
    AND ars. synchronization_health_desc = ''HEALTHY''
    AND ars.operational_state_desc = ''ONLINE''
IF @DatabasesAvailable = @DatabaseCount
	BEGIN
	  RAISERROR(''Server %s availability group %s Status: [%s] %d out of %d databases are available.'', 10, 1, @@SERVERNAME, @AgName, @AgRole, @DatabasesAvailable, @DatabaseCount)
	END
ELSE
    BEGIN
	  RAISERROR(''Server %s availability group %s Status: [%s] only %d out of %d databases are available.'', 16, 1, @@SERVERNAME, @AgName, @AgRole, @DatabasesAvailable, @DatabaseCount)
	END
*/', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Monitor Server Table]    Script Date: 11/30/2020 4:56:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Monitor Server Table', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [mi_mondb];
GO
UPDATE mi_mondb.dbo.monitor_server
SET servername = @@SERVERNAME,
    active_date = GETDATE();
GO', 
		@database_name=N'mi_mondb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Vertex Server Task Table]    Script Date: 11/30/2020 4:56:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Vertex Server Task Table', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [mi_masdb];
GO

UPDATE mi_masdb.dbo.vertex_server_task
SET vertex_server_name = @@SERVERNAME;
GO', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Business Server Table]    Script Date: 11/30/2020 4:56:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Business Server Table', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE mi_custom.dbo.business_server
SET servername = @@SERVERNAME', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Report Post Failover Tasks Complete]    Script Date: 11/30/2020 4:56:45 PM ******/
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

/****** Object:  Job [Check_Stop_Bill_Actions]    Script Date: 11/30/2020 4:56:45 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:56:45 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Check_Stop_Bill_Actions', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'MI procedure to review STPBIL actions and create CNREQ or REIBIL actions if necessary.', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:45 PM ******/
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
/****** Object:  Step [Check_StopBills]    Script Date: 11/30/2020 4:56:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check_StopBills', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_masdb.dbo.mi_ap_check_stopbills', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST01\BackupWP1MASINST01\JobLog\Check_Stop_Bill_Actions.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Stopbill_Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20081030, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'21788836-7da1-40e2-8576-e4bb0b1f770b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [ContractRenewal]    Script Date: 11/30/2020 4:56:46 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:56:46 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ContractRenewal', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'EXEC mi_ap_renew_contract:  contact Victor Barraza (RFC 715) MI procedure to renew contracts (unlike GE proc, this does not affect recurring lines)', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:46 PM ******/
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
/****** Object:  Step [mi_ap_renew_contract]    Script Date: 11/30/2020 4:56:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_ap_renew_contract', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC mi_ap_renew_contract', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\proc_BackupLocalDatabaseLogs.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily @ 5am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20091029, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'589755f3-2faa-4986-a93b-9bfa467e54b8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Copy m_account_replacement]    Script Date: 11/30/2020 4:56:46 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:56:46 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Copy m_account_replacement', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will copy any new conditional replacements from task # 5 to the following tasks: 6,7,8,9,10,11,15,16,17,18,19,20,21,23,24,25,26,27,28,30,31,32,34,35,36,37,38', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 1 - Copy conditional replacements]    Script Date: 11/30/2020 4:56:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1 - Copy conditional replacements', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*  Copy m_account_replacement data LOOP version for  SURM receivers only
Updated 8/22/2016 reflecting VV and Wittington Place SURM receivers
 Do NOT add tasks 43,44 (S3 IP receivers) as signals come complete from Connect24; NO replacements.

 This is known to DBA''s as "Copy m_account_replacement"   
 ''select conditional from m_account_replacement where task_no = 5'' reveals 2906 replacements 08/2016 !!
 All active SG receivers matched on 8/23/2016 except tasks 21,24. They had an extra DNIS replacement -75849- removed.
 Task 24,25,26 need this push (& cleanup first) before being defined active since they have extra replacement records.
 Task 57,61 (ADC 2W) have 477 less records than the actual signal-receiving receivers-might as well update them, although not used. 
 */


SET nocount ON
GO

/*  SURM tasks = 5(The SOURCE receiver),6,7,8,9,10,11,13,15,16,17,18,19,20,21,23,24,25,26,27,28,
30,31,32,34,35,36,37,38,39,40,41,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,61,62,63 */

CREATE TABLE RXList (RXID int NOT NULL, Name nvarchar(15));
INSERT INTO RxList (RXID, Name) VALUES (6,''A-SYS3_2A(p20)'')
INSERT INTO RxList (RXID, Name) VALUES (7,''A-SYS3_3A(p21)'')
INSERT INTO RxList (RXID, Name) VALUES (8,''A-SYS3_4A(p22)'')
INSERT INTO RxList (RXID, Name) VALUES (9,''A-SYS3_5A(p23)'')
INSERT INTO RxList (RXID, Name) VALUES (10,''A-SYS3_6A(p24)'')
INSERT INTO RxList (RXID, Name) VALUES (11,''B-SYS3_3B(p37)'')
INSERT INTO RxList (RXID, Name) VALUES (13,''WP-SYS3_1A'')
INSERT INTO RxList (RXID, Name) VALUES (15,''B-SYS3_4B(p38)'')
INSERT INTO RxList (RXID, Name) VALUES (16,''B-SYS3_6B(p40)'')
INSERT INTO RxList (RXID, Name) VALUES (17,''B-SYS3_1B(p35)'')
INSERT INTO RxList (RXID, Name) VALUES (18,''B-SYS3_2B(p36)'')
INSERT INTO RxList (RXID, Name) VALUES (19,''B-SYS3_5B(p39)'')
INSERT INTO RxList (RXID, Name) VALUES (20,''WP-SYS4_1A'')
INSERT INTO RxList (RXID, Name) VALUES (21,''SG-n/u'')
INSERT INTO RxList (RXID, Name) VALUES (23,''B-SYS3_9B(p33)'')
INSERT INTO RxList (RXID, Name) VALUES (24,''SG-n/u'')
INSERT INTO RxList (RXID, Name) VALUES (25,''SG-n/u'')
INSERT INTO RxList (RXID, Name) VALUES (26,''SG-n/u'')
INSERT INTO RxList (RXID, Name) VALUES (27,''A-SYS3_7A(p25)'')
INSERT INTO RxList (RXID, Name) VALUES (28,''B-SYS3_7B(p41)'')
INSERT INTO RxList (RXID, Name) VALUES (30,''B-SYS3_11B(p49)'')
INSERT INTO RxList (RXID, Name) VALUES (31,''A-SYS3_9A(p32)'')
INSERT INTO RxList (RXID, Name) VALUES (32,''A-SYS3_10A(p34)'')
INSERT INTO RxList (RXID, Name) VALUES (34,''WP-SYS4_1B'')
INSERT INTO RxList (RXID, Name) VALUES (35,''B-SYS3_10B(p45)'')
INSERT INTO RxList (RXID, Name) VALUES (36,''A-SYS3_8A(p26)'')
INSERT INTO RxList (RXID, Name) VALUES (37,''B-SYS3_8B(p42'')
INSERT INTO RxList (RXID, Name) VALUES (38,''B-SYS3_11A(p48)'')
INSERT INTO RxList (RXID, Name) VALUES (39,''WP-SYS3_1B'')
INSERT INTO RxList (RXID, Name) VALUES (40,''WP-SYS3_2A'')
INSERT INTO RxList (RXID, Name) VALUES (41,''WP-SYS3_2B'')
INSERT INTO RxList (RXID, Name) VALUES (45,''SYS3_12A(p51)'')
INSERT INTO RxList (RXID, Name) VALUES (46,''SYS3_12B(p52)'')
INSERT INTO RxList (RXID, Name) VALUES (47,''SYS3_13A(p53)'')
INSERT INTO RxList (RXID, Name) VALUES (48,''SYS3_13B(p54)'')
INSERT INTO RxList (RXID, Name) VALUES (49,''WP-SYS3_3A'')
INSERT INTO RxList (RXID, Name) VALUES (50,''WP-SYS3_3B'')
INSERT INTO RxList (RXID, Name) VALUES (51,''WP-SYS3_4A'')
INSERT INTO RxList (RXID, Name) VALUES (52,''WP-SYS3_4B'')
INSERT INTO RxList (RXID, Name) VALUES (53,''WP-SYS4_2A'')
INSERT INTO RxList (RXID, Name) VALUES (54,''WP-SYS4_2B'')
INSERT INTO RxList (RXID, Name) VALUES (55,''WP-SYS4_3A'')
INSERT INTO RxList (RXID, Name) VALUES (56,''WP-SYS4_3B'')
INSERT INTO RxList (RXID, Name) VALUES (57,''ADC SYS3_2W 1A'')
INSERT INTO RxList (RXID, Name) VALUES (58,''WP-SYS4_4A'')
INSERT INTO RxList (RXID, Name) VALUES (59,''WP-SYS4_4B'')
INSERT INTO RxList (RXID, Name) VALUES (61,''ADC SYS3_2W 1B'')
INSERT INTO RxList (RXID, Name) VALUES (62,''WP-SYS4_5A'')
INSERT INTO RxList (RXID, Name) VALUES (63,''WP-SYS4_5B'')

SET nocount OFF
GO

/* Set variables */
declare @TaskNO smallint,
        @NTaskNO smallint,
        @MyName nvarchar(15)
declare update_task CURSOR FOR
--This is the LIST of tasks you are copying TO
SELECT RXID, Name
	FROM RxList
OPEN update_task
select @TaskNO = ''5'' --The SOURCE task
 FETCH NEXT FROM update_task INTO @NTaskNO, @MyName
  WHILE (@@fetch_status = 0)
   BEGIN

     print ''Copying '' + @MyName + CHAR(13) + CHAR(10)


insert m_account_replacement (task_no, conditional, replacement, acct1, pos1, acct2, 
pos2, acct3, pos3, acct4, pos4, acct5, pos5, acct6, 
pos6, acct7, pos7, acct8, pos8, acct9, pos9, acct10, 
pos10, acct11, pos11, acct12, pos12, acct13, pos13, 
acct14, pos14, acct15, pos15, acct16, pos16, acct17, 
pos17, acct18, pos18, acct19, pos19, acct20, pos20)

select @NTaskNO, conditional, replacement, acct1, pos1, acct2, 
pos2, acct3, pos3, acct4, pos4, acct5, pos5, acct6, 
pos6, acct7, pos7, acct8, pos8, acct9, pos9, acct10, 
pos10, acct11, pos11, acct12, pos12, acct13, pos13, 
acct14, pos14, acct15, pos15, acct16, pos16, acct17, 
pos17, acct18, pos18, acct19, pos19, acct20, pos20
from m_account_replacement
where task_no = @TaskNO and conditional <> ''1001'' 
and conditional not in (select conditional from m_account_replacement where task_no = @NTaskNO)

  FETCH NEXT FROM update_task INTO @NTaskNO, @MyName  -- next loop
   END  -- then exit
    CLOSE update_task
     DEALLOCATE update_task
      DROP table RxList
GO

Print ''Copy Complete''', 
		@database_name=N'mi_mondb', 
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

/****** Object:  Job [Correct Customer Branch]    Script Date: 11/30/2020 4:56:46 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS_BUS]    Script Date: 11/30/2020 4:56:46 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS_BUS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS_BUS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Correct Customer Branch', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Nightly processes to correct customer branch - RFC # 1634', 
		@category_name=N'MAS_BUS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary]    Script Date: 11/30/2020 4:56:46 PM ******/
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
/****** Object:  Step [Step 2]    Script Date: 11/30/2020 4:56:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_ap_update_cust_branch', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\mi_ap_update_cust_branch.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule 1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111025, 
		@active_end_date=99991231, 
		@active_start_time=233000, 
		@active_end_time=235959, 
		@schedule_uid=N'665a6d56-4f82-4190-afe9-1a6518798d71'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [CreateOutOfServiceLetterAction]    Script Date: 11/30/2020 4:56:47 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:56:47 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CreateOutOfServiceLetterAction', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'MI procedure to automatically open Out of Service letter actions for OOS actions due >= 10 days from the create date of the action', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:47 PM ******/
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
/****** Object:  Step [Execute mi_ap_moves_oosltr]    Script Date: 11/30/2020 4:56:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute mi_ap_moves_oosltr', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_masdb.dbo.mi_ap_moves_oosltr', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\CreateOutOfServiceLetterAction.txt', 
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
		@active_start_date=20080620, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'5efd4479-49f7-4c9a-935a-123abb782074'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [CreateResurveyActionsOnWelcomeCallJobs]    Script Date: 11/30/2020 4:56:47 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:56:47 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CreateResurveyActionsOnWelcomeCallJobs', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'automatically open Resurvey actions on for completed Welcome Call jobs', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:47 PM ******/
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
/****** Object:  Step [sp_execute_mi_ap_welcome_resrvy]    Script Date: 11/30/2020 4:56:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_execute_mi_ap_welcome_resrvy', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_masdb.dbo.mi_ap_welcome_resrvy', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\CreateResurveyActionsOnWelcomeCallJobs.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekday_run', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20080718, 
		@active_end_date=99991231, 
		@active_start_time=44500, 
		@active_end_time=235959, 
		@schedule_uid=N'2c8b83b8-d853-4f38-8c38-8b620d6a57ea'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_CycleSQLErrorLog]    Script Date: 11/30/2020 4:56:47 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA]    Script Date: 11/30/2020 4:56:47 PM ******/
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
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [cycle error log]    Script Date: 11/30/2020 4:56:48 PM ******/
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
/****** Object:  Step [cycle agent error log]    Script Date: 11/30/2020 4:56:48 PM ******/
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
		@schedule_uid=N'5f9d8543-d359-46d1-b172-9a034f9638be'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Analyze_Objects_Hist]    Script Date: 11/30/2020 4:56:48 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:48 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Analyze_Objects_Hist', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:48 PM ******/
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
/****** Object:  Step [Analyze Objects Hist]    Script Date: 11/30/2020 4:56:48 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Analyze Objects Hist', 
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
declare @start_date datetime
declare @end_date datetime

select @end_date = getdate()
select @start_date = dateadd(day, -7, getdate())

exec SSISDB.dbo.analyze_objects_hist_auto @start_date, @end_date

', 
		@database_name=N'SSISDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=5, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190403, 
		@active_end_date=99991231, 
		@active_start_time=211500, 
		@active_end_time=235959, 
		@schedule_uid=N'c5d8f4e2-a4fd-47ba-9d78-0a0341e68dfc'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_AGDatabases (Primary Replica)]    Script Date: 11/30/2020 4:56:48 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:48 PM ******/
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
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:48 PM ******/
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
/****** Object:  Step [Remove Older Backups]    Script Date: 11/30/2020 4:56:48 PM ******/
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
$root = $root.replace($env:COMPUTERNAME, "MASPROD")
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
		@output_file_name=N'\\wp1sqlbk04\d$\MASPROD\Backup\JobLog\proc_BackupPrimaryDatabasesEncrypted.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Databases in an Availability Group from a primary replica. (ENCRYPTED)]    Script Date: 11/30/2020 4:56:48 PM ******/
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
		@command=N'EXEC proc_BackupPrimaryDatabasesEncrypted ''MASPROD''
', 
		@database_name=N'DBAAdmin', 
		@output_file_name=N'\\wp1sqlbk04\d$\MASPROD\Backup\JobLog\proc_BackupPrimaryDatabasesEncrypted.txt', 
		@flags=6
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
		@schedule_uid=N'f89ba64c-15f5-4261-b9a4-ca08225df437'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_AGTransactionLogs (Primary Replica)]    Script Date: 11/30/2020 4:56:48 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:48 PM ******/
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
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:49 PM ******/
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
/****** Object:  Step [Backup Transaction Logs]    Script Date: 11/30/2020 4:56:49 PM ******/
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
		@command=N'EXEC dbo.proc_BackupPrimaryReplicaLogsEncrypted ''MASPROD''', 
		@database_name=N'DBAAdmin', 
		@output_file_name=N'\\wp1sqlbk04\d$\MASPROD\Backup\JobLog\proc_DBAAdmin_Backup_TransactionLogs_PrimaryReplica.txt', 
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
		@schedule_uid=N'32a99c9e-835e-463f-9499-e11c53dfee8d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_Databases (Local)]    Script Date: 11/30/2020 4:56:49 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:49 PM ******/
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
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Local Databases]    Script Date: 11/30/2020 4:56:49 PM ******/
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
		@output_file_name=N'\\wp1sqlbk04\d$\WP1MASINST02\Backup\JobLog\proc_BackupLocalDatabases.txt', 
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
		@active_start_time=4500, 
		@active_end_time=235959, 
		@schedule_uid=N'f8f16e6f-2f70-4b48-8efe-5255b554dc51'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_RemoveOlderBackups]    Script Date: 11/30/2020 4:56:49 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:49 PM ******/
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
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Older Backups]    Script Date: 11/30/2020 4:56:49 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Older Backups', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
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
		@active_start_time=500, 
		@active_end_time=235959, 
		@schedule_uid=N'964c9102-94f8-484a-80ea-a62d803dd249'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Backup_TransactionLogs (Local)]    Script Date: 11/30/2020 4:56:49 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:49 PM ******/
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
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Logs]    Script Date: 11/30/2020 4:56:49 PM ******/
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
		@output_file_name=N'\\wp1sqlbk04\d$\WP1MASINST02\Backup\JobLog\proc_BackupLocalDatabaseLogs.txt', 
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
		@schedule_uid=N'a525d924-276a-4896-bd88-ad6303c61474'
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
		@schedule_uid=N'efbb1f6a-aba7-418b-ad0d-1e440ac6de60'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_BlockingMonitoring]    Script Date: 11/30/2020 4:56:50 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:50 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:50 PM ******/
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
/****** Object:  Step [Monitor Blocking]    Script Date: 11/30/2020 4:56:50 PM ******/
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

/****** Object:  Job [DBAAdmin_Compare_SQL_Agent_Jobs]    Script Date: 11/30/2020 4:56:50 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:50 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Compare_SQL_Agent_Jobs', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:50 PM ******/
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
/****** Object:  Step [Compare SQL Agent Jobs]    Script Date: 11/30/2020 4:56:50 PM ******/
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

if object_id(''jobname_WP1MASINST01'') > 0
	drop table jobname_WP1MASINST01
select * into jobname_WP1MASINST01 from WPSITSQL01.DBAAdmin.dbo.jobname_WP1MASINST01

if object_id(''jobname_WP1MASINST02'') > 0
	drop table jobname_WP1MASINST02
select * into jobname_WP1MASINST02 from WPSITSQL01.DBAAdmin.dbo.jobname_WP1MASINST02

if object_id(''jobname_VV1MASINST01'') > 0
	drop table jobname_VV1MASINST01
select * into jobname_VV1MASINST01 from WPSITSQL01.DBAAdmin.dbo.jobname_VV1MASINST01

if object_id(''jobname_VV1MASINST02'') > 0
	drop table jobname_VV1MASINST02
select * into jobname_VV1MASINST02 from WPSITSQL01.DBAAdmin.dbo.jobname_VV1MASINST02

if object_id(''jobname_core'') > 0
	drop table jobname_core
select name into jobname_core from jobname_WP1MASINST01 a where
	exists (select b.name from jobname_WP1MASINST02 b where a.name=b.name)
	and exists (select c.name from jobname_VV1MASINST01 c where a.name=c.name)
	and exists (select d.name from jobname_VV1MASINST02 d where a.name=d.name)

if object_id(''extra_WP1MASINST01'') > 0
	drop table extra_WP1MASINST01
select name into extra_WP1MASINST01 from jobname_WP1MASINST01 a where
	not exists (select b.name from jobname_core b where a.name = b.name)

if object_id(''extra_WP1MASINST02'') > 0
	drop table extra_WP1MASINST02
select name into extra_WP1MASINST02 from jobname_WP1MASINST02 a where
	not exists (select b.name from jobname_core b where a.name = b.name)

if object_id(''extra_VV1MASINST01'') > 0
	drop table extra_VV1MASINST01
select name into extra_VV1MASINST01 from jobname_VV1MASINST01 a where
	not exists (select b.name from jobname_core b where a.name = b.name)

if object_id(''extra_VV1MASINST02'') > 0
	drop table extra_VV1MASINST02
select name into extra_VV1MASINST02 from jobname_VV1MASINST02 a where
	not exists (select b.name from jobname_core b where a.name = b.name)

select @mail_body = ''WP1MASINAT01 extra jobs: '' 
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = @mail_recipients,  
			@body = @mail_body,  
			@subject = @mail_subject,
			@query = ''select name from SSISDB.dbo.extra_WP1MASINST01'' 

select @mail_body = ''WP1MASINAT02 extra jobs: '' 
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = @mail_recipients,  
			@body = @mail_body,  
			@subject = @mail_subject, 
			@query = ''select name from SSISDB.dbo.extra_WP1MASINST02'' 

select @mail_body = ''VV1MASINAT01 extra jobs: '' 
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = @mail_recipients,  
			@body = @mail_body,  
			@subject = @mail_subject, 
			@query = ''select name from SSISDB.dbo.extra_VV1MASINST01'' 

select @mail_body = ''VV1MASINAT02 extra jobs: '' 
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = @mail_recipients,  
			@body = @mail_body,  
			@subject = @mail_subject, 
			@query = ''select name from SSISDB.dbo.extra_VV1MASINST02'' 


', 
		@database_name=N'SSISDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190508, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
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

/****** Object:  Job [DBAAdmin_Fix_Blowfish_Error]    Script Date: 11/30/2020 4:56:50 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:50 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:50 PM ******/
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
/****** Object:  Step [Fix Blowfish Errors]    Script Date: 11/30/2020 4:56:50 PM ******/
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
	(select b.name from master.dbo.sysusers b where a.name = b.name and b.name not like ''mas_ %'') and exists
	(select c.name from mi_mondb.dbo.sysusers c where a.name = c.name and c.name not like ''mas_ %'') and exists
	(select d.name from mi_masdb.dbo.sysusers d where a.name = d.name and d.name not like ''mas_ %'') and exists
	(select e.name from mi_custom.dbo.sysusers e where a.name = e.name and e.name not like ''mas_ %'')

declare mas cursor for select name from #t
open mas
fetch mas into @mas_name

while (@@fetch_status = 0)
begin
	select @cmd_user = ''CREATE USER '' + @mas_name + '' FOR LOGIN '' + @mas_name
	select @cmd_role = ''ALTER ROLE mas_user ADD MEMBER '' + @mas_name
	print @cmd_user
	print @cmd_role
	--exec(@cmd_user)
	--exec(@cmd_role)
	fetch mas into @mas_name
end
drop table #t
close mas
deallocate mas', 
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
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200109, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
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

/****** Object:  Job [DBAAdmin_Log_MSignal_Blocking]    Script Date: 11/30/2020 4:56:51 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:51 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Log_MSignal_Blocking', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job logs blocking if the row count in m_signals is 100 or greater,
OR if task 98 is enabled and not set to 1,
OR if task 101 is enabled and not set to 1.
	
While the condition exists, it will continually run sp__who2 b and log in a temp table.
When the condition ends, the data is copied to a permanently logged table within the DBAAdmin Database and the duplicates that were captured are deleted from the table.
', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not The Quit Reporting Success)]    Script Date: 11/30/2020 4:56:51 PM ******/
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
		@command=N'IF ((master.dbo.svf_AgReplicaState(''MASPROD'')=0) AND (master.dbo.svf_DbReplicaState(''mi_mondb'')=0)) RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [monitor m_signal table blocking]    Script Date: 11/30/2020 4:56:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'monitor m_signal table blocking', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbap_msignal_blocking', 
		@database_name=N'DBAAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA_Every1Minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120514, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'b3a70580-69ac-4220-95d0-a684ac80b9b3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Log_MSignal_By_Time]    Script Date: 11/30/2020 4:56:51 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:51 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Log_MSignal_By_Time', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not The Quit Reporting Success)]    Script Date: 11/30/2020 4:56:51 PM ******/
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
		@command=N'IF ((master.dbo.svf_AgReplicaState(''MASPROD'')=0) AND (master.dbo.svf_DbReplicaState(''mi_mondb'')=0)) RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [monitor m_signals greater than 90 seconds]    Script Date: 11/30/2020 4:56:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'monitor m_signals greater than 90 seconds', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbap_msignal_log_by_time', 
		@database_name=N'DBAAdmin', 
		@output_file_name=N'\\WP1NAS01\sqlbackup\WP1MASINST02\JobLog\dbap_msignal_log_by_time.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA_Every1Minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120514, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'aedecc1d-f223-4752-9db2-27726a067b19'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_MAS_Audit_Reports]    Script Date: 11/30/2020 4:56:51 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:51 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_MAS_Audit_Reports', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:51 PM ******/
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
/****** Object:  Step [Generate MAS Audit Reports]    Script Date: 11/30/2020 4:56:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate MAS Audit Reports', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @curr_date datetime
select @curr_date = getdate()
exec SSISDB.dbo.mas_reports @curr_date 


', 
		@database_name=N'SSISDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190508, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
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

/****** Object:  Job [DBAAdmin_MAS_Audit_Scripts]    Script Date: 11/30/2020 4:56:52 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:52 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_MAS_Audit_Scripts', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:52 PM ******/
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
/****** Object:  Step [Generate MAS Audit Reports]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate MAS Audit Reports', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBAAdmin.dbo.mas_sox_scripts



', 
		@database_name=N'DBAAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190508, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
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

/****** Object:  Job [DBAAdmin_MASPROD_Post_Failover_Tasks]    Script Date: 11/30/2020 4:56:52 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:52 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_MASPROD_Post_Failover_Tasks', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Availability Group Role]    Script Date: 11/30/2020 4:56:52 PM ******/
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

SET @AgName = ''MASPROD''
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
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\DBAAdmin_MASPROD_Post_Failover_Tasks.txt', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Monitor Server Table]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Monitor Server Table', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [mi_mondb];
GO
UPDATE mi_mondb.dbo.monitor_server
SET servername = @@SERVERNAME,
 active_date = GETDATE()
where server_id=''G'';
UPDATE mi_mondb.dbo.monitor_server
SET active_flag = ''Y'', batch_flag = ''Y'', active_date = GETDATE()
WHERE servername = @@SERVERNAME
GO', 
		@database_name=N'mi_mondb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST01\JobLog\DBAAdmin_MASPROD_Post_Failover_Tasks.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Vertex Server Task Table]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Vertex Server Task Table', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [mi_masdb];
GO

UPDATE mi_masdb.dbo.vertex_server_task
SET vertex_server_name = @@SERVERNAME;
GO', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST01\JobLog\DBAAdmin_MASPROD_Post_Failover_Tasks.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Business Server Table]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Business Server Table', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [mi_custom];
GO
UPDATE mi_custom.dbo.business_server
SET business_flag = ''N'', external_apps_flag= ''N''
WHERE business_flag = ''Y'' AND external_apps_flag = ''Y''
UPDATE mi_custom.dbo.business_server
SET business_flag = ''Y'', external_apps_flag = ''Y''
WHERE servername = @@SERVERNAME


', 
		@database_name=N'master', 
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\DBAAdmin_MASPROD_Post_Failover_Tasks.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update al_queue_master]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update al_queue_master', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'update al_queue_master
   set servername = @@servername
where queue_id = ''q_prod01''
   and servername <> @@servername
 
', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [De-orphan master]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'De-orphan master', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

SET NOCOUNT OFF

CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL
	FETCH NEXT FROM OrphList INTO @LoginName
	BEGIN TRY
		EXEC (@SQL)
	END TRY
	BEGIN CATCH
		CONTINUE
	END CATCH
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [De-orphan - mi_custom]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'De-orphan - mi_custom', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

SET NOCOUNT OFF

CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL
	FETCH NEXT FROM OrphList INTO @LoginName
	BEGIN TRY
		EXEC (@SQL)
	END TRY
	BEGIN CATCH
		CONTINUE
	END CATCH
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans

', 
		@database_name=N'mi_custom', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [De orphan - mi_masdb]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'De orphan - mi_masdb', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

SET NOCOUNT OFF

CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL
	FETCH NEXT FROM OrphList INTO @LoginName
	BEGIN TRY
		EXEC (@SQL)
	END TRY
	BEGIN CATCH
		CONTINUE
	END CATCH
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans

', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [De orphan - mi_mondb]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'De orphan - mi_mondb', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

SET NOCOUNT OFF

CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL
	FETCH NEXT FROM OrphList INTO @LoginName
	BEGIN TRY
		EXEC (@SQL)
	END TRY
	BEGIN CATCH
		CONTINUE
	END CATCH
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans

', 
		@database_name=N'mi_mondb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [De-orphan SSISDB]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'De-orphan SSISDB', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

SET NOCOUNT OFF

CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL
	FETCH NEXT FROM OrphList INTO @LoginName
	BEGIN TRY
		EXEC (@SQL)
	END TRY
	BEGIN CATCH
		CONTINUE
	END CATCH
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans
', 
		@database_name=N'SSISDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restart MAS Ex Services (WP1MASWEB01)]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restart MAS Ex Services (WP1MASWEB01)', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'#$ServiceName = "MASterMind EX Services 6.40.01.009 (x64) - I00"
#$Server = "WP1MASWEB01"

#Get-Service -Name $ServiceName -ComputerName $Server


#Get-Service -Name $ServiceName -ComputerName $Server | Where-Object {$_.Status -eq "Running"} | Stop-Service
#Get-Service -Name $ServiceName -ComputerName $Server | Where-Object {$_.Status -eq "Stopped"} | Start-Service
#Get-Service -Name $ServiceName -ComputerName $Server', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restart MAS Ex Services (WP1MASWEB02)]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restart MAS Ex Services (WP1MASWEB02)', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'#$ServiceName = "MASterMind EX Services 6.40.01.009 (x64) - I00"
#$Server = "WP1MASWEB02"

#Get-Service -Name $ServiceName -ComputerName $Server


#Get-Service -Name $ServiceName -ComputerName $Server | Where-Object {$_.Status -eq "Running"} | Restart-Service
#Get-Service -Name $ServiceName -ComputerName $Server | Where-Object {$_.Status -eq "Stopped"} | Start-Service
#Get-Service -Name $ServiceName -ComputerName $Server', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Selected Jobs]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Selected Jobs', 
		@step_id=13, 
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
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\DBAAdmin_MASPROD_Post_Failover_Tasks.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sync MAS users passwords]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sync MAS users passwords', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @cmd nvarchar(2000)
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

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Move Cluster Group]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Move Cluster Group', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'Move-ClusterGroup -Name "Cluster Group" -Node WP1MASINST02
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Report Post Failover Tasks Complete]    Script Date: 11/30/2020 4:56:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Report Post Failover Tasks Complete', 
		@step_id=16, 
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
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\DBAAdmin_MASPROD_Post_Failover_Tasks.txt', 
		@flags=2
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

/****** Object:  Job [DBAAdmin_MASPROD_Turn_Down]    Script Date: 11/30/2020 4:56:53 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:53 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_MASPROD_Turn_Down', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'During a PLANNED FAILOVER this job should be run on the ACTIVE PRIMARY for MASPROD Availability Group.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stop Selected SQL Server Agent Jobs]    Script Date: 11/30/2020 4:56:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stop Selected SQL Server Agent Jobs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
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
DECLARE C1 CURSOR READ_ONLY FORWARD_ONLY LOCAL FOR SELECT [job_name], [primary_enabled], [secondary_enabled], [start_immediately] FROM DBAAdmin.dbo.AGJobManagement WHERE ag_name = ''MASPROD''
OPEN C1;
FETCH C1 INTO @job_name, @primary_enabled, @secondary_enabled, @start_immediately;
WHILE @@FETCH_STATUS = 0
	BEGIN
	  IF @primary_enabled = 1 AND @secondary_enabled = 0
	    BEGIN
                                  IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs J JOIN msdb.dbo.sysjobactivity A ON A.job_id=J.job_id WHERE J.name= @job_name AND A.run_requested_date IS NOT NULL AND A.stop_execution_date IS NULL)
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
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\DBAAdmin_MASPROD_Turn_Down.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stop MAS Ex Services (WP1MASWEB01)]    Script Date: 11/30/2020 4:56:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stop MAS Ex Services (WP1MASWEB01)', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'#$ServiceName = "MASterMind EX Services 6.40.01.009 (x64)*"
#$Server = "WP1MASWEB01.corp.brinkshome.com"

#Get-Service -Name $ServiceName -ComputerName $Server


#Get-Service -Name $ServiceName -ComputerName $Server | Where-Object {$_.Status -eq "Running"} | Stop-Service', 
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

/****** Object:  Job [DBAAdmin_MessageAcceptedAlarms]    Script Date: 11/30/2020 4:56:53 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:53 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_MessageAcceptedAlarms', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Send a message to a user session that has accepted an alarm with out clearing it during a planned or unplanned failover', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:53 PM ******/
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
/****** Object:  Step [Send Message to a User Session]    Script Date: 11/30/2020 4:56:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Send Message to a User Session', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBAAdmin.dbo.prod_NotifyAcceptedAlarms', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every Minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180309, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'562078f6-d31f-49dd-9c90-fc95aa8cdce2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Move_ClusterGroup_To_VV1MASINST01]    Script Date: 11/30/2020 4:56:53 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:53 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Move_ClusterGroup_To_VV1MASINST01', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Move the MASINST.corp.brinkshome.com Cluster Group to VV1MASINST01', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Move Cluster Group to VV1MASINST01]    Script Date: 11/30/2020 4:56:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Move Cluster Group to VV1MASINST01', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
try{
   Move-ClusterGroup -Name "Cluster Group" -Node VV1MASINST01 -Cluster MASINST.corp.brinkshome.com
   }
catch{
   Throw
}', 
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

/****** Object:  Job [DBAAdmin_Move_ClusterGroup_To_VV1MASINST02]    Script Date: 11/30/2020 4:56:53 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:53 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Move_ClusterGroup_To_VV1MASINST02', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Move the MASINST.corp.brinkshome.com Cluster Group to VV1MASINST02', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Move Cluster Group to VV1MASINST02]    Script Date: 11/30/2020 4:56:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Move Cluster Group to VV1MASINST02', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
try{
   Move-ClusterGroup -Name "Cluster Group" -Node VV1MASINST02 -Cluster MASINST.corp.brinkshome.com
   }
catch{
   Throw
}', 
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

/****** Object:  Job [DBAAdmin_Move_ClusterGroup_To_WP1MASINST01]    Script Date: 11/30/2020 4:56:54 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:54 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Move_ClusterGroup_To_WP1MASINST01', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Move the MASINST.corp.brinkshome.com Cluster Group to WP1MASINST01', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Move Cluster Group to WP1MASINST01]    Script Date: 11/30/2020 4:56:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Move Cluster Group to WP1MASINST01', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
try{
   Move-ClusterGroup -Name "Cluster Group" -Node WP1MASINST01 -Cluster MASINST.corp.brinkshome.com
   }
catch{
   Throw
}', 
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

/****** Object:  Job [DBAAdmin_Move_ClusterGroup_To_WP1MASINST02]    Script Date: 11/30/2020 4:56:54 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:54 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Move_ClusterGroup_To_WP1MASINST02', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Move the MASINST.corp.brinkshome.com Cluster Group to WP1MASINST02', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Move Cluster Group to WP1MASINST02]    Script Date: 11/30/2020 4:56:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Move Cluster Group to WP1MASINST02', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$ErrorActionPreference = "Stop"
try{
   Move-ClusterGroup -Name "Cluster Group" -Node WP1MASINST02 -Cluster MASINST.corp.brinkshome.com
   }
catch{
   Throw
}', 
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

/****** Object:  Job [DBAAdmin_OnSQLAgentRestart]    Script Date: 11/30/2020 4:56:54 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:54 PM ******/
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
/****** Object:  Step [add users to tempdb]    Script Date: 11/30/2020 4:56:54 PM ******/
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
', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [send alert]    Script Date: 11/30/2020 4:56:54 PM ******/
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
	,  @body=''Stacy and Vince added back as db_owner into tempdb; turned deadlock capture trace flag 1222 on'' 
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
		@schedule_uid=N'9456b36b-303a-4485-a063-7da357fe3017'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Post_Automatic_Failover_Tasks]    Script Date: 11/30/2020 4:56:55 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:55 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Post_Automatic_Failover_Tasks', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check AG Role]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check AG Role', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF ((master.dbo.svf_AgReplicaState(''MAS'')=0) AND (master.dbo.svf_DbReplicaState(''mi_custom'')=0)) RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Monitor Server If Needed]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Monitor Server If Needed', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (SELECT 1 FROM mi_mondb.dbo.monitor_server WHERE servername != @@SERVERNAME)
  BEGIN
/*
    UPDATE mi_mondb.dbo.monitor_server
    SET servername = @@SERVERNAME,
      active_date = GETDATE();
*/
UPDATE mi_mondb.dbo.monitor_server
SET active_flag = ''N'', batch_flag = ''N''
WHERE active_flag = ''Y'' AND batch_flag = ''Y''
UPDATE mi_mondb.dbo.monitor_server
SET active_flag = ''Y'', batch_flag = ''Y'', active_date = GETDATE()
WHERE servername = @@SERVERNAME

  END
GO
', 
		@database_name=N'mi_mondb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Vertex Server Task Table If Needed]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Vertex Server Task Table If Needed', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (SELECT 1 FROM mi_masdb.dbo.vertex_server_task WHERE vertex_server_name != @@SERVERNAME)
  BEGIN
    UPDATE mi_masdb.dbo.vertex_server_task
    SET vertex_server_name = @@SERVERNAME;
  END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Business Server Table If Needed]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Business Server Table If Needed', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (SELECT 1 FROM mi_custom.dbo.business_server WHERE servername != @@SERVERNAME)
  BEGIN
    UPDATE mi_custom.dbo.business_server
    SET servername = @@SERVERNAME;
        -- EXECUTE DBAAdmin.dbo.proc_CheckForAcceptedAlarms
     -- EXEC xp_cmdshell ''sc \\WP1MASWEB01.corp.brinkshome.com stop "MASterMind EX Services 6.40.01.009 (x64) - I00"''
     -- EXEC xp_cmdshell ''sc \\WP1MASWEB01.corp.brinkshome.com start "MASterMind EX Services 6.40.01.009 (x64) - I00"''
  END
GO', 
		@database_name=N'mi_custom', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every Minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180309, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'ac98045f-79eb-467e-8022-fc345420d987'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_RestoreMASTrio]    Script Date: 11/30/2020 4:56:55 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:55 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_RestoreMASTrio', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'PMS\brundmi', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore mi_custom]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore mi_custom', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'function LiteSpeedRestore($srv, $DatabaseName, $RestoreToServer, $RestoreFromLocation)
{
$RestoreFromLocation
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {''''
   $PrimaryFG = '' MOVE N'''''''''' + $pf.Name + '''''''''' TO N'''''''''' + $pf.FileName + ''''''''''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE N'''''''''' + $lf.Name + '''''''''' TO N'''''''''' + $lf.FileName + ''''''''''''''''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

$RestoreCommand = $KillCommand + '' EXEC master.dbo.xp_restore_database @database = N'''''' + $DatabaseName + '''''' , @filename = N'''''' + $RestoreFromLocation + '''''',
@filenumber = 1, @encryptionkey = N''''7908d2f6a8737846f07758a7553179ca'''', @with = N''''REPLACE'''', @with = N''''STATS = 10'''',
@with = N'''''' + $PrimaryFG + '', @with = N'''''' + $LogFG + '', @affinity = 0, @logging = 0;''

# $RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

function NativeRestore($srv, $DatabaseName, $RestoreToServer, $backupLocation)
{
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {
   $PrimaryFG = '' MOVE '''''' + $pf.Name + '''''' TO '''''' + $pf.FileName + ''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE '''''' + $lf.Name + '''''' TO '''''' + $lf.FileName + '''''' ''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

# Build a string for the native restore command
$RestoreCommand = $KillCommand + '' RESTORE DATABASE ['' + 
                  $DatabaseName + ''] FROM DISK = '''''' + $backupLocation + '''''' WITH REPLACE, '' + $PrimaryFG + '', '' + $LogFG + '', STATS = 5;''

$RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

# import-module "sqlps" -DisableNameChecking
# Name of the database to restore
$DatabaseName = ''mi_custom''
# Name of the server to restore to
$RestoreToServer = ''WP4MASINST01''
# $RestoreToServer = $env:computername
# Name of the source server
$RestoreFromServer = ''CYCLONE''
# Build a path string to the location of the backup file
$BackupPath = (''\\WP1NAS01\sqlbackup\'' + $RestoreFromServer + ''\Backup\A-Full\'')
#$BackupPath = ''\\wp4fs01\LE_Backups\WP4MASSQL01\Restore\''

Set-Location c:

# Get the name of the backup file to restore.  Sort newest backup first.  Output the file name to the $BackupFileName variable.  This will be an array variable
Get-ChildItem -Name -Path ($BackupPath + ''*'' + $DatabaseName + ''*'') -OutVariable BackupFileName | Where-Object { -not $_.PsIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -first 1

# Build a string with the complelete UNC filename to restore.  
$backupLocation = ($backupPath + 
    $BackupFileName[0]) # Use the first file in the list.

# $backupLocation

# Load the SQL Server Management Object Assembly
[System.Reflection.Assembly]::LoadWithPartialName(''Microsoft.SqlServer.SMO'') | out-null
$srv = New-Object (''Microsoft.SqlServer.Management.Smo.Server'') $RestoreToServer
# $db = $svr.Databases

LiteSpeedRestore $srv $DatabaseName $RestoreToServer $backupLocation
# NativeRestore $srv $DatabaseName $RestoreToServer $backupLocation









', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore mi_mondb]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore mi_mondb', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'function LiteSpeedRestore($srv, $DatabaseName, $RestoreToServer, $RestoreFromLocation)
{
$RestoreFromLocation
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {''''
   $PrimaryFG = '' MOVE N'''''''''' + $pf.Name + '''''''''' TO N'''''''''' + $pf.FileName + ''''''''''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE N'''''''''' + $lf.Name + '''''''''' TO N'''''''''' + $lf.FileName + ''''''''''''''''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

$RestoreCommand = $KillCommand + '' EXEC master.dbo.xp_restore_database @database = N'''''' + $DatabaseName + '''''' , @filename = N'''''' + $RestoreFromLocation + '''''',
@filenumber = 1, @encryptionkey = N''''7908d2f6a8737846f07758a7553179ca'''', @with = N''''REPLACE'''', @with = N''''STATS = 10'''',
@with = N'''''' + $PrimaryFG + '', @with = N'''''' + $LogFG + '', @affinity = 0, @logging = 0;''

# $RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

function NativeRestore($srv, $DatabaseName, $RestoreToServer, $backupLocation)
{
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {
   $PrimaryFG = '' MOVE '''''' + $pf.Name + '''''' TO '''''' + $pf.FileName + ''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE '''''' + $lf.Name + '''''' TO '''''' + $lf.FileName + '''''' ''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

# Build a string for the native restore command
$RestoreCommand = $KillCommand + '' RESTORE DATABASE ['' + 
                  $DatabaseName + ''] FROM DISK = '''''' + $backupLocation + '''''' WITH REPLACE, '' + $PrimaryFG + '', '' + $LogFG + '', STATS = 5;''

$RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

# import-module "sqlps" -DisableNameChecking
# Name of the database to restore
$DatabaseName = ''mi_mondb''
# Name of the server to restore to
$RestoreToServer = ''WP4MASINST01''
# $RestoreToServer = $env:computername
# Name of the source server
$RestoreFromServer = ''CYCLONE''
# Build a path string to the location of the backup file
$BackupPath = (''\\WP1NAS01\sqlbackup\'' + $RestoreFromServer + ''\Backup\A-Full\'')
#$BackupPath = ''\\wp4fs01\LE_Backups\WP4MASSQL01\Restore\''

Set-Location c:

# Get the name of the backup file to restore.  Sort newest backup first.  Output the file name to the $BackupFileName variable.  This will be an array variable
Get-ChildItem -Name -Path ($BackupPath + ''*'' + $DatabaseName + ''*'') -OutVariable BackupFileName | Where-Object { -not $_.PsIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -first 1

# Build a string with the complelete UNC filename to restore.  
$backupLocation = ($backupPath + 
    $BackupFileName[0]) # Use the first file in the list.

# $backupLocation

# Load the SQL Server Management Object Assembly
[System.Reflection.Assembly]::LoadWithPartialName(''Microsoft.SqlServer.SMO'') | out-null
$srv = New-Object (''Microsoft.SqlServer.Management.Smo.Server'') $RestoreToServer
# $db = $svr.Databases

LiteSpeedRestore $srv $DatabaseName $RestoreToServer $backupLocation
# NativeRestore $srv $DatabaseName $RestoreToServer $backupLocation
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore mi_masdb]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore mi_masdb', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'function LiteSpeedRestore($srv, $DatabaseName, $RestoreToServer, $RestoreFromLocation)
{
$RestoreFromLocation
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {''''
   $PrimaryFG = '' MOVE N'''''''''' + $pf.Name + '''''''''' TO N'''''''''' + $pf.FileName + ''''''''''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE N'''''''''' + $lf.Name + '''''''''' TO N'''''''''' + $lf.FileName + ''''''''''''''''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

$RestoreCommand = $KillCommand + '' EXEC master.dbo.xp_restore_database @database = N'''''' + $DatabaseName + '''''' , @filename = N'''''' + $RestoreFromLocation + '''''',
@filenumber = 1, @encryptionkey = N''''7908d2f6a8737846f07758a7553179ca'''', @with = N''''REPLACE'''', @with = N''''STATS = 10'''',
@with = N'''''' + $PrimaryFG + '', @with = N'''''' + $LogFG + '', @affinity = 0, @logging = 0;''

# $RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

function NativeRestore($srv, $DatabaseName, $RestoreToServer, $backupLocation)
{
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {
   $PrimaryFG = '' MOVE '''''' + $pf.Name + '''''' TO '''''' + $pf.FileName + ''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE '''''' + $lf.Name + '''''' TO '''''' + $lf.FileName + '''''' ''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

# Build a string for the native restore command
$RestoreCommand = $KillCommand + '' RESTORE DATABASE ['' + 
                  $DatabaseName + ''] FROM DISK = '''''' + $backupLocation + '''''' WITH REPLACE, '' + $PrimaryFG + '', '' + $LogFG + '', STATS = 5;''

$RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

# import-module "sqlps" -DisableNameChecking
# Name of the database to restore
$DatabaseName = ''mi_masdb''
# Name of the server to restore to
$RestoreToServer = ''WP4MASINST01''
# $RestoreToServer = $env:computername
# Name of the source server
$RestoreFromServer = ''CYCLONE''
# Build a path string to the location of the backup file
$BackupPath = (''\\WP1NAS01\sqlbackup\'' + $RestoreFromServer + ''\Backup\A-Full\'')
#$BackupPath = ''\\wp4fs01\LE_Backups\WP4MASSQL01\Restore\''

Set-Location c:

# Get the name of the backup file to restore.  Sort newest backup first.  Output the file name to the $BackupFileName variable.  This will be an array variable
Get-ChildItem -Name -Path ($BackupPath + ''*'' + $DatabaseName + ''*'') -OutVariable BackupFileName | Where-Object { -not $_.PsIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -first 1

# Build a string with the complelete UNC filename to restore.  
$backupLocation = ($backupPath + 
    $BackupFileName[0]) # Use the first file in the list.

# $backupLocation

# Load the SQL Server Management Object Assembly
[System.Reflection.Assembly]::LoadWithPartialName(''Microsoft.SqlServer.SMO'') | out-null
$srv = New-Object (''Microsoft.SqlServer.Management.Smo.Server'') $RestoreToServer
# $db = $svr.Databases

LiteSpeedRestore $srv $DatabaseName $RestoreToServer $backupLocation
# NativeRestore $srv $DatabaseName $RestoreToServer $backupLocation
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Cleanup mi Databases]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cleanup mi Databases', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
/*
These commands are meant to get the databases into a state more condusive to the test environment. 
The following is completed on each database.

1. Recovery set to SIMPLE
2. SA set as the DB Owner
3. Log file is shrunk to preserve space
4. Statistics on all indexes are updated

To save time, each step may be executed individually as each of the restores in Step 003a for the 
corresponding server completes. (i.e. When mi_mondb restore completes, go ahead and 
run the cleanup process for mi_custom as the other databases are restoring, etc. etc.)
*/
/*
use master
go

ALTER DATABASE [mi_custom] SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::mi_custom TO sa

USE mi_custom
go

TRUNCATE TABLE repl_tran;
TRUNCATE TABLE mi_wsi_error_log;
TRUNCATE TABLE mi_wsi_error_log_history;

DBCC SHRINKFILE (N''mi_custom_log'' , 0)
GO



use master
go

ALTER DATABASE [mi_mondb] SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::mi_mondb TO sa

USE mi_mondb
go 

DBCC SHRINKFILE (N''mi_mondb_log'' , 0)
GO

use master
go

ALTER DATABASE [mi_masdb] SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::mi_masdb TO sa

USE mi_masdb
go

DBCC SHRINKFILE (N''mi_masdb_log'' , 0)
GO


*/
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [mi_custom 2nd Grant Statements]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_custom 2nd Grant Statements', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE mi_custom
go

grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_audit to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_bad_codewords to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_bad_permits to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_busrules to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_cell_ani to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_cell_provider to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_contact to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_contact_link to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_contact_list to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_contact_phone to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_cs_prefix to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_equip_event_xref to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_error_log to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_error_log_history to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_keys to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_message to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_ooscats to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_permit to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_permit_exempt_service_company to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_prefix_phone to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_processing_rule to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_req_zones to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_sec_group to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_agency to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_dispatch to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_general_dispatch to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_general_info to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_note to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_option to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_permit to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_site_system_option to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_sitetype to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_special_zones to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_system to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_system_user_id to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_systype to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_systype_bkup to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_systype_xref to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_testcats to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_trace to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_user_error_log to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_user_error_log_history to mas_user
grant SELECT, INSERT, UPDATE,DELETE, REFERENCES on mi_wsi_zone to mas_user
GRANT EXECUTE ON mi_GetWSIErrorLogHistory TO mas_user', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop and Add Users mi_custom]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop and Add Users mi_custom', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- $Header: $
-- users specific to mi_custom

USE mi_custom
go

--EXEC sp_dropuser ''masvdi_main''
--go
--EXEC sp_adduser masvdi_main,masvdi_main,mas_user
--go

--EXEC sp_dropuser ''masvertex''
--go
--EXEC sp_adduser masvertex,masvertex,mas_user
--go

--EXEC sp_dropuser ''masweb_main''
--go
--EXEC sp_adduser masweb_main,masweb_main,mas_user
--go

--EXEC sp_dropuser ''maswsi_user''
--go
--EXEC sp_adduser maswsi_user,maswsi_user,mas_user
--go



USE [mi_custom]
GO
CREATE USER [PMS\rosenad] FOR LOGIN [PMS\rosenad]
GO
CREATE USER [PMS\bennesc] FOR LOGIN [PMS\bennesc]
GO

USE [mi_custom]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\rosenad''
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\bennesc''
GO



--This section grants permissions to devs to increase permission in the UAT environment
--to view definition of objects

--use [mi_custom]
--GO
--GRANT VIEW DEFINITION TO [PMS\skyttel]
--GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop and Add Users mi_mondb and mi_masdb]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop and Add Users mi_mondb and mi_masdb', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- $Header: $
-- users specific to mi_masdb / mi_mondb


USE [mi_masdb]
GO
CREATE USER [PMS\rosenad] FOR LOGIN [PMS\rosenad]
GO
USE [mi_masdb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\rosenad''
GO

USE [mi_mondb]
GO
CREATE USER [PMS\rosenad] FOR LOGIN [PMS\rosenad]
GO
USE [mi_mondb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\rosenad''
GO

USE [mi_masdb]
GO
CREATE USER [PMS\bennesc] FOR LOGIN [PMS\bennesc]
GO
USE [mi_masdb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\bennesc''
GO

USE [mi_mondb]
GO
CREATE USER [PMS\bennesc] FOR LOGIN [PMS\bennesc]
GO
USE [mi_mondb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\bennesc''
GO








--This section grants permissions to devs to increase permission in the UAT environment
--to view definition of objects

--use [mi_masdb]
--GO
--GRANT VIEW DEFINITION TO [PMS\skyttel]
--GO

--use [mi_mondb]
--GO
--GRANT VIEW DEFINITION TO [PMS\skyttel]
--GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Fix Orphaned Users]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fix Orphaned Users', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
--de-orphans logins --but the user must exist as a login at the server level

use mi_custom
go

PRINT ''mi_custom'' +CHAR(13)
--Section 1
--drops any database logins that are not on the development server

SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

CREATE TABLE #schemas (script VARCHAR(MAX))

INSERT #schemas
SELECT  ''IF  EXISTS (SELECT * FROM sys.schemas WHERE name = ''''''+name+'''''') BEGIN DROP SCHEMA [''+name+''] END DROP USER [''+name+''] ''
FROM    sys.database_principals where TYPE in (''S'')   
	 AND name NOT IN (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'')
	 AND name NOT IN
		  (SELECT  name  FROM   sys.sql_logins)

DECLARE SchemaList CURSOR FAST_FORWARD FOR SELECT script FROM #schemas

OPEN SchemaList
FETCH NEXT FROM SchemaList INTO @SQL
WHILE @@FETCH_STATUS = 0
BEGIN

	PRINT @SQL

	EXEC (@SQL)
	FETCH NEXT FROM SchemaList INTO @SQL
END

CLOSE SchemaList
DEALLOCATE SchemaList

DROP TABLE #schemas

SET NOCOUNT OFF
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--Section 2
--de-orphan the remaining db users


CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL

	EXEC (@SQL)
	FETCH NEXT FROM OrphList INTO @LoginName
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans


----------------------------------------------------------------------------

use mi_masdb
go

PRINT CHAR(13)+''mi_masdb''+CHAR(13)
--Section 1
--drops any database logins that are not on the development server

SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

CREATE TABLE #schemas (script VARCHAR(MAX))

INSERT #schemas
SELECT  ''IF  EXISTS (SELECT * FROM sys.schemas WHERE name = ''''''+name+'''''') BEGIN DROP SCHEMA [''+name+''] END DROP USER [''+name+''] ''
FROM    sys.database_principals where TYPE in (''S'')   
	 AND name NOT IN (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'')
	 AND name NOT IN
		  (SELECT  name  FROM   sys.sql_logins)

DECLARE SchemaList CURSOR FAST_FORWARD FOR SELECT script FROM #schemas

OPEN SchemaList
FETCH NEXT FROM SchemaList INTO @SQL
WHILE @@FETCH_STATUS = 0
BEGIN

	PRINT @SQL

	EXEC (@SQL)
	FETCH NEXT FROM SchemaList INTO @SQL
END

CLOSE SchemaList
DEALLOCATE SchemaList

DROP TABLE #schemas

SET NOCOUNT OFF
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--Section 2
--de-orphan the remaining db users


CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL

	EXEC (@SQL)
	FETCH NEXT FROM OrphList INTO @LoginName
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans

-----------------------------------------------------------

use mi_mondb
go

PRINT CHAR(13)+''mi_mondb''+CHAR(13)
--Section 1
--drops any database logins that are not on the development server

SET NOCOUNT ON
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @LoginName AS VARCHAR(8000)

CREATE TABLE #schemas (script VARCHAR(MAX))

INSERT #schemas
SELECT  ''IF  EXISTS (SELECT * FROM sys.schemas WHERE name = ''''''+name+'''''') BEGIN DROP SCHEMA [''+name+''] END DROP USER [''+name+''] ''
FROM    sys.database_principals where TYPE in (''S'')   
	 AND name NOT IN (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'')
	 AND name NOT IN
		  (SELECT  name  FROM   sys.sql_logins)

DECLARE SchemaList CURSOR FAST_FORWARD FOR SELECT script FROM #schemas

OPEN SchemaList
FETCH NEXT FROM SchemaList INTO @SQL
WHILE @@FETCH_STATUS = 0
BEGIN

	PRINT @SQL

	EXEC (@SQL)
	FETCH NEXT FROM SchemaList INTO @SQL
END

CLOSE SchemaList
DEALLOCATE SchemaList

DROP TABLE #schemas

SET NOCOUNT OFF
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--Section 2
--de-orphan the remaining db users


CREATE TABLE #Orphans (
	UserName VARCHAR(250),
	UserSID VARCHAR(8000))
	
INSERT #orphans EXEC sp_change_users_login ''report''

DECLARE OrphList CURSOR FAST_FORWARD FOR SELECT Username FROM #orphans

OPEN OrphList
FETCH NEXT FROM OrphList INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = ''sp_change_users_login ''''Update_One'''', ''''''+ @LoginName + '''''', ''''''+ @LoginName + ''''''''
	PRINT @SQL

	EXEC (@SQL)
	FETCH NEXT FROM OrphList INTO @LoginName
END

CLOSE OrphList
DEALLOCATE OrphList

DROP TABLE #Orphans', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Correct sysopts]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Correct sysopts', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go


-- $Header: $

-- re-create system_option view, update database names

-- run in the Business Database


--  BE CAREFUL!!!!  if you are running this on a test database that is being used to test signals with NO business database, just

--update the system_option table and set option_value=''SIGNALDB'' where option_id=''monitoring_database''

--we do NOT want to update the view that resides in the business database to point to this testing db!


SET NOCOUNT ON


DECLARE @busdb sysname, @mondb sysname


-- set these variables to the appropriate databases

SELECT @busdb = ''mi_masdb'', @mondb = ''mi_mondb''

-- both databases must be specified

IF ISNULL(@busdb,'''') = '''' OR ISNULL(@mondb,'''') = ''''

BEGIN
  
  EXEC dbo.sp__msg ''ERROR: must specify busdb and mondb, busdb=%1, mondb=%2'', NULL, @busdb, @mondb
  
  RETURN
  
END

-- both databases must be different

ELSE
 IF @busdb = @mondb
  
BEGIN
  
    EXEC dbo.sp__msg ''ERROR: bus/mon databases must be different, busdb=%1, mondb=%2'', NULL, @busdb, @mondb
  
    RETURN

END
-- must be run from business database

ELSE
 IF @busdb <> DB_NAME()

    BEGIN
  
       EXEC dbo.sp__msg ''ERROR: must be run from business MM database, busdb=%1'', NULL, @busdb
  
       RETURN
     
END


-- take care of system_option first, since it contains names of databases

DROP VIEW system_option

EXEC(''CREATE VIEW dbo.system_option AS SELECT * FROM '' + @mondb + ''.dbo.system_option'')

GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.system_option TO mas_user

GRANT SELECT ON dbo.system_option TO external_user


UPDATE system_option SET option_value = @busdb WHERE option_id = ''business_database''

UPDATE system_option SET option_value = @mondb WHERE option_id = ''monitoring_database''

go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Recreate MMB Views]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Recreate MMB Views', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb
go

-- $Header: $
-- update monitoring views in MM business database; must be run from business database
-- even if restoring ''mi_masdb'' and ''mi_mondb'' still need to run this because the Vertex views get changed
-- the test vertex server may be masvertex1 or masvertex2 (sql2008), depending on needs, references to the vertex test server
--      may need to be replaced (see start line 200)

SET NOCOUNT ON

DECLARE @busdb sysname, @mondb sysname

-- set these variables to the appropriate databases
SELECT @busdb = ''mi_masdb'', @mondb = ''mi_mondb''








-- both databases must be specified
IF ISNULL(@busdb,'''') = '''' OR ISNULL(@mondb,'''') = ''''
BEGIN
  EXEC dbo.sp__msg ''ERROR: must specify busdb and mondb, busdb=%1, mondb=%2'', NULL, @busdb, @mondb
  RETURN
END
-- both databases must be different
ELSE IF @busdb = @mondb
BEGIN
  EXEC dbo.sp__msg ''ERROR: bus/mon databases must be different, busdb=%1, mondb=%2'', NULL, @busdb, @mondb
  RETURN
END
-- must be run from business database
ELSE IF @busdb <> DB_NAME()
BEGIN
  EXEC dbo.sp__msg ''ERROR: must be run from business MM database, busdb=%1'', NULL, @busdb
  RETURN
END

DECLARE @debug char(1), @start_time datetime, @msg varchar(255),
        @name sysname, @view sysname, @sql varchar(4000),
        @eview sysname, @eviews varchar(1024), @cnt int, @ecnt int

SELECT @start_time = GETDATE(), @cnt = 0, @ecnt = 0, @debug = ''N''

EXEC dbo.sp__msg ''STARTING re-create monitoring views''

SELECT @eviews = ''action_e,action_status_e,action_type_e,alarm_priority_e,authority_e,''
                    + ''call_disposition_e,contact_disposition_e,contact_list_type_e,contact_type_e,''
                    + ''daylight_savings_time_e,event_e,event_report_code_e,global_dispatch_e,holiday_e,''
                    + ''job_cause_e,job_class_e,job_request_e,job_type_e,oos_category_e,problem_e,''
                    + ''process_option_e,relation_e,resolution_e,service_plan_e,site_status_e,''
                    + ''site_type_e,test_category_e,time_zone_e,udf_control_e,udf_e,udf_type_e,''
                    + ''zone_state_e''

-- get a list of all user tables in mondb that aren''t also tables in busdb
CREATE TABLE #views (name sysname, type char(1))
SELECT @sql = ''INSERT #views (name) ''
                + ''SELECT name FROM '' + @mondb + ''.dbo.sysobjects a ''
                +  ''WHERE type = ''''U'''' AND OBJECTPROPERTY(OBJECT_ID(name),''''IsTable'''')=0''
EXEC (@sql)

SELECT @name = MIN(name) FROM #views
WHILE @name IS NOT NULL
BEGIN
  SELECT @view = @name, @eview = @view + ''_e''
  IF master.dbo.fn__inlist(@eviews,@eview,'','') = ''N''
    SELECT @eview = NULL

  -- use same code to create view and _e view (if necessary)
  WHILE (@view IS NOT NULL)
  BEGIN
    -- drop view if it already exists
    IF OBJECTPROPERTY(OBJECT_ID(@view),''IsView'') = 1
    BEGIN
      SELECT @sql = ''DROP VIEW '' + @view
      IF @debug = ''Y'' PRINT @sql
      EXEC (@sql)
    END

    SELECT @sql = ''CREATE VIEW dbo.'' + @view + '' AS SELECT * FROM '' + @mondb + ''.dbo.'' + @name
    IF @debug = ''Y'' PRINT @sql
    EXEC (@sql)
    SELECT @sql = ''GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.'' + @view + '' TO mas_user''
    IF @debug = ''Y'' PRINT @sql
    EXEC (@sql)
    SELECT @sql = ''GRANT SELECT ON dbo.'' + @view + '' TO external_user''
    IF @debug = ''Y'' PRINT @sql
    EXEC (@sql)

    IF @eview IS NOT NULL
    BEGIN
      -- just created view, now create eview
      IF @view <> @eview
        SELECT @cnt = @cnt + 1,
               @view = @eview
      -- just created eview, done with this name
      ELSE
        SELECT @ecnt = @ecnt + 1,
               @view = NULL
    END
    -- just created view, no eview, done with this name
    ELSE
      SELECT @cnt = @cnt + 1,
             @view = NULL
  END

  SELECT @name = MIN(name) FROM #views WHERE name > @name
END

EXEC dbo.sp__msg ''Created %1 views, %2 _e views to %3 tables'', NULL, @cnt, @ecnt, @mondb
DROP TABLE #views

-- these are additional, non-table views
--IF OBJECTPROPERTY(OBJECT_ID(''contact_link_servco_no''),''IsView'') = 1 DROP VIEW contact_link_servco_no
--SELECT @sql = ''CREATE VIEW dbo.contact_link_servco_no AS SELECT * FROM '' + @mondb + ''.dbo.contact_link_servco_no WITH (NOLOCK, INDEX(servco_no))''
--IF @debug = ''Y'' PRINT @sql
--EXEC(@sql)
--GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.contact_link_servco_no TO mas_user
--GRANT SELECT ON dbo.contact_link_servco_no TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''evhist_XPK''),''IsView'') = 1 DROP VIEW evhist_XPK
SELECT @sql = ''CREATE VIEW dbo.evhist_XPK AS SELECT * FROM '' + @mondb + ''.dbo.event_history WITH (NOLOCK, INDEX(XPKevent_history))''
IF @debug = ''Y'' PRINT @sql
EXEC(@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.evhist_XPK TO mas_user
GRANT SELECT ON dbo.evhist_XPK TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''evhist_alarminc_no''),''IsView'') = 1 DROP VIEW evhist_alarminc_no
SELECT @sql = ''CREATE VIEW dbo.evhist_alarminc_no AS SELECT * FROM '' + @mondb + ''.dbo.event_history WITH (NOLOCK, INDEX(alarminc_no))''
IF @debug = ''Y'' PRINT @sql
EXEC(@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.evhist_alarminc_no TO mas_user
GRANT SELECT ON dbo.evhist_alarminc_no TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''evhist_event_date''),''IsView'') = 1 DROP VIEW evhist_event_date
SELECT @sql = ''CREATE VIEW dbo.evhist_event_date AS SELECT * FROM '' + @mondb + ''.dbo.event_history WITH (NOLOCK, INDEX(event_date))''
IF @debug = ''Y'' PRINT @sql
EXEC(@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.evhist_event_date TO mas_user
GRANT SELECT ON dbo.evhist_event_date TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''evhist_seqno''),''IsView'') = 1 DROP VIEW evhist_seqno
SELECT @sql = ''CREATE VIEW dbo.evhist_seqno AS SELECT * FROM '' + @mondb + ''.dbo.event_history WITH (NOLOCK, INDEX(seqno))''
IF @debug = ''Y'' PRINT @sql
EXEC(@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.evhist_seqno TO mas_user
GRANT SELECT ON dbo.evhist_seqno TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''evhist_server_id''),''IsView'') = 1 DROP VIEW evhist_server_id
SELECT @sql = ''CREATE VIEW dbo.evhist_server_id AS SELECT * FROM '' + @mondb + ''.dbo.event_history WITH (NOLOCK, INDEX(server_id))''
IF @debug = ''Y'' PRINT @sql
EXEC(@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.evhist_server_id TO mas_user
GRANT SELECT ON dbo.evhist_server_id TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''evhist_system_seqno''),''IsView'') = 1 DROP VIEW evhist_system_seqno
SELECT @sql = ''CREATE VIEW dbo.evhist_system_seqno AS SELECT * FROM '' + @mondb + ''.dbo.event_history WITH (NOLOCK, INDEX(system_seqno))''
IF @debug = ''Y'' PRINT @sql
EXEC(@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.evhist_system_seqno TO mas_user
GRANT SELECT ON dbo.evhist_system_seqno TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''vehicle''),''IsView'') = 1 DROP VIEW vehicle
SELECT @sql = ''CREATE VIEW dbo.vehicle AS ''
                  + ''SELECT mobdev_no AS vehicle_no,descr,change_user,change_date,modem_id,emp_no,system_no,license,make,model,''
                  + ''model_year,longitude,latitude,speed,heading,lltv_date,accbit1,userbit1,userbit2,set_time,set_distance,''
                  + ''set_accessory_state,set_userbit1_state,set_userbit2_state,radio_coverage_state,date,color,icon,state_id,''
                  + ''vin,mobdev_id as vehicle_id,start_date,end_date,device_type,set_powersave,set_ps_delay,set_ps_wake,set_ps_move,''
                  + ''current_emp_no,patrol_flag,current_role_id,patrol_status,patrol_version,msg_seqno,recv_date,geo_point_no,''
                  + ''cell_phone,history_seqno,markings,command_list,radio_state,radio_state_date,check_in_minutes,dwnld_pending,''
                  + ''dwnld_data,dwnld_status,dwnld_status_date,device_version ''
                  + ''FROM '' + @mondb + ''.dbo.mobile_device''
IF @debug = ''Y'' PRINT @sql
EXEC (@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.vehicle TO mas_user
GRANT SELECT ON dbo.vehicle TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''vehicle_history''),''IsView'') = 1 DROP VIEW vehicle_history
SELECT @sql = ''CREATE VIEW dbo.vehicle_history AS ''
                  + ''SELECT mobdev_no AS vehicle_no,seqno,server_id,recv_date,utc_date,date,emp_no,longitude,latitude,speed,''
                  + ''heading,accbit1,userbit1,userbit2,comment,raw_message,gps_valid,radio_coverage_state,type,distance,''
                  + ''duration,address_site_no,addr1,city_name,state_id,zip_code,geo_point_no,event_seqno,alert_comment,activity_id ''
                  + ''FROM '' + @mondb + ''.dbo.mobile_device_history''
IF @debug = ''Y'' PRINT @sql
EXEC (@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.vehicle_history TO mas_user
GRANT SELECT ON dbo.vehicle_history TO external_user

IF OBJECTPROPERTY(OBJECT_ID(''web_prompts_edit_ctl''),''IsView'') = 1 DROP VIEW web_prompts_edit_ctl
SELECT @sql = ''CREATE VIEW dbo.web_prompts_edit_ctl AS ''
                  + ''SELECT p.context,p.colname,p.prompt,p.add_default,p.required,c.tag,c.attrib,c.lookup_type,c.use_query ''
                  + ''FROM '' + @mondb + ''.dbo.web_prompts AS p LEFT OUTER JOIN '' + @mondb + ''.dbo.web_edit_ctl AS c ON p.context=c.context AND p.colname=c.colname''
IF @debug = ''Y'' PRINT @sql
EXEC (@sql)
GRANT SELECT,REFERENCES,INSERT,UPDATE,DELETE ON dbo.web_prompts_edit_ctl TO mas_user
GRANT SELECT ON dbo.web_prompts_edit_ctl TO external_user

-- Vertex views should point to test Vertex server
IF OBJECTPROPERTY(OBJECT_ID(''locstate''),''IsView'') = 1 DROP VIEW locstate
SELECT @sql = ''CREATE VIEW dbo.locstate AS SELECT * FROM vertex.dbo.LocState''
IF @debug = ''Y'' PRINT @sql
EXEC (@sql)
GRANT SELECT ON dbo.locstate TO mas_user

IF OBJECTPROPERTY(OBJECT_ID(''loccounty''),''IsView'') = 1 DROP VIEW loccounty
SELECT @sql = ''CREATE VIEW dbo.loccounty AS SELECT * FROM vertex.dbo.LocCounty''
IF @debug = ''Y'' PRINT @sql
EXEC (@sql)
GRANT SELECT ON dbo.loccounty TO mas_user

IF OBJECTPROPERTY(OBJECT_ID(''loccity''),''IsView'') = 1 DROP VIEW loccity
SELECT @sql = ''CREATE VIEW dbo.loccity AS SELECT * FROM vertex.dbo.LocCity''
IF @debug = ''Y'' PRINT @sql
EXEC (@sql)
GRANT SELECT ON dbo.loccity TO mas_user

IF OBJECTPROPERTY(OBJECT_ID(''regprereturnstbl''),''IsView'') = 1 DROP VIEW regprereturnstbl
SELECT @sql = ''CREATE VIEW dbo.regprereturnstbl AS SELECT * FROM vertex.dbo.regprereturnstbl''
IF @debug = ''Y'' PRINT @sql
EXEC (@sql)
GRANT SELECT ON dbo.regprereturnstbl TO mas_user

EXEC dbo.sp__msg ''Created specialized views''

SELECT @msg = ''COMPLETED re-create monitoring views, elapsed '' + CONVERT(varchar,GETDATE() - @start_time,114)
EXEC dbo.sp__msg @msg
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Combined E Views]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Combined E Views', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go

/* $Header:   N:\pvcs32\VM\MASterMind\arc\NT\tab\Views\MASterMind Monitoring\combined_e_view.sqla   1.7   Sep 21 2007 17:12:44   lCushing  $ */
-- create _e views on non-_t tables for standard implementation without language translation

if exists( select name from sysobjects where name = ''action_e'' and type = ''V'') 
  drop view action_e
go
if exists( select name from sysobjects where name = ''action_status_e'' and type = ''V'') 
  drop view action_status_e
go
if exists( select name from sysobjects where name = ''action_type_e'' and type = ''V'') 
  drop view action_type_e
go
if exists( select name from sysobjects where name = ''alarm_priority_e'' and type = ''V'') 
  drop view alarm_priority_e
go
if exists( select name from sysobjects where name = ''authority_e'' and type = ''V'') 
  drop view authority_e
go
if exists( select name from sysobjects where name = ''call_disposition_e'' and type = ''V'') 
  drop view call_disposition_e
go
if exists( select name from sysobjects where name = ''contact_disposition_e'' and type = ''V'') 
  drop view contact_disposition_e
go
if exists( select name from sysobjects where name = ''contact_list_type_e'' and type = ''V'') 
  drop view contact_list_type_e
go
if exists( select name from sysobjects where name = ''contact_type_e'' and type = ''V'') 
  drop view contact_type_e
go
if exists( select name from sysobjects where name = ''daylight_savings_time_e'' and type = ''V'') 
  drop view daylight_savings_time_e
go
if exists( select name from sysobjects where name = ''event_e'' and type = ''V'') 
  drop view event_e
go
if exists( select name from sysobjects where name = ''event_report_code_e'' and type = ''V'') 
  drop view event_report_code_e
go
if exists( select name from sysobjects where name = ''global_dispatch_e'' and type = ''V'') 
  drop view global_dispatch_e
go
if exists( select name from sysobjects where name = ''holiday_e'' and type = ''V'') 
  drop view holiday_e
go
if exists( select name from sysobjects where name = ''job_cause_e'' and type = ''V'') 
  drop view job_cause_e
go
if exists( select name from sysobjects where name = ''job_class_e'' and type = ''V'') 
  drop view job_class_e
go
if exists( select name from sysobjects where name = ''job_request_e'' and type = ''V'') 
  drop view job_request_e
go
if exists( select name from sysobjects where name = ''job_type_e'' and type = ''V'') 
  drop view job_type_e
go
if exists( select name from sysobjects where name = ''oos_category_e'' and type = ''V'') 
  drop view oos_category_e
go
if exists( select name from sysobjects where name = ''problem_e'' and type = ''V'') 
  drop view problem_e
go
if exists( select name from sysobjects where name = ''process_option_e'' and type = ''V'') 
  drop view process_option_e
go
if exists( select name from sysobjects where name = ''relation_e'' and type = ''V'') 
  drop view relation_e
go
if exists( select name from sysobjects where name = ''resolution_e'' and type = ''V'') 
  drop view resolution_e
go
if exists( select name from sysobjects where name = ''service_plan_e'' and type = ''V'') 
  drop view service_plan_e
go
if exists( select name from sysobjects where name = ''site_status_e'' and type = ''V'') 
  drop view site_status_e
go
if exists( select name from sysobjects where name = ''site_type_e'' and type = ''V'') 
  drop view site_type_e
go
if exists( select name from sysobjects where name = ''test_category_e'' and type = ''V'') 
  drop view test_category_e
go
if exists( select name from sysobjects where name = ''time_zone_e'' and type = ''V'') 
  drop view time_zone_e
go
if exists( select name from sysobjects where name = ''udf_control_e'' and type = ''V'') 
  drop view udf_control_e
go
if exists( select name from sysobjects where name = ''udf_e'' and type = ''V'') 
  drop view udf_e
go
if exists( select name from sysobjects where name = ''udf_type_e'' and type = ''V'') 
  drop view udf_type_e
go
if exists( select name from sysobjects where name = ''zone_state_e'' and type = ''V'') 
  drop view zone_state_e
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view action_e as select * from ''+@mondb+''..action'')
exec (''create view action_status_e as select * from ''+@mondb+''..action_status'')
exec (''create view action_type_e as select * from ''+@mondb+''..action_type'')
exec (''create view alarm_priority_e as select * from ''+@mondb+''..alarm_priority'')
exec (''create view authority_e as select * from ''+@mondb+''..authority'')
exec (''create view call_disposition_e as select * from ''+@mondb+''..call_disposition'')
exec (''create view contact_disposition_e as select * from ''+@mondb+''..contact_disposition'')
exec (''create view contact_list_type_e as select * from ''+@mondb+''..contact_list_type'')
exec (''create view contact_type_e as select * from ''+@mondb+''..contact_type'')
exec (''create view daylight_savings_time_e as select * from ''+@mondb+''..daylight_savings_time'')
exec (''create view event_e as select * from ''+@mondb+''..event'')
exec (''create view event_report_code_e as select * from ''+@mondb+''..event_report_code'')
exec (''create view global_dispatch_e as select * from ''+@mondb+''..global_dispatch'')
exec (''create view holiday_e as select * from ''+@mondb+''..holiday'')
exec (''create view job_cause_e as select * from ''+@mondb+''..job_cause'')
exec (''create view job_class_e as select * from ''+@mondb+''..job_class'')
exec (''create view job_request_e as select * from ''+@mondb+''..job_request'')
exec (''create view job_type_e as select * from ''+@mondb+''..job_type'')
exec (''create view oos_category_e as select * from ''+@mondb+''..oos_category'')
exec (''create view problem_e as select * from ''+@mondb+''..problem'')
exec (''create view process_option_e as select * from ''+@mondb+''..process_option'')
exec (''create view relation_e as select * from ''+@mondb+''..relation'')
exec (''create view resolution_e as select * from ''+@mondb+''..resolution'')
exec (''create view service_plan_e as select * from ''+@mondb+''..service_plan'')
exec (''create view site_status_e as select * from ''+@mondb+''..site_status'')
exec (''create view site_type_e as select * from ''+@mondb+''..site_type'')
exec (''create view test_category_e as select * from ''+@mondb+''..test_category'')
exec (''create view udf_control_e as select * from ''+@mondb+''..udf_control'')
exec (''create view time_zone_e as select * from ''+@mondb+''..time_zone'')
exec (''create view udf_e as select * from ''+@mondb+''..udf'')
exec (''create view udf_type_e as select * from ''+@mondb+''..udf_type'')
exec (''create view zone_state_e as select * from ''+@mondb+''..zone_state'')
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on action_e to mas_user
go
grant select on action_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on action_status_e to mas_user
go
grant select on action_status_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on action_type_e to mas_user
go
grant select on action_type_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on alarm_priority_e to mas_user
go
grant select on alarm_priority_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on authority_e to mas_user
go
grant select on authority_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on call_disposition_e to mas_user
go
grant select on call_disposition_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on contact_disposition_e to mas_user
go
grant select on contact_disposition_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON contact_list_type_e TO mas_user
go
GRANT SELECT ON contact_list_type_e TO external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON contact_type_e TO mas_user
go
GRANT SELECT ON contact_type_e TO external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON daylight_savings_time_e TO mas_user
go
GRANT SELECT ON daylight_savings_time_e TO external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on event_e to mas_user
go
grant select on event_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON event_report_code_e TO mas_user
go
GRANT SELECT ON event_report_code_e TO external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on global_dispatch_e to mas_user
go
grant select on global_dispatch_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on holiday_e to mas_user
go
grant select on holiday_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on job_cause_e to mas_user
go
grant select on job_cause_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on job_class_e to mas_user
go
grant select on job_class_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on job_request_e to mas_user
go
grant select on job_request_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on job_type_e to mas_user
go
grant select on job_type_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on oos_category_e to mas_user
go
grant select on oos_category_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on problem_e to mas_user
go
grant select on problem_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on process_option_e to mas_user
go
grant select on process_option_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on relation_e to mas_user
go
grant select on relation_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on resolution_e to mas_user
go
grant select on resolution_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on service_plan_e to mas_user
go
grant select on service_plan_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on site_status_e to mas_user
go
grant select on site_status_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on site_type_e to mas_user
go
grant select on site_type_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on test_category_e to mas_user
go
grant select on test_category_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON time_zone_e TO mas_user
go
GRANT SELECT ON time_zone_e TO external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on udf_control_e to mas_user
go
grant select on udf_control_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on udf_e to mas_user
go
grant select on udf_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE on udf_type_e to mas_user
go
grant select on udf_type_e to external_user
go
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON zone_state_e TO mas_user
go
GRANT SELECT ON zone_state_e TO external_user
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [MMB Event Historory Views]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'MMB Event Historory Views', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go

/* $Header:   N:\pvcs32\VM\MASterMind\arc\NT\tab\Views\MASterMind Monitoring\mmb_evhist_views.sqla   1.0   Oct 31 2007 15:30:50   lCushing  $ */
if exists (select name from sysobjects where type = ''V'' and name = ''evhist_alarminc_no'')
  drop view evhist_alarminc_no
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view evhist_alarminc_no as select * from ''+@mondb+''.dbo.event_history with (nolock, index(alarminc_no))'')
go
grant delete, insert, references, select, update on evhist_alarminc_no to mas_user
go
grant select on evhist_alarminc_no to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''evhist_event_date'')
  drop view evhist_event_date
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view evhist_event_date as select * from ''+@mondb+''.dbo.event_history with (nolock, index(event_date))'')
go
grant delete, insert, references, select, update on evhist_event_date to mas_user
go
grant select on evhist_event_date to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''evhist_seqno'')
  drop view evhist_seqno
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view evhist_seqno as select * from ''+@mondb+''.dbo.event_history with (nolock index(seqno))'')
go
grant delete, insert, references, select, update on evhist_seqno to mas_user
go
grant select on evhist_seqno to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''evhist_server_id'')
  drop view evhist_server_id
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view evhist_server_id as select * from ''+@mondb+''.dbo.event_history with (nolock index(server_id))'')
go
grant delete, insert, references, select, update on evhist_server_id to mas_user
go
grant select on evhist_server_id to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''evhist_system_seqno'')
  drop view evhist_system_seqno
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view evhist_system_seqno as select * from ''+@mondb+''.dbo.event_history with (nolock index(system_seqno))'')
go
grant delete, insert, references, select, update on evhist_system_seqno to mas_user
go
grant select on evhist_system_seqno to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''evhist_XPK'')
  drop view evhist_XPK
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view evhist_XPK as select * from ''+@mondb+''.dbo.event_history with (nolock index(XPKevent_history))'')
go
grant delete, insert, references, select, update on evhist_XPK to mas_user
go
grant select on evhist_XPK to external_user
go

/*
create view event_history as select * from event_history
*/
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [MobileMind Views]    Script Date: 11/30/2020 4:56:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'MobileMind Views', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
use mi_masdb

go

/* $Header:   N:\pvcs32\VM\MASterMind\arc\NT\tab\Views\mobileminnd_views.sqla   1.3   May 03 2007 10:26:20   lCushing  $ */

drop view dbo.system_test_mm
go

declare @mondb varchar(255),
	@hint varchar(255),
	@business_and_monitoring varchar(255),
	@table_name varchar(255)


select @business_and_monitoring = option_value
from system_option
where option_id = ''business_and_monitoring''
if @@rowcount = 0 or rtrim(@business_and_monitoring) not in (''Y'',''N'')
  select @business_and_monitoring = ''N''

select @mondb = option_value 
from system_option with (nolock) where option_id = ''monitoring_database''

if @business_and_monitoring = ''Y'' 
Begin
	set @hint = ''''
	set @mondb = @mondb+''.''
	set @table_name = ''dbo.system_test ''
	if (select count(*) from sysobjects where name = ''red_control'' and type = ''U'') > 0
	Begin
		set @hint = ''with (nolock, index(expire_date))''
		set @mondb = ''''
		set @table_name = ''dbo.system_test ''
	end
end
else
Begin
	set @hint = ''with (nolock, index(system_date))''
	set @mondb = ''''
	set @table_name = ''dbo.system_test ''
End

exec (''create view dbo.system_test_mm as select * from ''+@mondb+@table_name+@hint)
go

grant select,insert,update,delete on dbo.system_test_mm to mas_user
go
grant select on dbo.system_test_mm to external_user
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitoring Archive Views]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitoring Archive Views', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go

/* $Header:   N:\pvcs32\VM\MASterMind\arc\NT\tab\Views\MASterMind Monitoring\monitoring_archive_views.sqla   1.4   Jun 11 2010 15:20:56   lCushing  $ */

/* remove unused views */
if exists (select name from sysobjects where type = ''V'' and name = ''call_list_archive_change'')
  drop view dbo.call_list_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''contact_archive_change'')
  drop view dbo.contact_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''contact_link_archive_change'')
  drop view dbo.contact_link_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''contact_list_archive_change'')
  drop view dbo.contact_list_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''contact_phone_archive_change'')
  drop view dbo.contact_phone_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''mail_address_archive_change'')
  drop view dbo.mail_address_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''holiday_schedule_archive_change'')
  drop view dbo.holiday_schedule_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''permit_dispatch_status_archive_change'')
  drop view dbo.permit_dispatch_status_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_archive_change'')
  drop view dbo.site_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_agency_archive_change'')
  drop view dbo.site_agency_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_dispatch_archive_change'')
  drop view dbo.site_dispatch_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_general_dispatch_archive_change'')
  drop view dbo.site_general_dispatch_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_note_archive_change'')
  drop view dbo.site_note_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_option_archive_change'')
  drop view dbo.site_option_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_permit_archive_change'')
  drop view dbo.site_permit_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''site_system_option_archive_change'')
  drop view dbo.site_system_option_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''system_archive_change'')
  drop view dbo.system_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''system_schedule_archive_change'')
  drop view dbo.system_schedule_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''system_user_id_archive_change'')
  drop view dbo.system_user_id_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''system_alarm_group_archive_change'')
  drop view dbo.system_alarm_group_archive_change
if exists (select name from sysobjects where type = ''V'' and name = ''zone_archive_change'')
  drop view dbo.zone_archive_change

/* Data Change Summary */
if exists (select name from sysobjects where type = ''V'' and name = ''data_change_summary_site'')
  drop view dbo.data_change_summary_site
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.data_change_summary_site
as
select * from ''+@mondb+''.dbo.data_change_summary with (nolock,index(site_no))''
exec (@s)
go
grant select on dbo.data_change_summary_site to mas_user
go
grant select on dbo.data_change_summary_site to external_user
go

/* Call List Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''call_list_archive_changeno'')
  drop view dbo.call_list_archive_changeno
go
declare @mondb varchar(255)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
exec (''create view dbo.call_list_archive_changeno as select * from ''+@mondb+''.dbo.call_list_archive with (nolock index(change_no))'')
go
grant delete, insert, references, select, update on dbo.call_list_archive_changeno to mas_user
go
grant select on dbo.call_list_archive_changeno to external_user
go

/* Contact Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''contact_archive_changeno'')
  drop view dbo.contact_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.contact_archive_changeno
as
select * from ''+@mondb+''.dbo.contact_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.contact_archive_changeno to mas_user
go
grant select on dbo.contact_archive_changeno to external_user
go

/* Contact Link Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''contact_link_archive_changeno'')
  drop view dbo.contact_link_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.contact_link_archive_changeno
as
select * from ''+@mondb+''.dbo.contact_link_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.contact_link_archive_changeno to mas_user
go
grant select on dbo.contact_link_archive_changeno to external_user
go

/* Contact List Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''contact_list_archive_changeno'')
  drop view dbo.contact_list_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.contact_list_archive_changeno
as
select * from ''+@mondb+''.dbo.contact_list_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.contact_list_archive_changeno to mas_user
go
grant select on dbo.contact_list_archive_changeno to external_user
go

/* Contact Phone Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''contact_phone_archive_changeno'')
  drop view dbo.contact_phone_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.contact_phone_archive_changeno
as
select * from ''+@mondb+''.dbo.contact_phone_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.contact_phone_archive_changeno to mas_user
go
grant select on dbo.contact_phone_archive_changeno to external_user
go

/* Mail Address Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''mail_address_archive_changeno'')
  drop view dbo.mail_address_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.mail_address_archive_changeno
as
select * from ''+@mondb+''.dbo.mail_address_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.mail_address_archive_changeno to mas_user
go
grant select on dbo.mail_address_archive_changeno to external_user
go

/* Holiday Schedule Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''holiday_schedule_archive_changeno'')
  drop view dbo.holiday_schedule_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.holiday_schedule_archive_changeno
as
select * from ''+@mondb+''.dbo.holiday_schedule_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.holiday_schedule_archive_changeno to mas_user
go
grant select on dbo.holiday_schedule_archive_changeno to external_user
go

/* Permit Dispatch Status Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''permit_dispatch_status_archive_changeno'')
  drop view dbo.permit_dispatch_status_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.permit_dispatch_status_archive_changeno
as
select * from ''+@mondb+''.dbo.permit_dispatch_status_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.permit_dispatch_status_archive_changeno to mas_user
go
grant select on dbo.permit_dispatch_status_archive_changeno to external_user
go

/* Site Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_archive_changeno'')
  drop view dbo.site_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_archive_changeno
as
select * from ''+@mondb+''.dbo.site_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_archive_changeno to mas_user
go
grant select on dbo.site_archive_changeno to external_user
go

/* Site Agency Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_agency_archive_changeno'')
  drop view dbo.site_agency_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_agency_archive_changeno
as
select * from ''+@mondb+''.dbo.site_agency_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_agency_archive_changeno to mas_user
go
grant select on dbo.site_agency_archive_changeno to external_user
go

/* Site Dispatch Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_dispatch_archive_changeno'')
  drop view dbo.site_dispatch_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_dispatch_archive_changeno
as
select * from ''+@mondb+''.dbo.site_dispatch_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_dispatch_archive_changeno to mas_user
go
grant select on dbo.site_dispatch_archive_changeno to external_user
go

/* Site General Dispatch Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_general_dispatch_archive_changeno'')
  drop view dbo.site_general_dispatch_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_general_dispatch_archive_changeno
as
select * from ''+@mondb+''.dbo.site_general_dispatch_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_general_dispatch_archive_changeno to mas_user
go
grant select on dbo.site_general_dispatch_archive_changeno to external_user
go

/* Site Note Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_note_archive_changeno'')
  drop view dbo.site_note_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_note_archive_changeno
as
select * from ''+@mondb+''.dbo.site_note_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_note_archive_changeno to mas_user
go
grant select on dbo.site_note_archive_changeno to external_user
go

/* Site Option Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_option_archive_changeno'')
  drop view dbo.site_option_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_option_archive_changeno
as
select * from ''+@mondb+''.dbo.site_option_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_option_archive_changeno to mas_user
go
grant select on dbo.site_option_archive_changeno to external_user
go

/* Site Permit Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_permit_archive_changeno'')
  drop view dbo.site_permit_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_permit_archive_changeno
as
select * from ''+@mondb+''.dbo.site_permit_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_permit_archive_changeno to mas_user
go
grant select on dbo.site_permit_archive_changeno to external_user
go

/* Site System Option Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''site_system_option_archive_changeno'')
  drop view dbo.site_system_option_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_system_option_archive_changeno
as
select * from ''+@mondb+''.dbo.site_system_option_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.site_system_option_archive_changeno to mas_user
go
grant select on dbo.site_system_option_archive_changeno to external_user
go

/* System Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''system_archive_changeno'')
  drop view dbo.system_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.system_archive_changeno
as
select * from ''+@mondb+''.dbo.system_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.system_archive_changeno to mas_user
go
grant select on dbo.system_archive_changeno to external_user
go

/* System Schedule Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''system_schedule_archive_changeno'')
  drop view dbo.system_schedule_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.system_schedule_archive_changeno
as
select * from ''+@mondb+''.dbo.system_schedule_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.system_schedule_archive_changeno to mas_user
go
grant select on dbo.system_schedule_archive_changeno to external_user
go

/* System User ID Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''system_user_id_archive_changeno'')
  drop view dbo.system_user_id_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.system_user_id_archive_changeno
as
select * from ''+@mondb+''.dbo.system_user_id_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.system_user_id_archive_changeno to mas_user
go
grant select on dbo.system_user_id_archive_changeno to external_user
go

/* System Alarm Group Archive */
if exists (select name from sysobjects where type = ''V'' and name = ''system_alarm_group_archive_changeno'')
  drop view dbo.system_alarm_group_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.system_alarm_group_archive_changeno
as
select * from ''+@mondb+''.dbo.system_alarm_group_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.system_alarm_group_archive_changeno to mas_user
go
grant select on dbo.system_alarm_group_archive_changeno to external_user
go

/* Zone Archive  */
if exists (select name from sysobjects where type = ''V'' and name = ''zone_archive_changeno'')
  drop view dbo.zone_archive_changeno
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.zone_archive_changeno
as
select * from ''+@mondb+''.dbo.zone_archive with (nolock,index(change_no))''
exec (@s)
go
grant select on dbo.zone_archive_changeno to mas_user
go
grant select on dbo.zone_archive_changeno to external_user
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitoring Views]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitoring Views', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go

/* $Header:   N:\pvcs32\VM\MASterMind\arc\NT\tab\Views\MASterMind Monitoring\monitoring_views.sqla   1.4   Sep 02 2010 18:39:28   lCushing  $ */

/* contact_pk */
if exists (select name from sysobjects where type = ''V'' and name = ''contact_pk'')
  drop view dbo.contact_pk
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_pk as select * from ''+@mondb+''.dbo.contact with (nolock index(xpkcontact))''
	BEGIN TRY
		select @table = ''contact_pk'', @seq = 1, @com = ''Rebuilding contact_pk view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects where type = ''V'' and name = ''contact_pk'')
begin
	grant select on dbo.contact_pk to mas_user
	grant select on dbo.contact_pk to external_user
end
go

/* contact_phone_ph */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_phone_ph'')
	drop view dbo.contact_phone_ph
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_phone_ph
	as
	select * from ''+@mondb+''.dbo.contact_phone with (nolock index(phone)) ''
	BEGIN TRY
		select @table = ''contact_phone_ph'', @seq = 1, @com = ''Rebuilding contact_phone_ph view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.contact_phone_ph'')
begin
	grant select on dbo.contact_phone_ph to mas_user
	grant select on dbo.contact_phone_ph to external_user
end
go

/* data_change_summary_incident */
if exists (select name from sysobjects where type = ''V'' and name = ''data_change_summary_incident'')
	drop view dbo.data_change_summary_incident
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.data_change_summary_incident as select * from ''+@mondb+''.dbo.data_change_summary with (nolock, index(incident_no))''
BEGIN TRY
	select @table = ''data_change_summary_incident'', @seq = 1, @com = ''Rebuilding data_change_summary_incident view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects where type = ''V'' and name = ''data_change_summary_incident'')
begin
	grant delete, insert, references, select, update on dbo.data_change_summary_incident to mas_user
	grant select on dbo.data_change_summary_incident to external_user
end
go

/* data_change_summary_site */
if exists (select name from sysobjects where type = ''V'' and name = ''data_change_summary_site'')
	drop view dbo.data_change_summary_site
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.data_change_summary_site as select * from ''+@mondb+''.dbo.data_change_summary with (nolock, index(site_no))''
BEGIN TRY
	select @table = ''data_change_summary_site'', @seq = 1, @com = ''Rebuilding data_change_summary_site view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects where type = ''V'' and name = ''data_change_summary_site'')
begin
	grant delete, insert, references, select, update on dbo.data_change_summary_site to mas_user
	grant select on dbo.data_change_summary_site to external_user
end
go

/* site_cost_center_tran_PK */
if exists (select name from sysobjects where type = ''V'' and name = ''site_cost_center_tran_PK'')
	drop view dbo.site_cost_center_tran_PK
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_cost_center_tran_PK as select * from ''+@mondb+''.dbo.site_cost_center_tran with (nolock, index(site_cost_center_tran_PK))''
BEGIN TRY
	select @table = ''site_cost_center_tran_PK'', @seq = 1, @com = ''Rebuilding site_cost_center_tran_PK view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects where type = ''V'' and name = ''site_cost_center_tran_PK'')
begin
	grant delete, insert, references, select, update on dbo.site_cost_center_tran_PK to mas_user
	grant select on dbo.site_cost_center_tran_PK to external_user
end
go

/* site_cost_center_tran_updated */
if exists (select name from sysobjects where type = ''V'' and name = ''site_cost_center_tran_updated'')
	drop view dbo.site_cost_center_tran_updated
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_cost_center_tran_updated as select * from ''+@mondb+''.dbo.site_cost_center_tran with (nolock, index(updated_flag))''
BEGIN TRY
	select @table = ''site_cost_center_tran_updated'', @seq = 1, @com = ''Rebuilding site_cost_center_tran_updated view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects where type = ''V'' and name = ''site_cost_center_tran_updated'')
begin
	grant delete, insert, references, select, update on dbo.site_cost_center_tran_updated to mas_user
	grant select on dbo.site_cost_center_tran_updated to external_user
end
go

/* system_site_no */
if exists (select name from sysobjects where type = ''V'' and name = ''system_site_no'')
	drop view dbo.system_site_no
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.system_site_no as select * from ''+@mondb+''.dbo.system with (nolock, index(site_no))''
BEGIN TRY
	select @table = ''system_site_no'', @seq = 1, @com = ''Rebuilding system_site_no view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects where type = ''V'' and name = ''system_site_no'')
begin
	grant select on dbo.system_site_no to mas_user
	grant select on dbo.system_site_no to external_user
end
go

/* zip_default_zipcode */
if exists (select name from sysobjects where type = ''V'' and name = ''zip_default_zipcode'')
	drop view dbo.zip_default_zipcode
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.zip_default_zipcode as select * from ''+@mondb+''.dbo.zip_default with (nolock, index(zipcode_zipdef))''
BEGIN TRY
	select @table = ''zip_default_zipcode'', @seq = 1, @com = ''Rebuilding zip_default_zipcode view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects where type = ''V'' and name = ''zip_default_zipcode'')
begin
	grant select on dbo.zip_default_zipcode to mas_user
	grant select on dbo.zip_default_zipcode to external_user
end
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Site Views]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Site Views', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go

/* $Header:   N:\pvcs32\VM\MASterMind\arc\NT\tab\Views\MASterMind Monitoring\site_views.sqla   1.2   Apr 05 2010 10:37:04   lCushing  $ */
/* Create views either on site or site_t table */

if exists (select name from sysobjects where type = ''V'' and name = ''site_pk'')
	drop view dbo.site_pk
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_pk as ''
if exists( select id from sysobjects where name = ''site_t'' and type = ''V'')
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site_t with (nolock,index(XPKsite))''
end
else
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site with (nolock,index(XPKsite))''
end
exec (@s)
go
grant select on dbo.site_pk to mas_user
go
grant select on dbo.site_pk to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''site_install'')
	drop view dbo.site_install
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_install as ''
if exists( select id from sysobjects where name = ''site_t'' and type = ''V'')
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site_t with (nolock,index(install_servco_no))''
end
else
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site with (nolock,index(install_servco_no))''
end
exec (@s)
go
grant select on dbo.site_install to mas_user
go
grant select on dbo.site_install to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''site_phone1'')
  drop view dbo.site_phone1
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_phone1 as ''
if exists( select id from sysobjects where name = ''site_t'' and type = ''V'')
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site_t with (nolock,index(phone1))''
end
else
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site with (nolock,index(phone1))''
end
exec (@s)
go
grant select on dbo.site_phone1 to mas_user
go
grant select on dbo.site_phone1 to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''site_phone2'')
  drop view dbo.site_phone2
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_phone2 as ''
if exists( select id from sysobjects where name = ''site_t'' and type = ''V'')
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site_t with (nolock,index(phone2))''
end
else
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site with (nolock,index(phone2))''
end
exec (@s)
go
grant select on dbo.site_phone2 to mas_user
go
grant select on dbo.site_phone2 to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''site_phone2'')
  drop view dbo.site_phone2
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_phone2 as ''
if exists( select id from sysobjects where name = ''site_t'' and type = ''V'')
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site_t with (nolock,index(phone2))''
end
else
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site with (nolock,index(phone2))''
end
exec (@s)
go
grant select on dbo.site_phone2 to mas_user
go
grant select on dbo.site_phone2 to external_user
go

if exists (select name from sysobjects where type = ''V'' and name = ''site_install_servco'')
  drop view dbo.site_install_servco
go
declare @mondb varchar(255), @s varchar(8000)
select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.site_install_servco as ''
if exists( select id from sysobjects where name = ''site_t'' and type = ''V'')
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site_t with (nolock,index(site_install_servco_no))''
end
else
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.site with (nolock,index(site_install_servco_no))''
end
exec (@s)
go
grant select on dbo.site_install_servco to mas_user
go
grant select on dbo.site_install_servco to external_user
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Special Views]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Special Views', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go

/* $Header:   N:\pvcs32\VM\MASterMind\arc\NT\tab\Views\MASterMind Monitoring\special_views.sqla   1.6   Nov 04 2010 14:01:46   lCushing  $ */

/* al_sec_window_id_sw */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''al_sec_window_id_sw'')
	drop view dbo.al_sec_window_id_sw
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @s = ''create view dbo.al_sec_window_id_sw as select * from dbo.al_sec_window_id where win_type=''''SW''''''
BEGIN TRY
	select @table = ''al_sec_window_id_sw'', @seq = 1, @com = ''Rebuilding al_sec_window_id_sw view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''al_sec_window_id_sw'')
begin
	grant DELETE, INSERT, REFERENCES, SELECT, UPDATE on dbo.al_sec_window_id_sw to mas_user
	grant select on dbo.al_sec_window_id_sw to external_user
end
go

/* Create views either on bill_code or bill_code_t table */
/* bill_code_pk */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''bill_code_pk'')
	drop view dbo.bill_code_pk
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @s = ''create view dbo.bill_code_pk as ''
if exists( select id from sysobjects with (nolock) where name = ''bill_code_t'' and type = ''U'')
begin
	select @s = @s + ''select * from dbo.bill_code_t with (nolock,index(XPKbill_code))''
end
else
begin
	select @s = @s + ''select * from dbo.bill_code with (nolock,index(XPKbill_code))''
end
BEGIN TRY
	select @table = ''bill_code_pk'', @seq = 1, @com = ''Rebuilding bill_code_pk view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.bill_code_pk'')
begin
	grant select on dbo.bill_code_pk to mas_user
	grant select on dbo.bill_code_pk to external_user
end
go

/* contact_link_pk */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_pk'')
	drop view dbo.contact_link_pk
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_link_pk as select * from ''+@mondb+''.dbo.contact_link with (nolock,index(XPKcontact_link))''
	BEGIN TRY
		select @table = ''contact_link_pk'', @seq = 1, @com = ''Rebuilding contact_link_pk view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_pk'')
begin
	grant delete, insert, references, select, update on dbo.contact_link_pk to mas_user
	grant select on dbo.contact_link_pk to external_user
end
go

/* contact_link_agency */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_agency'')
	drop view dbo.contact_link_agency
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_link_agency as select * from ''+@mondb+''.dbo.contact_link with (nolock,index(agency_no))''
	BEGIN TRY
		select @table = ''contact_link_agency'', @seq = 1, @com = ''Rebuilding contact_link_agency view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_agency'')
begin
	grant delete, insert, references, select, update on dbo.contact_link_agency to mas_user
	grant select on dbo.contact_link_agency to external_user
end
go

/* contact_link_contact */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_contact'')
	drop view dbo.contact_link_contact
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_link_contact as select * from ''+@mondb+''.dbo.contact_link with (nolock,index(contact_no))''
	BEGIN TRY
		select @table = ''contact_link_contact'', @seq = 1, @com = ''Rebuilding contact_link_contact view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.contact_link_contact'')
begin
	grant select on dbo.contact_link_contact to mas_user
	grant select on dbo.contact_link_contact to external_user
end
go

/* contact_link_cust */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_cust'')
	drop view dbo.contact_link_cust
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_link_cust as select * from ''+@mondb+''.dbo.contact_link with (nolock,index(cust_no))''
	BEGIN TRY
		select @table = ''contact_link_cust'', @seq = 1, @com = ''Rebuilding contact_link_cust view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.contact_link_cust'')
begin
	grant select on dbo.contact_link_cust to mas_user
	grant select on dbo.contact_link_cust to external_user
end
go

/* contact_link_prospect */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_prospect'')
	drop view dbo.contact_link_prospect
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_link_prospect as select * from ''+@mondb+''.dbo.contact_link with (nolock,index(prospect_no))''
	BEGIN TRY
		select @table = ''contact_link_prospect'', @seq = 1, @com = ''Rebuilding contact_link_prospect view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.contact_link_prospect'')
begin
	grant select on dbo.contact_link_prospect to mas_user
	grant select on dbo.contact_link_prospect to external_user
end
go

/* contact_link_servco */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_servco_no'')
	drop view dbo.contact_link_servco_no
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_servco'')
	drop view dbo.contact_link_servco
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_link_servco as select * from ''+@mondb+''.dbo.contact_link with (nolock,index(servco_no))''
	BEGIN TRY
		select @table = ''contact_link_servco'', @seq = 1, @com = ''Rebuilding contact_link_servco view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.contact_link_servco'')
begin
	grant select on dbo.contact_link_servco to mas_user
	grant select on dbo.contact_link_servco to external_user
end
go

/* contact_link_site */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contact_link_site'')
	drop view dbo.contact_link_site
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contact_link_site as select * from ''+@mondb+''.dbo.contact_link with (nolock,index(site_no))''
	BEGIN TRY
		select @table = ''contact_link_site'', @seq = 1, @com = ''Rebuilding contact_link_site view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.contact_link_site'')
begin
	grant select on dbo.contact_link_site to mas_user
	grant select on dbo.contact_link_site to external_user
end
go

/* Create views either on event or event_t table */
/* event_pk */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''event_pk'')
	drop view dbo.event_pk
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

select @mondb = option_value from system_option where option_id = ''monitoring_database''
select @s = ''create view dbo.event_pk as ''
if exists( select id from sysobjects with (nolock) where name = ''event_t'' and type = ''V'')
begin
	select @s = @s + ''select * from ''+@mondb+''.dbo.event_t with (nolock,index(XPKevent))''
end
else
begin
	if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
	begin
		select @s = @s + ''select * from ''+@mondb+''.dbo.event with (nolock,index(XPKevent))''
	end
	else
		select @s = @s + ''select * from dbo.event with (nolock,index(XPKevent))''
end
BEGIN TRY
	select @table = ''event_pk'', @seq = 1, @com = ''Rebuilding event_pk view...'', @err_msg = null, @retstat = 0
	Print ''''
	RAISERROR(@com,0,1) WITH NOWAIT
	EXEC (@s)
END TRY
BEGIN CATCH
	select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
		+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
	RAISERROR(@err_msg,0,1) WITH NOWAIT
	exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
		@table, @seq, @com, @err_msg
END CATCH
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.event_pk'')
begin
	grant select on dbo.event_pk to mas_user
	grant select on dbo.event_pk to external_user
end
go

/* service_co */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''service_co'')
	drop view dbo.service_co
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.service_co as select * from ''+@mondb+''.dbo.service_company where servco_type like ''''%S%''''''
	BEGIN TRY
		select @table = ''service_co'', @seq = 1, @com = ''Rebuilding service_co view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.service_co'')
begin
	grant DELETE, INSERT, REFERENCES, SELECT, UPDATE on dbo.service_co to mas_user
	grant select on dbo.service_co to external_user
end
go

/* install_co */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''install_co'')
	drop view dbo.install_co
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.install_co as select * from ''+@mondb+''.dbo.service_company where servco_type like ''''%I%''''''
	BEGIN TRY
		select @table = ''install_co'', @seq = 1, @com = ''Rebuilding install_co view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.install_co'')
begin
	grant DELETE, INSERT, REFERENCES, SELECT, UPDATE on dbo.install_co to mas_user
	grant select on dbo.install_co to external_user
end
go

/* corpacct_co */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''corpacct_co'')
	drop view corpacct_co
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.corpacct_co as select * from ''+@mondb+''.dbo.service_company where servco_type like ''''%C%''''''
	BEGIN TRY
		select @table = ''corpacct_co'', @seq = 1, @com = ''Rebuilding corpacct_co view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.corpacct_co'')
begin
	grant DELETE, INSERT, REFERENCES, SELECT, UPDATE on dbo.corpacct_co to mas_user
	grant select on corpacct_co to external_user
end
go

/* contractor_co */
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''contractor_co'')
	drop view contractor_co
go
declare @app varchar(30), @ver varchar(30), @build varchar(30), @server varchar(30), @db varchar(30),
 @table varchar(300), @seq int, @com varchar(100), @retstat int
select @app = ''MASterMind Business'', @ver = '' 6.26.02'', @build = ''02'', @server = @@servername, @db = db_name()
declare @err_msg nvarchar(4000), @mondb varchar(255), @s varchar(8000)

if ''Y'' = (select option_value from system_option where option_id = ''business_and_monitoring'')
begin
	select @mondb = option_value from system_option where option_id = ''monitoring_database''
	select @s = ''create view dbo.contractor_co as select * from ''+@mondb+''.dbo.service_company where servco_type like ''''%T%''''''
	BEGIN TRY
		select @table = ''contractor_co'', @seq = 1, @com = ''Rebuilding contractor_co view...'', @err_msg = null, @retstat = 0
		Print ''''
		RAISERROR(@com,0,1) WITH NOWAIT
		EXEC (@s)
	END TRY
	BEGIN CATCH
		select @err_msg = ''Error: '' + convert(nvarchar,ERROR_NUMBER()) + '' , Msg: '' +ERROR_MESSAGE() + '', at line ''+ convert(nvarchar,ERROR_LINE())
			+ '', Severity: '' + convert(nvarchar,ERROR_SEVERITY()) + '', State: '' + convert(nvarchar,ERROR_STATE())
		RAISERROR(@err_msg,0,1) WITH NOWAIT
		exec @retstat = dbo.ap_log_upgrade_progress @app, @ver, @build, @server, @db,
			@table, @seq, @com, @err_msg
	END CATCH
end
go
if exists (select name from sysobjects with (nolock) where type = ''V'' and name = ''dbo.contractor_co'')
begin
	grant DELETE, INSERT, REFERENCES, SELECT, UPDATE on dbo.contractor_co to mas_user
	grant select on dbo.contractor_co to external_user
end
go

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Correct Monitor Server]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Correct Monitor Server', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_mondb
go


-- $Header: $
-- delete and re-load monitor_server table

-- run in monitoring db
--select * from dbo.monitor_server
SET NOCOUNT ON

DECLARE @servername varchar(30), @server_id char(1), @active_flag char(1),
        @batch_flag char(1), @active_date datetime

DECLARE @servers table (
  servername varchar(30), server_id char(1), active_flag char(1), batch_flag char(1)
)

/* by default, just load the current server; if part of a replicated pair, uncomment
   the second server, add the servernames, and adjust the flags as desired 
   
   -- active_flag= MONITORING SERVER;  batch_flag= which server_id is the business server
   -- single server setup: flags are:  A, Y, Y
   -- multi-server setup:  
				Monitoring Server:  A, Y, B
				Business Server: B, N, Y
				All others:		 next letter (C), N, B
				
   
   */

 --for single server setup
INSERT INTO @servers (
    servername,server_id,active_flag,batch_flag)
VALUES (
    @@servername,''A'',''Y'',''Y'')
 
 
--for multi-server (triplet or more) setup
/*
INSERT INTO @servers (
    servername,server_id,active_flag,batch_flag)
VALUES (
    ''BUDDY'',''A'',''Y'',''B'')

INSERT INTO @servers (
    servername,server_id,active_flag,batch_flag)
VALUES (
    ''JOPLIN'',''B'',''N'',''Y'')  --NOTES:  BUDDY is considered ''A Server'', JOPLIN is B, RICKY is C, etc
 

--INSERT INTO @servers (
--	 servername,server_id,active_flag,batch_flag)
--VALUES (
--    ''RICKY'',''C'',''N'',''B'')
    
    
--INSERT INTO @servers (
--	 servername,server_id,active_flag,batch_flag)
--VALUES (
--    ''SPARKLES'',''D'',''N'',''B'')
*/   



DELETE monitor_server





DECLARE server_cur CURSOR FOR
 SELECT * FROM @servers ORDER BY server_id

OPEN server_cur
FETCH server_cur INTO @servername, @server_id, @active_flag, @batch_flag

WHILE (@@fetch_status = 0)
BEGIN
  IF @active_flag = ''Y''
    SELECT @active_date = GETDATE()
  ELSE
    SELECT @active_date = NULL

  IF ISNULL(@servername,'''') = ''''
    EXEC dbo.sp__msg ''ERROR: servername cannot be blank''
  ELSE IF EXISTS (SELECT 1 FROM monitor_server WHERE servername = @servername)
    EXEC dbo.sp__msg ''ERROR: servername %1 already exists'', NULL, @servername
  ELSE
  BEGIN
    INSERT INTO monitor_server (
        servername,server_id,active_flag,server_group_id,server_timzon_no,server_dst_no,batch_flag,active_date)
    VALUES (
        @servername, @server_id, @active_flag, 1, 6, 1, @batch_flag, @active_date)

    EXEC dbo.sp__msg ''Inserted monitor_server row for %1 (%2)'', NULL, @servername, @server_id
  END

  FETCH server_cur INTO @servername, @server_id, @active_flag, @batch_flag
END
CLOSE server_cur
DEALLOCATE server_cur
go


SELECT * FROM dbo.monitor_server', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Correct Output Directories]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Correct Output Directories', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb

go

-- $Id: 005a_Correct_OutputDirs.sql,v 1.1 2012-03-13 20:02:38 vrice Exp $
-- fix the form output directories and the qspid system option to point to the appropriate test directories
--  run in Business Database

SET NOCOUNT ON
DELETE dbo.process_info WHERE spid = @@spid

DECLARE @srvalch01 varchar(60) = ''\\srvalch01\TestOut\'' + LOWER(@@servername) + ''\'' + master.dbo.fn__token(DB_NAME(),1,''_''),
        @lanthanum varchar(60) = ''\\lanthanum\pap$\TestingResults''


EXEC dbo.sp__msg ''New \\srvalch01 output directory is %1'', @f1=@srvalch01
EXEC dbo.sp__msg ''New \\lanthanum output directory is %1'', @f1=@lanthanum

UPDATE form
   SET output_directory = REPLACE(output_directory,''\\srvalch01\MASout'',@srvalch01)
 WHERE output_directory LIKE ''%\\srvalch01\MASout%''
EXEC dbo.sp__msg ''Updated %1 \\srvalch01\MASout forms with new output directory'', @f1=@@rowcount

UPDATE system_option
   SET option_value = REPLACE(option_value,''\\srvalch01\MASout'',@srvalch01)
 WHERE option_id = ''qspid_path'' AND option_value LIKE ''%\\srvalch01\MASout%''
IF @@rowcount > 0
  EXEC dbo.sp__msg ''Updated qspid_path system_option with new TestOut output directory''
ELSE
  EXEC dbo.sp__msg ''WARNING: did not update qspid_path with new output directory''

UPDATE dbo.form
   SET output_directory = @lanthanum
 WHERE output_directory = ''\\lanthanum\pap$''
EXEC dbo.sp__msg ''Updated %1 \\lanthanum forms with new output directory'', @f1=@@rowcount
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Correct Queues]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Correct Queues', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb
go

-- $Id: 005b_Correct_Queues.sql,v 1.1 2012-03-13 19:48:18 vrice Exp $
-- reset the queues
-- Run in the Business DB

SET NOCOUNT ON
DELETE dbo.process_info WHERE spid = @@spid

DECLARE @aserver varchar(30),
        @bserver varchar(30),
        @cserver varchar(30)

SELECT @aserver = servername FROM dbo.monitor_server WHERE server_id = ''A''
SELECT @bserver = servername FROM dbo.monitor_server WHERE server_id = ''B''
SELECT @cserver = servername FROM dbo.monitor_server WHERE server_id = ''C''

IF @aserver IS NOT NULL
BEGIN
  UPDATE al_queue_master
     SET servername = @aserver
   WHERE queue_id = ''busrepa''

  UPDATE al_queue_master
     SET servername = @aserver,
         accepting = ''Y'',
         hostprocess = NULL,
         spid = NULL
   WHERE queue_id = ''q_masdb''
END
ELSE
BEGIN
  EXEC dbo.sp__msg ''ERROR: no A server in monitor_server''
  RETURN
END

IF @bserver IS NOT NULL
BEGIN
  UPDATE al_queue_master
     SET servername = @bserver
   WHERE queue_id = ''busrepb''

  UPDATE al_queue_master
     SET servername = @bserver,
         accepting = ''Y'',
         hostprocess = NULL,
         spid = NULL
   WHERE queue_id = ''q_masd''
END
-- these aren''t needed if no B server
ELSE
  DELETE al_queue_master WHERE queue_id IN (''busrepc'',''q_masd'')

IF @cserver IS NOT NULL
  UPDATE al_queue_master SET servername = @bserver WHERE queue_id = ''busrepc''
-- these aren''t needed if no C server
ELSE
  DELETE al_queue_master WHERE queue_id = ''busrepc''

-- these aren''t used on any test servers
DELETE al_queue_master WHERE queue_id IN (''busrepf'',''busrepg'',''q_masb'',''q_masa'',''q_stmtd'')
go

DELETE al_queue_master WHERE servername IN (''CYCLONE'')
go

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Correct Vertex]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Correct Vertex', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb
go

-- $Header: $
-- delete and re-load vertex_server_task table
-- run in Business Database
-- SELECT * FROM dbo.vertex_server_task (NOLOCK)

DELETE vertex_server_task

-- the A server uses tasks 3/4
INSERT INTO vertex_server_task (
    task_no,vertex_server_name,vertex_db_name,batch_int_flag,accepting_flag,
    show_window_flag,debug_flag,start_date,max_retries,change_user,change_date,
    server_id)
VALUES (
    3,@@SERVERNAME,''vertex'',''I'',''Y'',
    ''Y'',''N'',GETDATE(),3,1,GETDATE(),
    ''A'')
INSERT INTO vertex_server_task (
    task_no,vertex_server_name,vertex_db_name,batch_int_flag,accepting_flag,
    show_window_flag,debug_flag,start_date,max_retries,change_user,change_date,
    server_id)
VALUES (
    4,@@SERVERNAME,''vertex'',''B'',''Y'',
    ''Y'',''N'',GETDATE(),3,1,GETDATE(),
    ''A'')

-- uncomment out this section if the restore is part of a replicated pair
-- the B server uses tasks 1/2
--/*
INSERT INTO vertex_server_task (
    task_no,vertex_server_name,vertex_db_name,batch_int_flag,accepting_flag,
    show_window_flag,debug_flag,start_date,max_retries,change_user,change_date,
    server_id)
VALUES (
    1,@@SERVERNAME,''vertex'',''I'',''Y'',
    ''Y'',''N'',GETDATE(),3,1,GETDATE(),
    ''B'')
INSERT INTO vertex_server_task (
    task_no,vertex_server_name,vertex_db_name,batch_int_flag,accepting_flag,
    show_window_flag,debug_flag,start_date,max_retries,change_user,change_date,
    server_id)
VALUES (
    2,@@SERVERNAME,''vertex'',''B'',''Y'',
    ''Y'',''N'',GETDATE(),3,1,GETDATE(),
    ''B'')
--*/
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Correct App Tasks]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Correct App Tasks', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--			 REPLICATION TASK ENABLING
--			 NOTE!!!  Be sure to change the @mondb value in each script!!!

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--This will disable all tasks in both masdb/mondb on both BUDDY/JOPLIN for a full replicated restore
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*
declare @mondb varchar(20)	    =	  ''mi_mondb''   --- CHANGE MONITOR DATABASE NAME!!!
declare @SQL varchar(500)

    select @SQL=
						  ''UPDATE BUDDY.''+@mondb+''.dbo.m_task_current_status
						  SET enable_flag = ''''N''''''
    print @SQL
    exec(@SQL)

select @SQL=null

    select @SQL=
						  ''UPDATE JOPLIN.''+@mondb+''.dbo.m_task_current_status
						  SET enable_flag = ''''N''''''
    print @SQL
    exec(@SQL)
   
 */  
   /*
select @SQL=null

    select @SQL=
						  ''UPDATE RICKY.''+@mondb+''.dbo.m_task_current_status
						  SET enable_flag = ''''N''''''
    print @SQL
    exec(@SQL)
 */


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--this will enable the appropriate tasks in both databases on both servers 
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*
declare @mondb2 varchar(20)	    =	  ''mi_mondb''   --- CHANGE MONITOR DATABASE NAME!!!
declare @SQL2 varchar(500)

    select @SQL2=
						  ''UPDATE BUDDY.''+@mondb2+''.dbo.m_task_current_status
						  SET enable_flag = ''''Y''''
						  WHERE task_no IN (101,102,109,901,914,915,916,917,932,933,952,953,970,990,999)''
    print @SQL2
    exec(@SQL2)

select @SQL2=null

    select @SQL2=
						  ''UPDATE JOPLIN.''+@mondb2+''.dbo.m_task_current_status
						  SET enable_flag = ''''Y''''
						  WHERE task_no IN (101,102,109,901,902,904,908,914,915,916,917,930,931,950,951,972,990)''
    print @SQL2
    exec(@SQL2)

*/
--select @SQL2=null

--    select @SQL2=
--						  ''UPDATE RICKY.''+@mondb2+''.dbo.m_task_current_status
--						  SET enable_flag = ''''Y''''
--						  WHERE task_no IN (101,102,109,901,902,904,908,914,915,916,917,930,931,932,933,950,951,952,953,972,990)''
--    print @SQL2
--    exec(@SQL2)
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [mi_ap_reset_account]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_ap_reset_account', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Execute against the business database
USE [mi_masdb]
GO

/****** Object:  StoredProcedure [dbo].[mi_ap_reset_account]    Script Date: 09/16/2013 23:30:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[mi_ap_reset_account]'') AND type in (N''P'', N''PC''))
DROP PROCEDURE [dbo].[mi_ap_reset_account]
GO

USE [mi_masdb]
GO

/****** Object:  StoredProcedure [dbo].[mi_ap_reset_account]    Script Date: 12/05/2011 14:46:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[mi_ap_reset_account]
  @cs_no varchar(20),
  @make_shell char(1) = ''Y'',
  @servco_no int = NULL,
  @sigfmt varchar(3) = ''CID'',
  @alpha_panics char(1) = ''N'',
  @debug tinyint = 0
AS
/*
  $Header: /Users/vrice/Documents/cvs/Clients/MI/ap/mi_ap_reset_account.sql,v 1.12 2011-08-17 20:04:28 vrice Exp $

  NAME
    mi_ap_reset_account   Procedure to delete all peripheral monitoring data for an account and optionally
                            put it back to "shell" state

  PARAMETERS
    @cs_no                CS# of account to be cleaned up
    @make_shell           optional (default=Y), Reset to shell status if Y, otherwise delete everything
    @servco_no            optional (default=NULL), Service company for shell if account doesn''t already exist
    @sigfmt               optional (default=CID), Signal format for signals (CID or SIA)

  REQUIRES

  EXAMPLES
    EXEC dbo.mi_ap_reset_account ''CS98765432''               -- resets account to shell status
    EXEC dbo.mi_ap_reset_account ''CS98765432'', ''N''          -- deletes account completely
    EXEC dbo.mi_ap_reset_account ''CS98765432'', ''Y'', 123456  -- create shell account if doesn''t already exist;
                                                            --   if it does, delete it and re-create from servco''s template

  AUTHOR
    Vince Rice, Solid Rock Systems (c) 2007,2008,2010,2011

  TODOS
*/

SET NOCOUNT ON

DECLARE @site_no int,
        @system_no int,
        @primary_cs_no varchar(20),
        @site_servco int,
        @sec_cs_no varchar(20),
        @sec_system_no int,
        @sec_site_no int,
        @shell_cs_no varchar(20),
        @shell_site_no int,
        @shell_system_no int,
        @delete_shell char(1),

        @list varchar(512),
        @next varchar(255),
        @zone char(6),
        @event char(6),
        @match varchar(20),
        @dt datetime,
        @rowcount int,
        @error int

IF @make_shell = ''N''
  SELECT @delete_shell = ''Y''

-- get site/system/servco information if account already exists
SELECT @system_no = sy.system_no, @site_no = s.site_no, @primary_cs_no = sy.primary_cs_no,
       @site_servco = s.servco_no
  FROM dbo.system sy LEFT JOIN dbo.site s ON sy.site_no = s.site_no
 WHERE cs_no = @cs_no

-- always pass in digital cs_no; if it''s primary, get secondary, if it''s secondary, get primary
IF @primary_cs_no IS NULL
  SELECT @sec_system_no = system_no, @sec_site_no = site_no FROM system WHERE primary_cs_no = @cs_no
ELSE
  SELECT @sec_system_no = system_no, @sec_site_no = site_no FROM system WHERE cs_no = @primary_cs_no

IF @site_no <> ISNULL(@sec_site_no,@site_no)
BEGIN
  EXEC dbo.sp__msg ''ERROR: primary site is not same as secondary site''
  GOTO end_procedure
END
ELSE IF @system_no IS NULL AND @servco_no IS NULL
BEGIN
  EXEC dbo.sp__msg ''WARNING: @servco parameter must be specified since system %1 does not exist'', @f1=@cs_no
  GOTO end_procedure
END
ELSE IF @system_no IS NOT NULL AND @site_no IS NULL
BEGIN
  EXEC dbo.sp__msg ''ERROR: system (%1) exists but site does not'', @f1=@system_no
  GOTO end_procedure
END

IF @debug > 0
  EXEC dbo.sp__msg ''CS#=%1, system=%2, site=%3, sec_system=%4'', @f1=@cs_no, @f2=@system_no, @f3=@site_no, @f4=@sec_system_no

IF @make_shell = ''Y''
BEGIN
  -- account exists ...
  IF @system_no IS NOT NULL
  BEGIN
    -- ... if it''s different than the site''s servco, delete and re-create the account
    IF @servco_no <> @site_servco
      SELECT @delete_shell = ''Y''
    -- ... and servco not specified, use the one on the site
    ELSE
      SELECT @servco_no = @site_servco
  END

  -- make sure servco is valid
  IF NOT EXISTS (SELECT 1 FROM service_company WHERE servco_no = @servco_no)
  BEGIN
    EXEC dbo.sp__msg ''ERROR: servco %1 does not exist'', @f1=@servco_no
    GOTO end_procedure
  END

  SELECT @shell_cs_no = CAST(@servco_no AS varchar)

  SELECT @shell_system_no = sy.system_no, @shell_site_no = sy.site_no
    FROM dbo.system sy
   WHERE sy.cs_no = @shell_cs_no

  SELECT @rowcount = @@rowcount

  IF @rowcount = 0
  BEGIN
    IF @debug > 0
      EXEC dbo.sp__msg ''Did not find servco shell, servco=%1, shell_cs=%2'', @f1=@servco_no, @f2=@shell_cs_no

    SELECT @shell_cs_no = cs_no, @shell_system_no = system_no, @shell_site_no = site_no
      FROM dbo.system
     WHERE cs_no = ''VDISHELL''

    IF @@rowcount = 0
      EXEC dbo.sp__msg ''WARNING: neither shell account %1 nor VDISHELL exist'', @f1=@servco_no
  END

  IF @debug > 0
    EXEC dbo.sp__msg ''Shell CS#=%1, system=%2, site=%3'', @f1=@shell_cs_no, @f2=@shell_system_no, @f3=@shell_site_no
END

IF @system_no IS NOT NULL
BEGIN
  -- system-related tables
  IF EXISTS (SELECT 1 FROM site_system_option WHERE system_no IN (@system_no,@sec_system_no))
    DELETE site_system_option WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_alarm_status WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_alarm_status WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_alarm_suppress WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_alarm_suppress WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_alarm_suppress_zone WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_alarm_suppress_zone WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_schedule WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_schedule WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_schedule_time WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_schedule_time WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_test WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_test WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_test_zone WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_test_zone WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM processing_rule WHERE system_no IN (@system_no,@sec_system_no))
    DELETE processing_rule WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM zone WHERE system_no IN (@system_no,@sec_system_no))
    DELETE zone WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_user_id WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_user_id WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM event_history WHERE system_no IN (@system_no,@sec_system_no))
    DELETE event_history WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM dealer_system_queue WHERE system_no IN (@system_no,@sec_system_no))
    DELETE dealer_system_queue WHERE system_no IN (@system_no,@sec_system_no)

  IF EXISTS (SELECT 1 FROM site_system_option_archive WHERE system_no IN (@system_no,@sec_system_no))
    DELETE site_system_option_archive WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_schedule_archive WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_schedule_archive WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_schedule_time_archive WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_schedule_time_archive WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM processing_rule_archive WHERE system_no IN (@system_no,@sec_system_no))
    DELETE processing_rule_archive WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM zone_archive WHERE system_no IN (@system_no,@sec_system_no))
    DELETE zone_archive WHERE system_no IN (@system_no,@sec_system_no)

  IF EXISTS (SELECT 1 FROM site_system_option_edit WHERE system_no IN (@system_no,@sec_system_no))
    DELETE site_system_option_edit WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_schedule_edit WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_schedule_edit WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_schedule_time_edit WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_schedule_time_edit WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM processing_rule_edit WHERE system_no IN (@system_no,@sec_system_no))
    DELETE processing_rule_edit WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM zone_edit WHERE system_no IN (@system_no,@sec_system_no))
    DELETE zone_edit WHERE system_no IN (@system_no,@sec_system_no)

  -- site-related tables
  IF @site_no IS NOT NULL
  BEGIN
    IF EXISTS (SELECT 1 FROM contact_phone cp INNER JOIN contact_link cl ON cp.contact_no = cl.contact_no WHERE cl.site_no = @site_no)
      DELETE contact_phone FROM contact_phone cp INNER JOIN contact_link cl ON cp.contact_no = cl.contact_no WHERE cl.site_no = @site_no
    IF EXISTS (SELECT 1 FROM contact ct INNER JOIN contact_link cl ON ct.contact_no = cl.contact_no WHERE cl.site_no = @site_no)
      DELETE contact FROM contact ct INNER JOIN contact_link cl ON ct.contact_no = cl.contact_no WHERE cl.site_no = @site_no
    IF EXISTS (SELECT 1 FROM contact_link WHERE site_no = @site_no)
      DELETE contact_link WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_agency WHERE site_no = @site_no)
      DELETE site_agency WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_dispatch WHERE site_no = @site_no)
      DELETE site_dispatch WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_general_dispatch WHERE site_no = @site_no)
      DELETE site_general_dispatch WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_note WHERE site_no = @site_no)
      DELETE site_note WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_option WHERE site_no = @site_no)
      DELETE site_option WHERE site_no = @site_no
    DELETE permit
      FROM permit p INNER JOIN site_permit sp ON sp.site_no = @site_no AND p.agency_no = sp.agency_no AND p.permit_no = sp.permit_no
     WHERE NOT EXISTS (SELECT 1 FROM site_permit sp WHERE p.agency_no = sp.agency_no AND p.permit_no = sp.permit_no AND sp.site_no <> @site_no)
    IF EXISTS (SELECT 1 FROM site_permit WHERE site_no = @site_no)
      DELETE site_permit WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM dealer_system_queue WHERE site_no = @site_no)
      DELETE dealer_system_queue WHERE site_no = @site_no

    IF EXISTS (SELECT 1 FROM contact_phone_archive cp INNER JOIN contact_link_archive cl ON cp.contact_no = cl.contact_no WHERE cl.site_no = @site_no)
      DELETE contact_phone_archive FROM contact_phone_archive cp INNER JOIN contact_link_archive cl ON cp.contact_no = cl.contact_no WHERE cl.site_no = @site_no
    IF EXISTS (SELECT 1 FROM contact_archive ct INNER JOIN contact_link_archive cl ON ct.contact_no = cl.contact_no WHERE cl.site_no = @site_no)
      DELETE contact_archive FROM contact_archive ct INNER JOIN contact_link_archive cl ON ct.contact_no = cl.contact_no WHERE cl.site_no = @site_no
    IF EXISTS (SELECT 1 FROM contact_link_archive WHERE site_no = @site_no)
      DELETE contact_link_archive WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_agency_archive WHERE site_no = @site_no)
      DELETE site_agency_archive WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_dispatch_archive WHERE site_no = @site_no)
      DELETE site_dispatch_archive WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_general_dispatch_archive WHERE site_no = @site_no)
      DELETE site_general_dispatch_archive WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_note_archive WHERE site_no = @site_no)
      DELETE site_note_archive WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_option_archive WHERE site_no = @site_no)
      DELETE site_option_archive WHERE site_no = @site_no
    DELETE permit_archive
      FROM permit_archive p INNER JOIN site_permit_archive sp ON sp.site_no = @site_no AND p.agency_no = sp.agency_no AND p.permit_no = sp.permit_no
     WHERE NOT EXISTS (SELECT 1 FROM site_permit_archive sp WHERE p.agency_no = sp.agency_no AND p.permit_no = sp.permit_no AND sp.site_no <> @site_no)
    IF EXISTS (SELECT 1 FROM site_permit_archive WHERE site_no = @site_no)
      DELETE site_permit_archive WHERE site_no = @site_no

    IF EXISTS (SELECT 1 FROM job_tran WHERE site_no = @site_no)
      DELETE job_tran WHERE site_no = @site_no

    IF EXISTS (SELECT 1 FROM contact_edit ct INNER JOIN contact_link_edit cl ON ct.contact_no = cl.contact_no WHERE cl.site_no = @site_no)
      DELETE contact_edit FROM contact_edit ct INNER JOIN contact_link_edit cl ON ct.contact_no = cl.contact_no WHERE cl.site_no = @site_no
    IF EXISTS (SELECT 1 FROM contact_phone_edit cp INNER JOIN contact_link_edit cl ON cp.contact_no = cl.contact_no WHERE cl.site_no = @site_no)
      DELETE contact_phone_edit FROM contact_phone_edit cp INNER JOIN contact_link_edit cl ON cp.contact_no = cl.contact_no WHERE cl.site_no = @site_no
    IF EXISTS (SELECT 1 FROM contact_link_edit WHERE site_no = @site_no)
      DELETE contact_link_edit WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_agency_edit WHERE site_no = @site_no)
      DELETE site_agency_edit WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_dispatch_edit WHERE site_no = @site_no)
      DELETE site_dispatch_edit WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_general_dispatch_edit WHERE site_no = @site_no)
      DELETE site_general_dispatch_edit WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_note_edit WHERE site_no = @site_no)
      DELETE site_note_edit WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_option_edit WHERE site_no = @site_no)
      DELETE site_option_edit WHERE site_no = @site_no
    DELETE permit_edit FROM permit_edit p INNER JOIN site_permit_edit sp ON p.agency_no = sp.agency_no AND p.permit_no = sp.permit_no
    IF EXISTS (SELECT 1 FROM site_permit_edit WHERE site_no = @site_no)
      DELETE site_permit_edit WHERE site_no = @site_no

    IF EXISTS (SELECT 1 FROM site_archive WHERE site_no = @site_no)
      DELETE site_archive WHERE site_no = @site_no
    IF EXISTS (SELECT 1 FROM site_edit WHERE site_no = @site_no)
      DELETE site_edit WHERE site_no = @site_no
  END

  IF EXISTS (SELECT 1 FROM system_edit WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_edit WHERE system_no IN (@system_no,@sec_system_no)
  IF EXISTS (SELECT 1 FROM system_archive WHERE system_no IN (@system_no,@sec_system_no))
    DELETE system_archive WHERE system_no IN (@system_no,@sec_system_no)

  IF EXISTS (SELECT 1 FROM system WHERE system_no = @sec_system_no)
    DELETE system WHERE system_no = @sec_system_no

  IF @delete_shell = ''Y''
  BEGIN
    -- save these for last in case of any troubles above
    DELETE site WHERE site_no = @site_no
    DELETE system WHERE system_no IN (@system_no,@sec_system_no)
    EXEC dbo.sp__msg ''Deleted all information for CS# %1'', @f1=@cs_no
  END
END

IF @make_shell = ''Y''
BEGIN
  IF @system_no IS NULL
  BEGIN
    EXEC dbo.ap_next_app_no ''system_no'', @system_no OUTPUT
    EXEC dbo.ap_next_app_no ''site_no'', @site_no OUTPUT

    IF @debug > 0
      EXEC dbo.sp__msg ''New system=%1, site=%2'', @f1=@system_no, @f2=@site_no
  END

  UPDATE s
     SET site_name = shell.site_name,
         sort_key = shell.sort_key,
         site_addr1 = shell.site_addr1,
         street_no = shell.street_no,
         street_name = shell.street_name,
         site_addr2 = shell.site_addr2,
         city_name = shell.city_name,
         county_name = shell.county_name,
         state_id = shell.state_id,
         zip_code = shell.zip_code,
         phone1 = shell.phone1,
         co_no = shell.co_no,
         branch_no = shell.branch_no,
         timezone_no = shell.timezone_no,
         dst_no = shell.dst_no,
         siteloc_id = shell.siteloc_id,
         servarea_id = shell.servarea_id,
         geocode_id = shell.geocode_id,
         taxauth_no = shell.taxauth_no,
         cross_street = shell.cross_street,
         codeword1 = shell.codeword1,
         sitetype_id = shell.sitetype_id,
         sitestat_id = shell.sitestat_id,
         cspart_no = shell.cspart_no,
         orig_install_date = shell.orig_install_date
    FROM dbo.site s INNER JOIN dbo.site shell ON s.site_no = @site_no AND shell.site_no = @shell_site_no

  SELECT @rowcount = @@rowcount

  IF @rowcount > 0 AND @debug > 0
    EXEC dbo.sp__msg ''Updated site %1 from shell %2'', @f1=@site_no, @f2=@shell_site_no
  ELSE IF @rowcount = 0
  BEGIN
    EXEC dbo.sp__msg ''Inserting new site %1 from shell %2'', @f1=@site_no, @f2=@shell_site_no

    INSERT INTO dbo.site (
        site_no,site_name,site_addr1,street_no,street_name,sort_key,co_no,branch_no,
        sitetype_id,sitestat_id,country_name,timezone_no,geocode_id,taxauth_no,geo_ovr_flag,
        local_flag,ext_warr_flag,owner_occupy_flag,change_date,change_user,change_type,
        change_no,site_addr2,city_name,state_id,zip_code,county_name,phone1,ext1,phone2,ext2,
        cross_street,servarea_id,dst_no,grdpart_no,servpart_no,cspart_no,sitebstat_id,aq_no,
        mktsrc_id,ulcode_id,compet_id,sales_emp_no,codeword1,codeword2,mapbook_id,map_page,
        map_coord,orig_install_date,lead_no,subdivision,owner_no,udf1,udf2,udf3,udf4,terr_id,
        sic_id,occ_id,phone1_rev,phone2_rev,prospect_no,corpacct_id,siteloc_id,
        install_servco_no,servco_no,corpacct_servco_no,key_no,service_comment,attention,
        recur_costctr_id,install_costctr_id,service_costctr_id,other_costctr_id,in_city_flag,
        route_id,position,patrol_servarea_id,patrol_servplan_id,zipdef_no,service_emp_no,
        longitude,latitude
        )
    SELECT
        @site_no,site_name,site_addr1,street_no,street_name,sort_key,co_no,branch_no,
        sitetype_id,sitestat_id,country_name,timezone_no,geocode_id,taxauth_no,geo_ovr_flag,
        local_flag,ext_warr_flag,owner_occupy_flag,change_date,change_user,change_type,
        change_no,site_addr2,city_name,state_id,zip_code,county_name,phone1,ext1,phone2,ext2,
        cross_street,servarea_id,dst_no,grdpart_no,servpart_no,cspart_no,sitebstat_id,aq_no,
        mktsrc_id,ulcode_id,compet_id,sales_emp_no,codeword1,codeword2,mapbook_id,map_page,
        map_coord,orig_install_date,lead_no,subdivision,owner_no,udf1,udf2,udf3,udf4,terr_id,
        sic_id,occ_id,phone1_rev,phone2_rev,prospect_no,corpacct_id,siteloc_id,
        install_servco_no,servco_no,corpacct_servco_no,key_no,service_comment,attention,
        recur_costctr_id,install_costctr_id,service_costctr_id,other_costctr_id,in_city_flag,
        route_id,position,patrol_servarea_id,patrol_servplan_id,zipdef_no,service_emp_no,
        longitude,latitude
      FROM dbo.site WHERE site_no = @shell_site_no

    SELECT @rowcount = @@rowcount

    IF @rowcount > 0
      EXEC dbo.sp__msg ''Inserted new site %1 from shell %2'', @f1=@site_no, @f2=@shell_site_no
    ELSE
      EXEC dbo.sp__msg ''Did not insert new shell site for some reason''
  END

  UPDATE sy
     SET site_no = @site_no,
         systype_id = shell.systype_id,
         primary_cs_no = shell.primary_cs_no,
         panel_location = shell.panel_location,
         panel_code = shell.panel_code,
         panel_phone = shell.panel_phone,
         receiver_phone = shell.receiver_phone,
         install_date = shell.install_date,
         ooscat_id = shell.ooscat_id,
         oos_start_date = shell.oos_start_date,
         twoway_device_id = shell.twoway_device_id,
         alkup_cs_no = shell.alkup_cs_no,
         blkup_cs_no = shell.blkup_cs_no
    FROM dbo.system sy INNER JOIN dbo.system shell ON sy.system_no = @system_no AND shell.system_no = @shell_system_no

  SELECT @rowcount = @@rowcount

  IF @rowcount > 0 AND @debug > 0
    EXEC dbo.sp__msg ''Updated system %1 from shell %2'', @f1=@system_no, @f2=@shell_system_no
  ELSE IF @rowcount = 0
  BEGIN
    EXEC dbo.sp__msg ''Inserting new system %1 from shell %2'', @f1=@system_no, @f2=@shell_system_no

    INSERT INTO dbo.system (
        system_no,site_no,systype_id,redundant_system_flag,change_user,change_date,
        change_type,change_no,cs_no,primary_cs_no,alt_id,vrt_no,ati_hours,ati_minutes,
        special,entry_delay_minutes,exit_delay_minutes,telco_lease_line,active_date,
        inactive_date,mailfreq_id,install_date,monsys_id,panel_phone,download_phone,
        receiver_phone,backup_phone,job_no,panel_location,tech_emp_no,descr,disptype_id,
        alternate_ati_hours,alternate_ati_minutes,ati_option,ati_late_event_id,ati_gldisp_id,
        ati_dispage_no,panel_id,reset_type_id,ooscat_id,oos_start_date,servplan_id,
        service_comment,po_reqd_for_service_flag,alarmconf_id,system_name,system_addr1,
        system_addr2,street_no,street_name,dispatch_comment,oos_zone_list,cs_account_type,
        site_cs_no,monitor_status,service_emp_no,po_number,po_expire_date,po_amt,costctr_id,
        facility_no,activation_billed_flag,panel_code,twoway_device_id,alkup_cs_no,
        blkup_cs_no,equiptype_id
        )
    SELECT
        @system_no,@site_no,systype_id,redundant_system_flag,change_user,change_date,
        change_type,change_no,@cs_no,primary_cs_no,alt_id,vrt_no,ati_hours,ati_minutes,
        special,entry_delay_minutes,exit_delay_minutes,telco_lease_line,active_date,
        inactive_date,mailfreq_id,install_date,monsys_id,panel_phone,download_phone,
        receiver_phone,backup_phone,job_no,panel_location,tech_emp_no,descr,disptype_id,
        alternate_ati_hours,alternate_ati_minutes,ati_option,ati_late_event_id,ati_gldisp_id,
        ati_dispage_no,panel_id,reset_type_id,ooscat_id,oos_start_date,servplan_id,
        service_comment,po_reqd_for_service_flag,alarmconf_id,system_name,system_addr1,
        system_addr2,street_no,street_name,dispatch_comment,oos_zone_list,cs_account_type,
        site_cs_no,monitor_status,service_emp_no,po_number,po_expire_date,po_amt,costctr_id,
        facility_no,activation_billed_flag,panel_code,twoway_device_id,alkup_cs_no,
        blkup_cs_no,equiptype_id
      FROM dbo.system
     WHERE system_no = @shell_system_no

    SELECT @rowcount = @@rowcount

    IF @rowcount > 0 AND @debug > 0
      EXEC dbo.sp__msg ''Inserted new system %1 from shell %2'', @f1=@system_no, @f2=@shell_system_no
    ELSE IF @rowcount = 0
      EXEC dbo.sp__msg ''Did not insert new shell system for some reason''
  END

  INSERT INTO processing_rule (
      system_no,zonestate_id,zone_id,event_id,redundant_signal_req_flag,change_user,
      change_date,comment,glsched_id,sched_no,gldisp_id,dispage_no,cs_page_no,cs_line_no,
      zone_to_restore,alt_cs_no,procopt_id
      )
  SELECT
      @system_no,zonestate_id,zone_id,event_id,redundant_signal_req_flag,change_user,
      change_date,comment,glsched_id,sched_no,gldisp_id,dispage_no,cs_page_no,cs_line_no,
      zone_to_restore,alt_cs_no,procopt_id
    FROM dbo.processing_rule
   WHERE system_no = @shell_system_no

  IF @debug > 0
    EXEC dbo.sp__msg ''Inserted %1 processing_rules'', @f1=@@rowcount

  INSERT INTO zone (
      system_no,zone_id,alarmgrp_no,equiploc_id,restore_reqd_flag,arm_disarm,
      alarm_state_flag,trouble_state_flag,bypass_state_flag,trip_count,change_user,
      change_date,comment,equiptype_id,status_change_date,camera_zone_id,default_flag,
      disable_flag,contact_no,camera_preset_no,dvr_system_no
      )
  SELECT
      @system_no,zone_id,alarmgrp_no,equiploc_id,restore_reqd_flag,arm_disarm,
      alarm_state_flag,trouble_state_flag,bypass_state_flag,trip_count,change_user,
      change_date,comment,equiptype_id,status_change_date,camera_zone_id,default_flag,
      disable_flag,contact_no,camera_preset_no,dvr_system_no
    FROM dbo.zone
   WHERE system_no = @shell_system_no

  IF @debug > 0
    EXEC dbo.sp__msg ''Inserted %1 zones'', @f1=@@rowcount

  INSERT INTO event_history (
      system_no,event_date,full_clear_flag,event_id,event_class,eventrpt_id,zone_id,
      user_id,user_name,emp_no,scheduled_date,comment,alarminc_no,test_seqno,alarm_delay,
      opactdisp_id,new_priority,area,phone,additional_info,server_id,equipment_time,aux1,
      aux2,aux3,zonestate_id,match,alarminc_call_seqno
      )
  SELECT
      @system_no,event_date,full_clear_flag,event_id,event_class,eventrpt_id,zone_id,
      user_id,user_name,emp_no,scheduled_date,comment,alarminc_no,test_seqno,alarm_delay,
      opactdisp_id,new_priority,area,phone,additional_info,server_id,equipment_time,aux1,
      aux2,aux3,zonestate_id,match,alarminc_call_seqno
    FROM event_history WHERE system_no = @shell_system_no

  IF @debug > 0
    EXEC dbo.sp__msg ''Inserted %1 event_historys'', @f1=@@rowcount

  IF @delete_shell = ''Y''
    EXEC dbo.sp__msg ''Re-created CS# %1 from shell account %2'', @f1=@cs_no, @f2=@shell_cs_no
  ELSE
    EXEC dbo.sp__msg ''Reset CS# %1 from shell account %2'', @f1=@cs_no, @f2=@shell_cs_no
END

end_procedure:

GO


GRANT EXECUTE ON mi_ap_reset_account TO mas_user', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [mi_cp_save_bad_address_Correction]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_cp_save_bad_address_Correction', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Execute against the business database

--Redirects the hardcoded references to SRVODS02 to BUDDY

USE [mi_masdb]
GO

/****** Object:  StoredProcedure [dbo].[mi_cp_save_bad_address]    Script Date: 01/20/2012 13:38:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[mi_cp_save_bad_address]'') AND type in (N''P'', N''PC''))
DROP PROCEDURE [dbo].[mi_cp_save_bad_address]
GO

USE [mi_masdb]
GO

/****** Object:  StoredProcedure [dbo].[mi_cp_save_bad_address]    Script Date: 01/20/2012 13:38:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[mi_cp_save_bad_address] (
	@cs_no varchar(20)
	,@address varchar(60)
	,@install_servco_no int = 0
	,@servco_no int = 0)
AS

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					-- mi_cp_save_bad_address --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* NOTES
	
Creator:		Mike Morris
Date Created:   10/17/2011
Modifications:
Server:			HURRICANE, BUDDY
Database(s):    mi_custom
Tables:			mi_AccuMail_Bad_Addresses

Needs:			cp_SSRS_Moni_Net_AccountDetail_SiteContact, cp_SSRS_Moni_Net_AccountDetail_SiteGenDisp, 
				cp_SSRS_Moni_Net_AccountDetail_SiteDisp, cp_SSRS_Moni_Net_AccountDetail_SystemInfo, 
				cp_SSRS_Moni_Net_AccountDetail_SiteAgency, mi_af_instructions_to_plain, apr_get_sched_time,
				apr_call_list_display
*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

IF (@cs_no is not null and @address is not null)
BEGIN
	IF exists (SELECT 1 FROM mi_custom.dbo.mi_AccuMail_Bad_Addresses where cs_no = @cs_no)
	BEGIN
		UPDATE	mi_custom.dbo.mi_AccuMail_Bad_Addresses
		SET		bad_address = @address
				,install_servco_no = @install_servco_no
				,servco_no = @servco_no
				,change_date = GETDATE()
		WHERE cs_no = @cs_no
	END
	ELSE
		INSERT INTO mi_custom.dbo.mi_AccuMail_Bad_Addresses 
		VALUES (@cs_no, @address, @install_servco_no, @servco_no, GETDATE())
END

GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [mi_ap_create_test_signals]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_ap_create_test_signals', 
		@step_id=25, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb
go

-- $Id: mi_ap_create_test_signals.sql,v 1.4 2013-06-04 20:48:35 vrice Exp $
IF OBJECT_ID(''dbo.mi_ap_create_test_signals'') IS NOT NULL
  DROP PROCEDURE dbo.mi_ap_create_test_signals
go

CREATE PROCEDURE dbo.mi_ap_create_test_signals
  @start_cs_no varchar(20) = NULL,
  @end_cs_no varchar(20) = NULL,
  @monitor_type varchar(30) = ''Digital'',
  @signal_format varchar(10) = ''CID'',
  @zonelist varchar(255) = ''001/1400,002/1400,003/1400'',
  @digital_ANI varchar(16) = ''9722437443'',
  @cell_provider varchar(10) = NULL,
  @debug tinyint = 0,
  @help tinyint = 0
AS
/*
  $Id: mi_ap_create_test_signals.sql,v 1.4 2013-06-04 20:48:35 vrice Exp $

  NAME
    mi_ap_create_test_signals     Create a set of valid test signals for a monitoring type

  DESCRIPTION

  PARAMETERS
    @start_cs_no                  Starting CS#
    @end_cs_no                    optional (default=@start_cs_no), Ending CS#; if NULL, use
                                    @start_cs_no, i.e. only operates on a single CS#
    @monitor_type                 optional (default=Digital), monitor type to create signals for
                                    *Twoway - one 2AC signal
                                    Digital - all signals created with digital ANI
                                    Cell Primary* - all signals created with cell ANI
                                    Cell Secondary* - signals created on all zones with
                                      digital ANI, one signal created on cell ANI
    @signal_format                optional (default=CID), used for match column only
    @zonelist                     optional (default=001-003), comma-delimited list of zones
                                    on which to create signals; on each zone is a slash-delimited
                                    event to put on the signal
    @digital_ANI                  optional (default=9722437443), digital ANI to put on signal
    @cell_provider                optional (default=NULL), if cell* monitoring type, abbreviation
                                    of cell provider (ALMCOM,ALMNET,TELULR,UPLINK)
    @debug                        optional (default=1), if > 0, display diagnostic messages
    @help                         optional (default=0), if 1, display PARAMETER help message

  RETURN
    int                           1 if any errors occurred, 0 otherwise

  REQUIRES
    event                         MM event table
    event_history                 MM event_history table
    system                        MM system table

    sp__fmtmsg                    System procedure to replace placeholders in a string with variables

  CALLED BY

  EXAMPLES
    -- creates default zones for a single CS#
    EXEC @retcode = dbo.mi_ap_create_test_signals @start_cs_no=''12345678''
    -- creates default zones for a range of CS#''s
    EXEC @retcode = dbo.mi_ap_create_test_signals @start_cs_no=''12345678'', @end_cs_no=''12345699''

  AUTHOR
    Vince Rice, Solid Rock Systems (c) 2011,2012,2013

  REVISION HISTORY (please do not put here, see TFS for complete list of changes)

  TODOS
*/

SET NOCOUNT ON

DECLARE @errmsg varchar(255),
        @bad_zones varchar(255),
        @bad_events varchar(255),
        @syscnt int,
        @zonecnt int = 0,
        @eventcnt int = 0,
        @event_phone varchar(16),
        @cell_ANI varchar(16),
        @server_id char(1),
        @addl_info varchar(30),
        @timer datetime = GETDATE(),
        @zone_id varchar(6),
        @event_id varchar(6),
        @parms varchar(8000)

DECLARE @zones table (
  zone_id varchar(20),
  zone_event varchar(6)
)


-- display internal parameter help (from comments above)
IF @help = 1
BEGIN
  SELECT @parms = SUBSTRING(t.text,
                            CHARINDEX(''PARAMETERS'', t.text),
                            CHARINDEX(''  RETURN''+CHAR(13), t.text) - (CHARINDEX(''PARAMETERS'', t.text))
                           )
    FROM sys.dm_exec_requests r
          CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
   WHERE r.session_id = @@spid

  EXEC dbo.sp__msg @parms, @msg_only=Y
  GOTO end_procedure
END

IF @start_cs_no IS NULL
  SELECT @errmsg = ''ERROR must specify starting CS#''
ELSE IF @end_cs_no IS NOT NULL AND @end_cs_no < @start_cs_no
  SELECT @errmsg = ''ERROR ending CS# must be greater than starting CS#''
ELSE IF @monitor_type NOT IN (''Digital'',''Digital Twoway'',
                            ''Cell Primary'',''Cell Primary Twoway'',
                            ''Cell Secondary'',''Cell Secondary Twoway'')
  SELECT @errmsg = ''ERROR invalid monitoring type''
ELSE IF @monitor_type LIKE ''Cell%'' AND @cell_provider IS NULL
  SELECT @errmsg = ''ERROR must specify cell provider for any cell monitoring type''
ELSE IF @cell_provider IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.mi_wsi_cell_provider
                                                    WHERE cell_provider = @cell_provider)
  SELECT @errmsg = ''ERROR invalid cell provider, not a valid WSI cell provider''
ELSE IF @digital_ANI IS NULL
  SELECT @errmsg = ''ERROR must specify digital ANI''
ELSE IF master.dbo.fn__valid_phone(@digital_ANI,10,10) > 0
  SELECT @errmsg = ''ERROR invalid digital ANI, not a valid phone number''
ELSE
BEGIN
  -- parse the zones
  INSERT INTO @zones (zone_id,zone_event)
  SELECT master.dbo.fn__token(token_str,1,''/''),
         master.dbo.fn__token(token_str,2,''/'')
    FROM master.dbo.fn__split(@zonelist,'','')

  SELECT @bad_zones = ISNULL(@bad_zones+'','','''') + zone_id
    FROM @zones
   WHERE LEN(zone_id) > 6

  SELECT @bad_events = ISNULL(@bad_events+'','','''') + zone_event
    FROM @zones z
   WHERE NOT EXISTS (SELECT 1 FROM dbo.event e WHERE e.event_id = z.zone_event)

  IF @bad_zones IS NOT NULL
    SELECT @errmsg = ''ERROR one or more zone_ids too long, zones='' + @bad_zones
  ELSE IF @bad_events IS NOT NULL
    SELECT @errmsg = ''ERROR one or more event_ids does not exist, event='' + @bad_events
END

IF @errmsg IS NOT NULL
BEGIN
  EXEC dbo.sp__msg @errmsg
  GOTO end_procedure
END

-- get the server ID
SELECT @server_id = server_id FROM dbo.monitor_server WHERE servername = @@servername

IF @server_id IS NULL
  SELECT @errmsg = ''ERROR could not find server in monitor_server, servername='' + @@servername
-- if cell specified, get a sample ANI
ELSE IF @cell_provider IS NOT NULL
BEGIN
  SELECT @cell_ANI = MIN(ani) FROM dbo.mi_wsi_cell_ani WHERE cell_provider = @cell_provider

  IF @cell_ANI IS NULL
    SELECT @errmsg = ''ERROR could not find cell ANI for provider '' + @cell_provider
END

IF @errmsg IS NOT NULL
BEGIN
  EXEC dbo.sp__msg @errmsg
  GOTO end_procedure
END

SELECT @end_cs_no = ISNULL(@end_cs_no,@start_cs_no)
SELECT @syscnt = COUNT(*) FROM dbo.system WHERE cs_no BETWEEN @start_cs_no AND @end_cs_no
IF @syscnt = 0
  EXEC dbo.sp__msg ''ERROR no systems exist in range, start=%1, end=%2'', @f1=@start_cs_no, @f2=@end_cs_no
ELSE IF @debug > 1
  EXEC dbo.sp__msg ''Creating %1 signals on %2 systems between CS# %3 and %4, zones/events %5'',
                   @f1=@monitor_type, @f2=@syscnt, @f3=@start_cs_no, @f4=@end_cs_no, @f5=@zonelist

-- create each signal with phone# of primary panel
IF @monitor_type LIKE ''Cell Primary%''
  SELECT @addl_info = ''OOS CallerID: ('' + LEFT(@cell_ANI,3) + '') ''
                            + SUBSTRING(@cell_ANI,4,3) + '' - ''
                            + RIGHT(@cell_ANI,4)
ELSE
  SELECT @addl_info = ''OOS CallerID: ('' + LEFT(@digital_ANI,3) + '') ''
                            + SUBSTRING(@digital_ANI,4,3) + '' - ''
                            + RIGHT(@digital_ANI,4)

DECLARE zone_cur CURSOR FOR
 SELECT LEFT(zone_id,6),LEFT(zone_event,6) FROM @zones ORDER BY zone_id

OPEN zone_cur
FETCH zone_cur INTO @zone_id, @event_id

WHILE (@@fetch_status = 0)
BEGIN
  SELECT @timer = GETDATE(), @zonecnt = 0

  -- create caller ID signal 5ms prior to event signal
  INSERT INTO dbo.event_history (
      system_no,event_date,full_clear_flag,
      event_id,event_class,eventrpt_id,zone_id,additional_info,server_id,zonestate_id,match,
      event_descr)
  SELECT sy.system_no,DATEADD(ms,-5,dbo.af_site_time(sy.site_no,@timer)),e.full_clear_flag,
         e.event_id,e.event_class,e.eventrpt_id,''CALLID'',@addl_info,@server_id,''A'',''4,SUR0,CALLID'',
         e.descr
    FROM dbo.system sy
            INNER JOIN dbo.event e ON e.event_id = ''SG039''
  WHERE sy.cs_no BETWEEN @start_cs_no AND @end_cs_no

  SELECT @zonecnt += @@rowcount

  -- create event signal
  INSERT INTO dbo.event_history (
      system_no,event_date,full_clear_flag,
      event_id,event_class,eventrpt_id,zone_id,area,additional_info,server_id,aux2,
      zonestate_id,match,event_descr)
  SELECT sy.system_no,dbo.af_site_time(sy.site_no,@timer),e.full_clear_flag,
         e.event_id,e.event_class,e.eventrpt_id,@zone_id,''1'',''OOS'',@server_id,e.procopt_id,
         ''A'',''4,SUR0,???'',e.descr
    FROM dbo.system sy
            INNER JOIN dbo.event e ON e.event_id = @event_id
  WHERE sy.cs_no BETWEEN @start_cs_no AND @end_cs_no

  SELECT @zonecnt += @@rowcount
  IF @debug > 1
    EXEC dbo.sp__msg ''Created %1 signals for zone %2, event %3'', @f1=@zonecnt, @f2=@zone_id, @f3=@event_id
  SELECT @eventcnt += @zonecnt

  -- wait for the system clock to advance
  WHILE @timer = GETDATE() CONTINUE

  FETCH zone_cur INTO @zone_id, @event_id
END
CLOSE zone_cur
DEALLOCATE zone_cur

-- if cell secondary, create a cell signal on the first zone
IF @monitor_type LIKE ''Cell Secondary%''
BEGIN
  SELECT @timer = GETDATE(), @zonecnt = 0
  SELECT @addl_info = ''OOS CallerID: ('' + LEFT(@cell_ANI,3) + '') ''
                            + SUBSTRING(@cell_ANI,4,3) + '' - ''
                            + RIGHT(@cell_ANI,4)

  -- get first zone
  SELECT @zone_id = MIN(zone_id) FROM @zones
  SELECT @event_id = zone_event FROm @zones WHERE zone_id = @zone_id

  -- create caller ID signal
  INSERT INTO dbo.event_history (
      system_no,event_date,full_clear_flag,
      event_id,event_class,eventrpt_id,zone_id,additional_info,server_id,zonestate_id,match,
      event_descr)
  SELECT sy.system_no,DATEADD(ms,-5,dbo.af_site_time(sy.site_no,@timer)),e.full_clear_flag,
         e.event_id,e.event_class,e.eventrpt_id,''CALLID'',@addl_info,@server_id,''A'',''4,SUR0,CALLID'',
         e.descr
    FROM dbo.system sy
            INNER JOIN dbo.event e ON e.event_id = ''SG039''
  WHERE sy.cs_no BETWEEN @start_cs_no AND @end_cs_no

  SELECT @zonecnt += @@rowcount

  -- create event signal
  INSERT INTO dbo.event_history (
      system_no,event_date,full_clear_flag,
      event_id,event_class,eventrpt_id,zone_id,area,additional_info,server_id,aux2,
      zonestate_id,match,event_descr)
  SELECT sy.system_no,dbo.af_site_time(sy.site_no,@timer),e.full_clear_flag,
         e.event_id,e.event_class,e.eventrpt_id,@zone_id,''1'',''OOS'',@server_id,e.procopt_id,
         ''A'',''4,SUR0,???'',e.descr
    FROM dbo.system sy
            INNER JOIN dbo.event e ON e.event_id = @event_id
  WHERE sy.cs_no BETWEEN @start_cs_no AND @end_cs_no

  SELECT @zonecnt += @@rowcount
  IF @debug > 1
    EXEC dbo.sp__msg ''Created %1 cell secondary signals for zone %2, event %3'',
                     @f1=@zonecnt, @f2=@zone_id, @f3=@event_id
  SELECT @eventcnt += @zonecnt
END

-- create twoway operator action signals last, to match WSI business rules
IF @monitor_type LIKE ''% TWOWAY''
BEGIN
  INSERT INTO dbo.event_history (
      system_no,event_date,full_clear_flag,
      event_id,event_class,eventrpt_id,user_name,emp_no,alarm_delay,new_priority,
      event_descr,employee_initials)
  SELECT sy.system_no,dbo.af_site_time(sy.site_no,@timer),e.full_clear_flag,
         e.event_id,e.event_class,e.eventrpt_id,''George Jetson'',1,e.alarm_delay,e.priority,
         e.descr,''GHJ''
    FROM dbo.system sy
            INNER JOIN dbo.event e ON e.event_id = ''2AC''
  WHERE sy.cs_no BETWEEN @start_cs_no AND @end_cs_no

  SELECT @zonecnt += @@rowcount
  SELECT @eventcnt += @zonecnt

  IF @debug > 1
    EXEC dbo.sp__msg ''Created %1 twoway signals'', @f1=@zonecnt

  -- wait for the system clock to advance
  WHILE @timer = GETDATE() CONTINUE
END

IF @debug > 0
BEGIN
  IF @start_cs_no = @end_cs_no
    EXEC dbo.sp__msg ''Created total of %1 signals for CS# %2'', @f1=@eventcnt, @f2=@start_cs_no
  ELSE
    EXEC dbo.sp__msg ''Created total of %1 %2 signals for CS# range %3 - %4'',
                     @f1=@eventcnt, @f2=@monitor_type, @f3=@start_cs_no, @f4=@end_cs_no
END

end_procedure:
-- let the caller know whether events were successfully created
IF @eventcnt > 0
  RETURN 0
ELSE
  RETURN 1
go

GRANT EXECUTE ON dbo.mi_ap_create_test_signals TO mas_user
go
GRANT EXECUTE ON dbo.mi_ap_create_test_signals TO [PMS\rosenad]
go
GRANT EXECUTE ON dbo.mi_ap_create_test_signals TO [PMS\finletr]
go

--give Adam rights to the event_history table
use [mi_mondb]
GO
GRANT INSERT,UPDATE,SELECT,DELETE ON [dbo].[event_history] TO [PMS\rosenad]
GO

use [mi_mondb]
GO
GRANT INSERT,UPDATE,SELECT,DELETE ON [dbo].[event_history] TO [PMS\finletr]
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [add permissions_for_ap_o]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'add permissions_for_ap_o', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--give Adam rights to the event_history table


use [mi_mondb]
GO

GRANT EXECUTE ON dbo.ap_o TO [PMS\riversa]
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Schemas And Users mi_custom Developers]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Schemas And Users mi_custom Developers', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

use mi_custom
go


/****** Object:  Schema [PMS\bking]    Script Date: 09/30/2010 15:40:27 ******/

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''chenya'')
DROP SCHEMA [chenya]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\chenya'')
DROP SCHEMA [PMS\chenya]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\chenya'')
DROP USER [PMS\chenya]
GO

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''diazad'')
DROP SCHEMA [diazad]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\diazad'')
DROP SCHEMA [PMS\diazad]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\diazad'')
DROP USER [PMS\diazad]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''mjennings'')
DROP SCHEMA [mjennings]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\mjennings'')
DROP SCHEMA [PMS\mjennings]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\mjennings'')
DROP USER [PMS\mjennings]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''ogalindo'')
DROP SCHEMA [ogalindo]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\ogalindo'')
DROP SCHEMA [PMS\ogalindo]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\ogalindo'')
DROP USER [PMS\ogalindo]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''yunuskh'')
DROP SCHEMA [yunuskh]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\yunuskh'')
DROP SCHEMA [PMS\yunuskh]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\yunuskh'')
DROP USER [PMS\yunuskh]
GO





use mi_mondb
go


/****** Object:  Schema [PMS\bking]    Script Date: 09/30/2010 15:40:27 ******/

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''chenya'')
DROP SCHEMA [chenya]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\chenya'')
DROP SCHEMA [PMS\chenya]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\chenya'')
DROP USER [PMS\chenya]
GO

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''diazad'')
DROP SCHEMA [diazad]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\diazad'')
DROP SCHEMA [PMS\diazad]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\diazad'')
DROP USER [PMS\diazad]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''mjennings'')
DROP SCHEMA [mjennings]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\mjennings'')
DROP SCHEMA [PMS\mjennings]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\mjennings'')
DROP USER [PMS\mjennings]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''ogalindo'')
DROP SCHEMA [ogalindo]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\ogalindo'')
DROP SCHEMA [PMS\ogalindo]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\ogalindo'')
DROP USER [PMS\ogalindo]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''yunuskh'')
DROP SCHEMA [yunuskh]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\yunuskh'')
DROP SCHEMA [PMS\yunuskh]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\yunuskh'')
DROP USER [PMS\yunuskh]
GO





use mi_masdb
go


/****** Object:  Schema [PMS\bking]    Script Date: 09/30/2010 15:40:27 ******/

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''chenya'')
DROP SCHEMA [chenya]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\chenya'')
DROP SCHEMA [PMS\chenya]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\chenya'')
DROP USER [PMS\chenya]
GO

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''diazad'')
DROP SCHEMA [diazad]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\diazad'')
DROP SCHEMA [PMS\diazad]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\diazad'')
DROP USER [PMS\diazad]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''mjennings'')
DROP SCHEMA [mjennings]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\mjennings'')
DROP SCHEMA [PMS\mjennings]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\mjennings'')
DROP USER [PMS\mjennings]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''ogalindo'')
DROP SCHEMA [ogalindo]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\ogalindo'')
DROP SCHEMA [PMS\ogalindo]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\ogalindo'')
DROP USER [PMS\ogalindo]
GO


IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''yunuskh'')
DROP SCHEMA [yunuskh]
GO
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N''pms\yunuskh'')
DROP SCHEMA [PMS\yunuskh]
GO
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N''PMS\yunuskh'')
DROP USER [PMS\yunuskh]
GO



USE [mi_custom]
GO
CREATE USER [PMS\blakemi] FOR LOGIN [PMS\blakemi]
GO
USE [mi_custom]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\blakemi''
GO
USE [mi_masdb]
GO
CREATE USER [PMS\blakemi] FOR LOGIN [PMS\blakemi]
GO
USE [mi_masdb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\blakemi''
GO
USE [mi_mondb]
GO
CREATE USER [PMS\blakemi] FOR LOGIN [PMS\blakemi]
GO
USE [mi_mondb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\blakemi''
GO

USE [mi_custom]
GO
CREATE USER [PMS\waldral] FOR LOGIN [PMS\waldral]
GO
USE [mi_custom]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\waldral''
GO
USE [mi_masdb]
GO
CREATE USER [PMS\waldral] FOR LOGIN [PMS\waldral]
GO
USE [mi_masdb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\waldral''
GO
USE [mi_mondb]
GO
CREATE USER [PMS\waldral] FOR LOGIN [PMS\waldral]
GO
USE [mi_mondb]
GO
EXEC sp_addrolemember N''db_datareader'', N''PMS\waldral''
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update_Signal_Processor_to_Dev]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update_Signal_Processor_to_Dev', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Run in the monitoring DB

use mi_mondb
go

SET NOCOUNT ON

IF @@SERVERNAME = ''BUDDY''
BEGIN
	update office
	set telephony_server = NULL
	where office_no = 1 
	and @@servername = ''BUDDY'' 
	
	PRINT ''BUDDY''''s signal processor has been successfully updated''
END

IF @@SERVERNAME = ''JOPLIN''
BEGIN
	update office
	set telephony_server = NULL
	where office_no = 1 
	and @@servername = ''JOPLIN'' 
	
	PRINT ''JOPLIN''''s signal processor has been successfully updated''
END

IF @@SERVERNAME = ''RICKY''
BEGIN
	update office
	set telephony_server = NULL
	where office_no = 1 
	and @@servername = ''RICKY'' 
	
	PRINT ''RICKY''''s signal processor has been successfully updated''
END

IF (@@SERVERNAME <> ''BUDDY'') AND (@@SERVERNAME <> ''JOPLIN'') AND (@@SERVERNAME <> ''RICKY'')
BEGIN
	PRINT ''This script should only be executed during the monthly MI TRIO restores.''
	PRINT ''The script must be executed against BUDDY, JOPLIN, and RICKY.''
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [monthly_restore_rcv_tasks_cleanup]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'monthly_restore_rcv_tasks_cleanup', 
		@step_id=29, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use mi_masdb
go
-- MONTHLY_Restore_RCV_Tasks_Cleanup

-- Rev 06072016 11:30 - mth - production-proofing test tasks

update office
set telephony_server = ''signalproda''
where office_no = 1

--Enable Y-off and Ademco receivers
update m_task
set rcvr_interface_id = ''T1''
where task_no in (3,4,5,6,7,8,9,10,12,14,15,16,27,29,31,32,33,36,38,42)

--Update specified receivers to Z1 UNUSED receiver interface
update m_task
set rcvr_interface_id = ''Z1''
where task_no in (11,17,18,19,21,23,26,28,30,35,37,43,44,45,46,47,48,57,61,917)

--Update Wittington TEST receivers
update m_task
set rcvr_interface_id = ''WT''
where task_no in (13,20,34,39,40,41,49,50,51,52,53,54,55,56,58,59,62,63)

--Delete TCP/IP from ALL receiver tasks as safety feature
update m_task
set tcpip_address = NULL
where task_no in (4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,61,62,63)


--Delete task lines from ALL receiver tasks (Will add to S3 TEST receiver later)
delete from m_task_line
where task_no in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,61,62,63)


--Update Receiver displayed data
update m_task
set descr = ''ADM1(62) Y'', port_no = 62 where task_no = 3 

update m_task
set descr = ''OH6DAL(72) Y'', port_no = 72 where task_no = 4

update m_task
set descr = ''S3 1A(51) Y'',port_no = 51 where task_no = 5

update m_task
set descr = ''S3 2A(52) Y'',port_no = 52 where task_no = 6

update m_task
set descr = ''S3 3A(53) Y'',port_no = 53 where task_no = 7

update m_task
set descr = ''S3 4A(54) Y'',port_no = 54 where task_no = 8

update m_task
set descr = ''S3 5A(55) Y'',port_no = 55 where task_no = 9

update m_task
set descr = ''S3 6A(56) Y'',port_no = 56 where task_no = 10

update m_task
set descr = ''S3 3B n/u'',port_no = 9999 where task_no = 11

update m_task
set descr = ''OH5DAL(61) Y'', port_no = 61 where task_no = 12

update m_task
set descr = ''WP-S3 1A'',port_no = 9999 where task_no = 13

update m_task
set descr = ''OH4DAL(65) Y'', port_no = 65 where task_no = 14
 
update m_task
set descr = ''S3 TEST(81) Serial'',port_no = 81,
keep_alive_msg = ''198000           @'' where task_no = 15
insert into m_task_line values (15,0101,05802)
insert into m_task_line values (15,0102,05803)
insert into m_task_line values (15,0103,05804)
insert into m_task_line values (15,0104,05805)

update m_task
set descr = ''S3 TEST TCP'',port_no = 1025,
keep_alive_msg = ''198000           @'',
com_method = ''TCPIPCLIENT'', 
tcpip_address = ''192.168.155.200'' where task_no = 16
insert into m_task_line values (16,0101,05802)
insert into m_task_line values (16,0102,05803)
insert into m_task_line values (16,0103,05804)
insert into m_task_line values (16,0104,05805)

update m_task
set descr = ''S3 1B n/u'',port_no = 9999,
keep_alive_msg = ''117000           @'',com_method = ''RS232'' where task_no = 17

update m_task
set descr = ''S3 2B n/u'',port_no = 9999,
keep_alive_msg = ''118000           @'',com_method = ''RS232'' where task_no = 18

update m_task
set descr = ''S3 5B n/u'',port_no = 9999,
keep_alive_msg = ''119000           @'',com_method = ''RS232'' where task_no = 19

update m_task
set descr = ''WP-S4 1A'',port_no = 9999,
keep_alive_msg = ''120000           @'',com_method = ''RS232'' where task_no = 20

update m_task
set descr = ''SG n/u'',port_no = 9999,
keep_alive_msg = ''121000           @'',com_method = ''RS232'' where task_no = 21

update m_task
set descr = ''S3 9B n/u'',port_no = 9999,
keep_alive_msg = ''123000           @'',com_method = ''RS232'' where task_no = 23

update m_task
set descr = ''SG n/u'',keep_alive_msg = ''124000           @'',port_no = 9999, com_method = ''RS232'' where task_no = 24

update m_task
set descr = ''SG n/u'',keep_alive_msg = ''125000           @'',port_no = 9999, com_method = ''RS232'' where task_no = 25

update m_task
set descr = ''SG n/u'',keep_alive_msg = ''126000           @'',  port_no = 9999, com_method = ''RS232'' where task_no = 26

update m_task
set descr = ''S3 7A(57) Y'', port_no = 57, com_method = ''RS232'' where task_no = 27

update m_task
set descr = ''S3 7B n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 28

update m_task
set descr = ''OH7DAL !a Y (67)'', port_no = 67 where task_no = 29
insert into m_task_line values (29,0231,80074)

update m_task
set descr = ''S3 11B n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 30

update m_task
set descr = ''S3 9A(60) Y'',port_no = 60, com_method = ''RS232'' where task_no = 31

update m_task
set descr = ''S3 10A(63) Y'',port_no = 63, com_method = ''RS232'' where task_no = 32

update m_task
set descr = ''ADM2(58) Y'', port_no = 58, com_method = ''RS232'' where task_no = 33

update m_task
set descr = ''WP-S4 1B'', port_no = 9999, com_method = ''RS232'' where task_no = 34

update m_task
set descr = ''S3 10B n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 35

update m_task
set descr = ''S3 8A(p59) Y'', port_no = 9999, com_method = ''RS232'' where task_no = 36

update m_task
set descr = ''S3 # 8B n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 37

update m_task
set descr = ''WP-S3 11A(p66) Y'', port_no = 9999, com_method = ''RS232'' where task_no = 38

update m_task
set descr = ''WP-S3 1B'', port_no = 9999, com_method = ''RS232'' where task_no = 39

update m_task
set descr = ''WP-S3 2A'', port_no = 9999, com_method = ''RS232'' where task_no = 40

update m_task
set descr = ''WP-S3 2B'', port_no = 9999, com_method = ''RS232'' where task_no = 41

update m_task
set descr = ''WP-ADM1(83)'', port_no = 83, com_method = ''RS232'' where task_no = 42

update m_task
set descr = ''SG n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 43

update m_task
set descr = ''SG n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 44

update m_task
set descr = ''S3 12A n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 45

update m_task
set descr = ''S3 12B n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 46

update m_task
set descr = ''S3 13A n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 47

update m_task
set descr = ''S3 13B n/u'', port_no = 9999, com_method = ''RS232'' where task_no = 48

update m_task
set descr = ''WP-S3 3A'', port_no = 9999, com_method = ''RS232'' where task_no = 49

update m_task
set descr = ''WP-S3 3B'', port_no = 9999, com_method = ''RS232'' where task_no = 50

update m_task
set descr = ''WP-S3 4A'', port_no = 9999, com_method = ''RS232'' where task_no = 51

update m_task
set descr = ''WP-S3 4B'', port_no = 9999, com_method = ''RS232'' where task_no = 52

update m_task
set descr = ''WP-S4 2A'', port_no = 9999, com_method = ''RS232'' where task_no = 53

update m_task
set descr = ''WP-S4 2B'' , port_no = 9999, com_method = ''RS232'' where task_no = 54

update m_task
set descr = ''WP-S4 3A'' , port_no = 9999, com_method = ''RS232'' where task_no = 55

update m_task
set descr = ''WP-S4 3B'', port_no = 9999, com_method = ''RS232'' where task_no = 56

update m_task
set descr = ''ADC SYSIII_2W 1A'', port_no = 9999, com_method = ''RS232'' where task_no = 57

update m_task
set descr = ''WP-S4 4A'', port_no = 9999, com_method = ''RS232'' where task_no = 58

update m_task
set descr = ''WP-S4 4B'', port_no = 9999, com_method = ''RS232'' where task_no = 59

update m_task
set descr = ''ADC SYSIII_2W 1B'', port_no = 9999, com_method = ''RS232'' where task_no = 61

update m_task
set descr = ''WP-S4 5A'', port_no = 9999, com_method = ''RS232'' where task_no = 62

update m_task
set descr = ''WP-S4 5B'',port_no = 9999, com_method = ''RS232'' where task_no = 63


--Task 98 cleanup
update m_task
set rcvr_interface_id = ''TW'' where task_no = 98

update m_task_line
set dial_string = ''Mastest_1'' where task_no = 98 and line = ''PASS''

update m_task_line
set dial_string = ''mastest'' where task_no = 98 and line = ''USER'' 

select * from m_task_line where task_no = 98
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Change PMSOLD Scripts]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Change PMSOLD Scripts', 
		@step_id=30, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @sql nvarchar(max)

SELECT name
FROM sys.objects 
WHERE type = ''P'' 
	and (	(OBJECT_DEFINITION(object_id) like ''%pmsold%'')
	and	    (OBJECT_DEFINITION(object_id) not like ''%pmsold[_]sn%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_masdb%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_custom%'')
		)

select @sql = '''';

SELECT @sql = @sql + ''

'' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(OBJECT_DEFINITION(object_id),''CREATE PROCEDURE'',''ALTER PROCEDURE''),''pmsold'',''pmsold_sn''),''mi_masdb'',''mi_masdb''),''mi_custom'',''mi_custom''),''CREATE  PROCEDURE'',''ALTER PROCEDURE''),''CREATE PROC'',''ALTER PROCEDURE'') + ''
GO''
FROM sys.objects 
WHERE type = ''P'' 
	and (	(OBJECT_DEFINITION(object_id) like ''%pmsold%'')
	and	    (OBJECT_DEFINITION(object_id) not like ''%pmsold[_]sn%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_masdb%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_custom%'')
		)
--	and (name = ''cp_tblSSRS_SystemAccess_User_Update'' or name = ''cp_SSRS_ag_AgencyInstallsCrywolf1Sub'')

SELECT LEN(@sql)

SELECT @sql AS [processing-instruction(x)] FOR XML PATH('''')

--EXEC (@sql)

--PRINT @sql /*WILL be truncated*/', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Change PMSOLD Views]    Script Date: 11/30/2020 4:56:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Change PMSOLD Views', 
		@step_id=31, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @VeryLongText nvarchar(max)

select @verylongtext = '''';

SELECT name
FROM sys.objects 
WHERE type = ''V'' 
	and (	(OBJECT_DEFINITION(object_id) like ''%pmsold%'')
	and	    (OBJECT_DEFINITION(object_id) not like ''%pmsold[_]sn%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_masdb%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_custom%'')
		)


SELECT @VeryLongText = @VeryLongText + ''

'' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(OBJECT_DEFINITION(object_id),''CREATE VIEW'',''ALTER VIEW''),''pmsold'',''pmsold_sn''),''mi_masdb'',''mi_masdb''),''mi_custom'',''mi_custom''),''CREATE  VIEW'',''ALTER VIEW'') + ''
GO''
FROM sys.objects 
WHERE type = ''V'' 
	and (	(OBJECT_DEFINITION(object_id) like ''%pmsold%'')
	and	    (OBJECT_DEFINITION(object_id) not like ''%pmsold[_]sn%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_masdb%'')
		--or	(OBJECT_DEFINITION(object_id) like ''%mi_custom%'')
		)
--	and (name = ''cp_tblSSRS_SystemAccess_User_Update'' or name = ''cp_SSRS_ag_AgencyInstallsCrywolf1Sub'')

--SELECT LEN(@VeryLongText)

SELECT @VeryLongText AS [processing-instruction(x)] FOR XML PATH('''')

--PRINT @VeryLongText /*WILL be truncated*/', 
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

/****** Object:  Job [DBAAdmin_Save_Passwords]    Script Date: 11/30/2020 4:56:56 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:56 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Save_Passwords', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary]    Script Date: 11/30/2020 4:56:56 PM ******/
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
/****** Object:  Step [Save_Passwords]    Script Date: 11/30/2020 4:56:56 PM ******/
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
		@schedule_uid=N'aa238274-281a-421f-8b27-a702d5fc13be'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Save_SQL_Agent_Jobs]    Script Date: 11/30/2020 4:56:56 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:56 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Save_SQL_Agent_Jobs', 
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
/****** Object:  Step [Save SQL Agent Jobs]    Script Date: 11/30/2020 4:56:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Save SQL Agent Jobs', 
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
if @@servername = ''WP1MASINST01''
begin
	delete from openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP1MASINST01'')
end

if @@servername = ''WP1MASINST02''
begin
	delete from openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP1MASINST02'')
end

if @@servername = ''VV1MASINST01''
begin
	delete from openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_VV1MASINST01'')
end

if @@servername = ''VV1MASINST02''
begin
	delete from openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_VV1MASINST02'')
end

if @@servername = ''WP4MASINST01''
begin
	delete from openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP4MASINST01'')
end

if @@servername = ''WP4MASINST02''
begin
	delete from openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP4MASINST02'')
end

if @@servername = ''WP1MASINST01''
	insert into openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP1MASINST01'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		and name not like ''%_q_%''
		order by name

if @@servername = ''WP1MASINST02''
	insert into openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP1MASINST02'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		and name not like ''%_q_%''
		order by name

if @@servername = ''VV1MASINST01''
	insert into openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_VV1MASINST01'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		and name not like ''%_q_%''
		order by name

if @@servername = ''VV1MASINST02''
	insert into openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_VV1MASINST02'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		and name not like ''%_q_%''
		order by name

if @@servername = ''WP4MASINST01''
	insert into openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP4MASINST01'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		and name not like ''%_q_%''
		order by name

if @@servername = ''WP4MASINST02''
	insert into openquery(WPSITSQL01, ''select name from DBAAdmin.dbo.jobname_WP4MASINST02'') (name) select name from msdb.dbo.sysjobs where name like ''[a-zA-Z]%''
		and name not like ''%_q_%''
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

/****** Object:  Job [DBAAdmin_Sync_MASPROD_Logins]    Script Date: 11/30/2020 4:56:57 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAAdmin]    Script Date: 11/30/2020 4:56:57 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAAdmin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAAdmin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Sync_MASPROD_Logins', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job that will sync logins from the PRIMARY to secondary REPLICAS.  This is for the MASPROD availability group ONLY.  Scheduled to run hourly.  It is recommended that this job be run prior to a scheduled failover.', 
		@category_name=N'DBAAdmin', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not The Quit Reporting Success)]    Script Date: 11/30/2020 4:56:57 PM ******/
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
/****** Object:  Step [Sync Logins via PowerShell]    Script Date: 11/30/2020 4:56:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sync Logins via PowerShell', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -ExecutionPolicy Bypass \\wp1nas01\SQLBackup\WP1MASINST02\Scripts\SyncLogins.ps1', 
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
		@schedule_uid=N'10917089-b778-4fa3-ba00-9c07fb87effd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBAAdmin_Update_Statistics]    Script Date: 11/30/2020 4:56:57 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:57 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAAdmin_Update_Statistics', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:57 PM ******/
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
/****** Object:  Step [Update Statistics in mi_custom]    Script Date: 11/30/2020 4:56:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Statistics in mi_custom', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'if datepart(hour, getdate()) = 5
begin
	exec sp_updatestats
end	
', 
		@database_name=N'mi_custom', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Statistics in mi_masdb]    Script Date: 11/30/2020 4:56:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Statistics in mi_masdb', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'if datepart(hour, getdate()) = 5
begin
	exec sp_updatestats
end	
', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Statistics in mi_mondb]    Script Date: 11/30/2020 4:56:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Statistics in mi_mondb', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'if datepart(hour, getdate()) = 5
begin
	exec sp_updatestats
end	
', 
		@database_name=N'mi_mondb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Statistics of specified tables]    Script Date: 11/30/2020 4:56:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Statistics of specified tables', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec update_stats
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
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200204, 
		@active_end_date=99991231, 
		@active_start_time=1500, 
		@active_end_time=235959, 
		@schedule_uid=N'f330bb96-2c0e-45c9-ac41-d11b123804d9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DbObjects_Archive]    Script Date: 11/30/2020 4:56:57 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:57 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:58 PM ******/
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
/****** Object:  Step [Arive the sysobjects table for the three MAS databases]    Script Date: 11/30/2020 4:56:58 PM ******/
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

/****** Object:  Job [Guard Dispatch Billing]    Script Date: 11/30/2020 4:56:58 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Processing]    Script Date: 11/30/2020 4:56:58 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Processing' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Processing'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Guard Dispatch Billing', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'For all customers with a dispatch event to a Guard agency and no cancel for the incident
        create BGUARD action
        create BGDREV if incorrect # of customer site links (-0- or 2+)
        does not close the BGUARD action - A/R group to review and close', 
		@category_name=N'Processing', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:58 PM ******/
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
/****** Object:  Step [mi_guard_dispatch_actions]    Script Date: 11/30/2020 4:56:58 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_guard_dispatch_actions', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC mi_masdb.dbo.mi_guard_dispatch_actions', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\GuardDispatchBilling.txt', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule 1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20091022, 
		@active_end_date=99991231, 
		@active_start_time=32500, 
		@active_end_time=235959, 
		@schedule_uid=N'7156fd9c-5c61-47ea-a4cd-b442981c644c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [InsertLTEJobLine]    Script Date: 11/30/2020 4:56:58 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:56:58 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:58 PM ******/
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
/****** Object:  Step [InsertLTEJobLine]    Script Date: 11/30/2020 4:56:58 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'InsertLTEJobLine', 
		@step_id=2, 
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
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
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

/****** Object:  Job [InvoiceAgingwithCostCenter_Populate_and_FileExport]    Script Date: 11/30/2020 4:56:58 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Processing]    Script Date: 11/30/2020 4:56:58 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Processing' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Processing'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'InvoiceAgingwithCostCenter_Populate_and_FileExport', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'internal rewrite of MAS report to include additional column.   This job creates text files for Company 1 and 5 from a final data table created by stored procedure mi_custom.cp_InvoiceAgingWithCostCenter.  see documentation on CustomDev sharepoint portal.  This should run wherever the ITProcessingPortal is pointing to.  Authors: JColeman; TWeissenburg; AKumar', 
		@category_name=N'Processing', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', 
		@notify_page_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:58 PM ******/
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
/****** Object:  Step [populate co 5]    Script Date: 11/30/2020 4:56:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'populate co 5', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_custom.dbo.cp_InvoiceAgingWithCostCenter 
@co_no= 5,
@username =''PMS\gMSA_DevSql_SVC$'' ,
@FriendlyName =''Invoice Aging Detail Report Co5''', 
		@database_name=N'mi_custom', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [populate co 1]    Script Date: 11/30/2020 4:56:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'populate co 1', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_custom.dbo.cp_InvoiceAgingWithCostCenter 
@co_no= 1,
@username =''PMS\gMSA_DevSql_SVC$'' ,
@FriendlyName =''Invoice Aging Detail Report Co1''', 
		@database_name=N'mi_custom', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Export Company 5 text file]    Script Date: 11/30/2020 4:56:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Export Company 5 text file', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec mi_custom.dbo.cp_InvoiceAgingWithCostCenter_FileExport 5', 
		@database_name=N'mi_custom', 
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\InvoiceAgingWithCostCenter_FileExport_company5.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Export Company 1 text file]    Script Date: 11/30/2020 4:56:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Export Company 1 text file', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec mi_custom.dbo.cp_InvoiceAgingWithCostCenter_FileExport 1', 
		@database_name=N'mi_custom', 
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\InvoiceAgingWithCostCenter_FileExport_company1.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Schedule - Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180901, 
		@active_end_date=99991231, 
		@active_start_time=3500, 
		@active_end_time=235959, 
		@schedule_uid=N'15cca886-06ed-4882-bf9c-25ca671bdf56'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [JobManagementDQCleanUp]    Script Date: 11/30/2020 4:56:59 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:56:59 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JobManagementDQCleanUp', 
		@enabled=1, 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:56:59 PM ******/
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
/****** Object:  Step [mi_cp_Job_Management_Update_AgedDQJobs]    Script Date: 11/30/2020 4:56:59 PM ******/
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

/****** Object:  Job [JobManagementRuleEngine]    Script Date: 11/30/2020 4:56:59 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:56:59 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JobManagementRuleEngine', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update job status level as business rules have been violated', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:00 PM ******/
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
/****** Object:  Step [UpdateJobStatusLevel]    Script Date: 11/30/2020 4:57:00 PM ******/
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

/****** Object:  Job [JobPayments]    Script Date: 11/30/2020 4:57:00 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Processing]    Script Date: 11/30/2020 4:57:00 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Processing' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Processing'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JobPayments', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Created as part of RFC F0116945. See the ticket for more detail.', 
		@category_name=N'Processing', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:00 PM ******/
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
/****** Object:  Step [Step 1]    Script Date: 11/30/2020 4:57:00 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'execute mi_ap_job_payment', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Processing Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20151008, 
		@active_end_date=99991231, 
		@active_start_time=190000, 
		@active_end_time=233000, 
		@schedule_uid=N'29d49c24-6ba4-49e9-ab4d-2e5d2661af5c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [LiveAnswerUpdate]    Script Date: 11/30/2020 4:57:00 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:00 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'LiveAnswerUpdate', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:00 PM ******/
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
/****** Object:  Step [execute mi_ap_live_answer_update]    Script Date: 11/30/2020 4:57:00 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'execute mi_ap_live_answer_update', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_ap_live_answer_update
', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181112, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959, 
		@schedule_uid=N'3ecdc152-1aae-4748-ad17-99b7716ebd76'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sched_2', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181113, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=55959, 
		@schedule_uid=N'fcbc61f0-0787-4ca1-9725-602cb43e7d68'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Load_BW_2G]    Script Date: 11/30/2020 4:57:00 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:57:01 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Load_BW_2G', 
		@enabled=1, 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:01 PM ******/
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
/****** Object:  Step [Execute_mi_ap_load_bw_2g]    Script Date: 11/30/2020 4:57:01 PM ******/
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

/****** Object:  Job [LoadLTESitesTable]    Script Date: 11/30/2020 4:57:01 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:01 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:01 PM ******/
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
/****** Object:  Step [LoadLTESitesTable]    Script Date: 11/30/2020 4:57:01 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LoadLTESitesTable', 
		@step_id=2, 
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
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
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

/****** Object:  Job [MAS_Future_Cancel_Actions]    Script Date: 11/30/2020 4:57:01 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS_BUS]    Script Date: 11/30/2020 4:57:01 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS_BUS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS_BUS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MAS_Future_Cancel_Actions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Creates future cancel actions on cancellations 60 days in the future', 
		@category_name=N'MAS_BUS', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:01 PM ******/
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
/****** Object:  Step [Step 1]    Script Date: 11/30/2020 4:57:01 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_ap_future_cancel', 
		@database_name=N'mi_masdb', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110512, 
		@active_end_date=99991231, 
		@active_start_time=31000, 
		@active_end_time=235959, 
		@schedule_uid=N'e471e8b0-7244-460c-bdc0-ac93a9678bca'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [MI CUSTOM LOAD CUSTAGE]    Script Date: 11/30/2020 4:57:02 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:57:02 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MI CUSTOM LOAD CUSTAGE', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Procedure to load mi_custage table for PMS', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:02 PM ******/
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
/****** Object:  Step [mi_ap_load_custage]    Script Date: 11/30/2020 4:57:02 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mi_ap_load_custage', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_custom.dbo.mi_ap_load_custage', 
		@database_name=N'mi_custom', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\mi_ap_load_custage.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'CUSTAGE LOAD', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20070330, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'b3bf7026-abdb-46ba-a738-bdaffe786a30'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [mi_cp_process_add_addhaw_recline]    Script Date: 11/30/2020 4:57:02 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:02 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'mi_cp_process_add_addhaw_recline', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:02 PM ******/
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
/****** Object:  Step [Step_1]    Script Date: 11/30/2020 4:57:02 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step_1', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [mi_masdb].[dbo].[mi_cp_process_add_addhaw_recline] 999
', 
		@database_name=N'mi_masdb', 
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
		@active_start_date=20190807, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'048f54fe-7ba8-4c9b-ae59-37701f3ecbf2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [mi_custom InsertNewTechnicianMasAdRelationships]    Script Date: 11/30/2020 4:57:03 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:03 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'mi_custom InsertNewTechnicianMasAdRelationships', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is used to populate the mi_custom table "mi_mas_ad_account_mapping" with new technicians every night. If a technician''s new AD and MAS accounts are created, they must be seeded in this table to work with the Technician App.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'mymoni', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute mi_3pf_InsertNewTechnicianMasAdRelationships]    Script Date: 11/30/2020 4:57:03 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute mi_3pf_InsertNewTechnicianMasAdRelationships', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [mi_custom]
GO

EXECUTE  [dbo].[mi_3pf_InsertNewTechnicianMasAdRelationships] 
GO


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Nightly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200217, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'65513b79-e11a-4cdb-b755-20b1d0ebf1f0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Move Actions]    Script Date: 11/30/2020 4:57:03 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:03 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Move Actions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Create UPDCMV actions for incomplete moves', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:03 PM ******/
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
/****** Object:  Step [Procedure_move_actions]    Script Date: 11/30/2020 4:57:03 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Procedure_move_actions', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_ap_incomplete_move_actions', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\srvalch01\MASOut\JobLogs\HURRICANE_moveaction.txt', 
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
		@active_start_date=20170327, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'f75d39ed-c3bc-4cb5-8875-06ed27aefdf4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Populate_Agency_Permits_status]    Script Date: 11/30/2020 4:57:03 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:57:03 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Populate_Agency_Permits_status', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:03 PM ******/
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
/****** Object:  Step [Populate table]    Script Date: 11/30/2020 4:57:03 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Populate table', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_custom.dbo.cp_SSRS_ag_AgencyPermitStatusPOP', 
		@database_name=N'mi_custom', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\Populate_Agency_Permits_status.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Populate_Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20081017, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'0a9bf940-8e82-44ab-9917-726472df282e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Post_Cancel_Actions]    Script Date: 11/30/2020 4:57:03 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:57:03 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Post_Cancel_Actions', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'For all customers in post-cancellation (defined as having open PCN action), determine
    what, if anything, needs to be done with them and do it.', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:04 PM ******/
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
/****** Object:  Step [Post_Cancels]    Script Date: 11/30/2020 4:57:04 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Post_Cancels', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_masdb.dbo.mi_ap_postcancel', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\Post_Cancel_Actions.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Post_Cancel_Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20090427, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'0a4a01ab-ba20-4893-9de3-f9ed14c86b37'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Purge Raw Signal MI_mondb]    Script Date: 11/30/2020 4:57:04 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:04 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Purge Raw Signal MI_mondb', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Purge Raw Signal MI_mondb', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:04 PM ******/
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
/****** Object:  Step [Start Raw Signal Purge]    Script Date: 11/30/2020 4:57:04 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Raw Signal Purge', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec ap_m_signal_processed_purge', 
		@database_name=N'MI_mondb', 
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
		@active_start_date=20060417, 
		@active_end_date=99991231, 
		@active_start_time=34600, 
		@active_end_time=235959, 
		@schedule_uid=N'f813a093-804b-4c55-9c05-3f2e885a8503'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Red Clean]    Script Date: 11/30/2020 4:57:04 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:04 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Red Clean', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Red Clean', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:05 PM ******/
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
/****** Object:  Step [Start Red Clean]    Script Date: 11/30/2020 4:57:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Red Clean', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec ap_red_clean', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20070320, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'6b4a84f3-f858-4210-b99f-42ad7f15e724'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Red Clean MI_mondb]    Script Date: 11/30/2020 4:57:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:05 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Red Clean MI_mondb', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Red Clean MI_mondb', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:05 PM ******/
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
/****** Object:  Step [Start Red Clean]    Script Date: 11/30/2020 4:57:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Red Clean', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec ap_red_clean', 
		@database_name=N'MI_mondb', 
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
		@active_start_date=20060417, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'94ae2edd-774b-48da-974a-0f80069402c0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [restore vertex]    Script Date: 11/30/2020 4:57:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:05 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'restore vertex', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'PMS\cntr_mokkadi', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [restore]    Script Date: 11/30/2020 4:57:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'restore', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'function LiteSpeedRestore($srv, $DatabaseName, $RestoreToServer, $RestoreFromLocation)
{
$RestoreFromLocation
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {''''
   $PrimaryFG = '' MOVE N'''''''''' + $pf.Name + '''''''''' TO N'''''''''' + $pf.FileName + ''''''''''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE N'''''''''' + $lf.Name + '''''''''' TO N'''''''''' + $lf.FileName + ''''''''''''''''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

$RestoreCommand = $KillCommand + '' EXEC master.dbo.xp_restore_database @database = N'''''' + $DatabaseName + '''''' , @filename = N'''''' + $RestoreFromLocation + '''''',
@filenumber = 1, @encryptionkey = N''''7908d2f6a8737846f07758a7553179ca'''', @with = N''''REPLACE'''', @with = N''''STATS = 10'''',
@with = N'''''' + $PrimaryFG + '', @with = N'''''' + $LogFG + '', @affinity = 0, @logging = 0;''

# $RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

function NativeRestore($srv, $DatabaseName, $RestoreToServer, $backupLocation)
{
$db = $srv.Databases.Item($DatabaseName)

# Build a string to move the database primary file group to the correct location
foreach ($fg in $db.FileGroups) {
  Foreach ($pf in $fg.Files)
   {
   $PrimaryFG = '' MOVE '''''' + $pf.Name + '''''' TO '''''' + $pf.FileName + ''''''''
   }
}

# Build a string to move the database log file group to the correct location
Foreach ($lf in $db.LogFiles)
{
   $LogFG = '' MOVE '''''' + $lf.Name + '''''' TO '''''' + $lf.FileName + '''''' ''
}
# Disconnect as we will have a SPID on the restore to server.
$srv.ConnectionContext.Disconnect()

# Write-Host $PrimaryFG
# Write-Host $LogFG

$KillCommand = ''DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''''KILL '''' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id('''''' + $DatabaseName + '''''')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END

CLOSE killCursor
DEALLOCATE killCursor;''

# Build a string for the native restore command
$RestoreCommand = $KillCommand + '' RESTORE DATABASE ['' + 
                  $DatabaseName + ''] FROM DISK = '''''' + $backupLocation + '''''' WITH REPLACE, '' + $PrimaryFG + '', '' + $LogFG + '', STATS = 5;''

$RestoreCommand

$RestoreOutput = Invoke-Sqlcmd -QueryTimeout 0 -ServerInstance $RestoreToServer -Database master -Query $RestoreCommand
$RestoreOutput

}

# import-module "sqlps" -DisableNameChecking
# Name of the database to restore
$DatabaseName = ''Vertex''
# Name of the server to restore to
$RestoreToServer = ''Wp1masinst02''
# $RestoreToServer = $env:computername
# Name of the source server
$RestoreFromServer = ''Vertexprodb''
# Build a path string to the location of the backup file
#$BackupPath = (''\\WP1NAS01\sqlbackup\'' + $RestoreFromServer + ''\Backup\A-Full\'')
$BackupPath = ''\\wp1nas01\SQLBackup\Restore\''

Set-Location c:

# Get the name of the backup file to restore.  Sort newest backup first.  Output the file name to the $BackupFileName variable.  This will be an array variable
Get-ChildItem -Name -Path ($BackupPath + ''*'' + $DatabaseName + ''*'') -OutVariable BackupFileName | Where-Object { -not $_.PsIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -first 1

# Build a string with the complelete UNC filename to restore.  
$backupLocation = ($backupPath + 
    $BackupFileName[0]) # Use the first file in the list.

# $backupLocation

# Load the SQL Server Management Object Assembly
[System.Reflection.Assembly]::LoadWithPartialName(''Microsoft.SqlServer.SMO'') | out-null
$srv = New-Object (''Microsoft.SqlServer.Management.Smo.Server'') $RestoreToServer
# $db = $svr.Databases

LiteSpeedRestore $srv $DatabaseName $RestoreToServer $backupLocation
# NativeRestore $srv $DatabaseName $RestoreToServer $backupLocation









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

/****** Object:  Job [REVREC_ap_load_amoritzation]    Script Date: 11/30/2020 4:57:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:05 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'REVREC_ap_load_amoritzation', 
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:05 PM ******/
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
/****** Object:  Step [Execute storeproc]    Script Date: 11/30/2020 4:57:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute storeproc', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[mi_ap_load_amortization]', 
		@database_name=N'mi_masdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Nightly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180412, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'4768e467-b8bd-4e0b-a304-574f195cf76d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #930 (Tran A)]    Script Date: 11/30/2020 4:57:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:06 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #930 (Tran A)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #930 (Tran A)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:06 PM ******/
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
/****** Object:  Step [Start Task #930]    Script Date: 11/30/2020 4:57:06 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #930', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 930', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'10c57033-afbe-40a7-84de-abc74976a0ee'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #931 (Event A)]    Script Date: 11/30/2020 4:57:06 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:06 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #931 (Event A)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #931 (Event A)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:06 PM ******/
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
/****** Object:  Step [Start Task #931]    Script Date: 11/30/2020 4:57:06 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #931', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 931', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'291e4fe4-0487-488b-91cf-a4a206ec8da0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #932 (Tran B)]    Script Date: 11/30/2020 4:57:06 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:06 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #932 (Tran B)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #932 (Tran B)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:06 PM ******/
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
/****** Object:  Step [Start Task #932]    Script Date: 11/30/2020 4:57:06 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #932', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 932', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'4f8a0a29-f530-4952-8504-78a78d508f4a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #933 (Event B)]    Script Date: 11/30/2020 4:57:06 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:06 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #933 (Event B)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #933 (Event B)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:07 PM ******/
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
/****** Object:  Step [Start Task #933]    Script Date: 11/30/2020 4:57:07 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #933', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 933', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'352e6587-fd81-4827-9e88-9d238337f51a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #934 (Tran C)]    Script Date: 11/30/2020 4:57:07 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:07 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #934 (Tran C)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #934 (Tran C)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:07 PM ******/
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
/****** Object:  Step [Start Task #934]    Script Date: 11/30/2020 4:57:07 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #934', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 934', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'5c60c59b-ccec-494e-bdeb-38068395ef90'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #935 (Event C)]    Script Date: 11/30/2020 4:57:07 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:07 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #935 (Event C)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #935 (Event C)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:07 PM ******/
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
/****** Object:  Step [Start Task #935]    Script Date: 11/30/2020 4:57:07 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #935', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 935', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'87f7593e-79f0-4045-894a-0a47a53d38df'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #936 (Tran D)]    Script Date: 11/30/2020 4:57:07 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:07 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #936 (Tran D)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #936 (Tran D)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:08 PM ******/
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
/****** Object:  Step [Start Task #936]    Script Date: 11/30/2020 4:57:08 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #936', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 936', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1e27f395-c1a6-4720-ab26-afdfba23794f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #937 (Event D)]    Script Date: 11/30/2020 4:57:08 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:08 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #937 (Event D)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #937 (Event D)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:08 PM ******/
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
/****** Object:  Step [Start Task #937]    Script Date: 11/30/2020 4:57:08 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #937', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 937', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'221d6183-5c2d-4419-ae28-f0cd32e658e1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #938 (Tran E)]    Script Date: 11/30/2020 4:57:08 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:08 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #938 (Tran E)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #938 (Tran E)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:09 PM ******/
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
/****** Object:  Step [Start Task #938]    Script Date: 11/30/2020 4:57:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #938', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 938', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd1df8b91-01e3-4a7b-a9e3-d27ab5506f80'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #939 (Event E)]    Script Date: 11/30/2020 4:57:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:09 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #939 (Event E)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #939 (Event E)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:09 PM ******/
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
/****** Object:  Step [Start Task #939]    Script Date: 11/30/2020 4:57:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #939', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 939', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e9580fbd-4453-4f43-b3a3-cfd0ec20abef'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #940 (Tran F)]    Script Date: 11/30/2020 4:57:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:09 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #940 (Tran F)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #940 (Tran F)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:09 PM ******/
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
/****** Object:  Step [Start Task #940]    Script Date: 11/30/2020 4:57:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #940', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 940', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1d673560-2325-4f22-8c44-c73b0800fe13'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [saved_mi_mondb Task #941 (Event F)]    Script Date: 11/30/2020 4:57:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS]    Script Date: 11/30/2020 4:57:09 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'saved_mi_mondb Task #941 (Event F)', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_mondb Task #941 (Event F)', 
		@category_name=N'MAS', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:09 PM ******/
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
/****** Object:  Step [Start Task #941]    Script Date: 11/30/2020 4:57:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Task #941', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON EXEC ap_start_task 941', 
		@database_name=N'mi_mondb', 
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
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'79ae8eac-075e-415d-9093-cd0be3c7fd93'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSIS Failover Monitor Job]    Script Date: 11/30/2020 4:57:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:10 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSIS Failover Monitor Job', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Runs every 2 minutes. This job execute master.dbo.sp_ssis_startup if detect AlwaysOn failover on SSISDB.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'##MS_SSISServerCleanupJobLogin##', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [AlwaysOn Failover Monitor]    Script Date: 11/30/2020 4:57:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'AlwaysOn Failover Monitor', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=3, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*
	DECLARE @role int
	DECLARE @status tinyint
	SET @role = (SELECT [role] FROM [sys].[dm_hadr_availability_replica_states] hars INNER JOIN [sys].[availability_databases_cluster] adc ON hars.[group_id] = adc.[group_id] WHERE hars.[is_local] = 1 AND adc.[database_name] =''SSISDB'')
	IF @role = 1
	BEGIN
		EXEC [SSISDB].[internal].[refresh_replica_status] @server_name = N''WP1MASINST02'', @status = @status OUTPUT
		IF @status = 1
			EXEC [SSISDB].[catalog].[startup]
	END
*/
DECLARE @role INT
DECLARE @sqlCmd NVARCHAR(MAX)
SET @role = (SELECT [role] FROM [sys].[dm_hadr_availability_replica_states] hars INNER JOIN [sys].[availability_databases_cluster] adc ON hars.[group_id] = adc.[group_id] WHERE hars.[is_local] = 1 AND adc.[database_name] =''SSISDB'')
IF @role = 1
BEGIN
    SET @sqlCmd = N''DECLARE @status tinyint;
    EXEC [SSISDB].[internal].[refresh_replica_status] @server_name = N'''''' + @@SERVERNAME + '''''', @status = @status OUTPUT
    IF @status = 1
        EXEC [SSISDB].[catalog].[startup]'';
    EXEC sys.sp_executesql @sqlCmd;
END', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monitor Scheduler', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20001231, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'bc4e55bd-e0cb-46aa-ba84-8b49e04c8715'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS Monthly Attrition Data Load]    Script Date: 11/30/2020 4:57:10 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:10 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:10 PM ******/
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
/****** Object:  Step [Attrition Data Load Run/ReRum]    Script Date: 11/30/2020 4:57:10 PM ******/
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
		@flags=0
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
		@schedule_uid=N'582c4531-a6bb-4a74-b048-3ce24e7cecbc'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS_Accounting_Securitization_RevenueByStateSummary_Update]    Script Date: 11/30/2020 4:57:10 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 4:57:10 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SSRSData' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SSRSData'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS_Accounting_Securitization_RevenueByStateSummary_Update', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'SSRSData', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:10 PM ******/
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
/****** Object:  Step [run_cp_ssrs_Accounting_Securitization_RevenueByStateSummary_Update]    Script Date: 11/30/2020 4:57:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run_cp_ssrs_Accounting_Securitization_RevenueByStateSummary_Update', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec cp_ssrs_Accounting_Securitization_RevenueByStateSummary_Update', 
		@database_name=N'mi_custom', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sched_summary_Update', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20091001, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'fa0ddc2a-b8c5-458b-be5c-fb2ec9627243'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS_cp_tblSSRS_SystemAccess_User_Update]    Script Date: 11/30/2020 4:57:10 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 4:57:10 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SSRSData' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SSRSData'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS_cp_tblSSRS_SystemAccess_User_Update', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Executes job to pull user data back from various production systems for SOX reporting purposes', 
		@category_name=N'SSRSData', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:11 PM ******/
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
/****** Object:  Step [Step 1]    Script Date: 11/30/2020 4:57:11 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec cp_tblSSRS_SystemAccess_User_Update', 
		@database_name=N'mi_custom', 
		@output_file_name=N'D:\MSSQL\MSSQL.1\MSSQL\JOBS\cp_tblSSRS_SystemAccess_User_Update.txt', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule 1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111025, 
		@active_end_date=99991231, 
		@active_start_time=93000, 
		@active_end_time=235959, 
		@schedule_uid=N'57bd4bd2-d7a8-4ee3-9b1d-0e980fcca58d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule 2', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111025, 
		@active_end_date=99991231, 
		@active_start_time=160000, 
		@active_end_time=235959, 
		@schedule_uid=N'604ce03b-6ca7-4ef2-83d9-70aecde5b7a1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS_FldSvc_JobReassignmentNotification_Update]    Script Date: 11/30/2020 4:57:11 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 4:57:11 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SSRSData' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SSRSData'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS_FldSvc_JobReassignmentNotification_Update', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update tblSSRS_JobRecallNotificationLog table', 
		@category_name=N'SSRSData', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:11 PM ******/
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
/****** Object:  Step [run_SP]    Script Date: 11/30/2020 4:57:11 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run_SP', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec cp_SSRS_FldSvc_JobReassignmentNotification_Update', 
		@database_name=N'mi_custom', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule_SP_Run', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20090819, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'93ca8f35-fd1e-4ea9-8a28-167f62db15a4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS_Pop_JurisdictionandMailout]    Script Date: 11/30/2020 4:57:11 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 4:57:11 PM ******/
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
		@owner_login_name=N'PMS\svc_SQL2K8_Prod', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:11 PM ******/
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
		@command=N'
IF master.dbo.svf_AgReplicaState(''MASPROD'')=0 RAISERROR (''This is not the primary replica.'',2,1)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run ssis ssrs_Pop_tblSSRSjurisdiction]    Script Date: 11/30/2020 4:57:11 PM ******/
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
		@command=N'D:\Batch\exec_ssrs_Pop_tblSSRSjurisdiction.bat', 
		@output_file_name=N'X:\JobLogs\ssrs_Pop_tblSSRSjurisdiction.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run ssis ssrs_Pop_tblOpenCloseMailoutReports]    Script Date: 11/30/2020 4:57:11 PM ******/
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
		@command=N'D:\Batch\exec_ssrs_Pop_tblOpenCloseMailoutReports.bat', 
		@output_file_name=N'X:\JobLogs\ssrs_Pop_tblOpenCloseMailoutReports.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
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

/****** Object:  Job [SSRS_Pop_tblAgencyPermitStatus]    Script Date: 11/30/2020 4:57:11 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 4:57:11 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SSRSData' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SSRSData'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS_Pop_tblAgencyPermitStatus', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'SSRSData', 
		@owner_login_name=N'PMS\sqlmanjob', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:12 PM ******/
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
/****** Object:  Step [Execute Script]    Script Date: 11/30/2020 4:57:12 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute Script', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.cp_SSRS_ag_AgencyPermitStatusPOP', 
		@database_name=N'mi_custom', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20090602, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'2a2eb167-5716-4aff-8e5a-a5c2edb68b18'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS_tblSSRS_CellularAccounts_Update]    Script Date: 11/30/2020 4:57:12 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 4:57:12 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SSRSData' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SSRSData'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS_tblSSRS_CellularAccounts_Update', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'populates snapshot into table tblSSRS_CellularAccounts', 
		@category_name=N'SSRSData', 
		@owner_login_name=N'PMS\sqlmanjob', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:12 PM ******/
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
/****** Object:  Step [cp_ssrs_tblSSRS_CellularAccounts_Update]    Script Date: 11/30/2020 4:57:12 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'cp_ssrs_tblSSRS_CellularAccounts_Update', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_custom.dbo.cp_ssrs_tblSSRS_CellularAccounts_Update', 
		@database_name=N'mi_custom', 
		@output_file_name=N'D:\MSSQL\MSSQL.1\MSSQL\JOBS\cp_ssrs_tblSSRS_CellularAccounts_Update.txt', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'last day of month', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=16, 
		@freq_recurrence_factor=1, 
		@active_start_date=20100105, 
		@active_end_date=99991231, 
		@active_start_time=234500, 
		@active_end_time=235959, 
		@schedule_uid=N'bd734cea-237a-4b37-bd60-416b2edbe258'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'today- once', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100105, 
		@active_end_date=99991231, 
		@active_start_time=234500, 
		@active_end_time=235959, 
		@schedule_uid=N'0d22f25d-173e-4ee6-b50d-0df16d11ba80'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [SSRS_tblSSRS_NoPermitNoPurchase]    Script Date: 11/30/2020 4:57:12 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SSRSData]    Script Date: 11/30/2020 4:57:12 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SSRSData' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SSRSData'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSRS_tblSSRS_NoPermitNoPurchase', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'SSRSData', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:12 PM ******/
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
/****** Object:  Step [Step 1]    Script Date: 11/30/2020 4:57:12 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec cp_SSRS_Operations_NoPermitNoPurchase_Update', 
		@database_name=N'mi_custom', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule 1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100209, 
		@active_end_date=99991231, 
		@active_start_time=63000, 
		@active_end_time=235959, 
		@schedule_uid=N'f6b60465-d3df-4358-8caf-513e369087b0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Task #999 (Mon to Bus) mi_masdb]    Script Date: 11/30/2020 4:57:12 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [MAS_BUS]    Script Date: 11/30/2020 4:57:13 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'MAS_BUS' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'MAS_BUS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Task #999 (Mon to Bus) mi_masdb', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Mon to Bus Transactions mi_masdb:  This job should only be enabled to run on ONE server in the replication loop.  In general we run this job on the ''Batch Processing Server''.', 
		@category_name=N'MAS_BUS', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not The Quit Reporting Success)]    Script Date: 11/30/2020 4:57:13 PM ******/
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
/****** Object:  Step [Start Task #999]    Script Date: 11/30/2020 4:57:13 PM ******/
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

/****** Object:  Job [Update LTE Info]    Script Date: 11/30/2020 4:57:13 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:13 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:13 PM ******/
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
/****** Object:  Step [Update LTE Info]    Script Date: 11/30/2020 4:57:13 PM ******/
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
		@active_start_date=20191202, 
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

/****** Object:  Job [Update mi_2gcell]    Script Date: 11/30/2020 4:57:13 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:57:13 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update mi_2gcell', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'mi_masdb Update mi_2gcell0', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:14 PM ******/
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
/****** Object:  Step [EXEC dbo.mi_ap_update_mi_2gcell]    Script Date: 11/30/2020 4:57:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC dbo.mi_ap_update_mi_2gcell', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_ap_update_mi_2gcell', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\srvalch01\masout\joblogs\HURRICANE_Update_mi_2gcell.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'mi_masdb update_mi_2gcell', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150120, 
		@active_end_date=99991231, 
		@active_start_time=83000, 
		@active_end_time=235959, 
		@schedule_uid=N'cc11dc9e-328f-4a6b-968b-24c38cac580f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Update PAP/Late Chr flag]    Script Date: 11/30/2020 4:57:14 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Processing]    Script Date: 11/30/2020 4:57:14 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Processing' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Processing'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update PAP/Late Chr flag', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'updates auto debit and late charge flags based on PAP status / balance', 
		@category_name=N'Processing', 
		@owner_login_name=N'BRINKS\gMtMSql_Prd$', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:14 PM ******/
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
/****** Object:  Step [Update Customers]    Script Date: 11/30/2020 4:57:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Customers', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_masdb.dbo.mi_ap_update_pap_flags', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\WP1NAS01\SQLBACKUP\WP1MASINST02\JOBLOG\JobLog\UpdatePAPLateFlags.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Regular', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20090324, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'70c39e54-2617-45d4-8546-59b7cef86141'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Update System Config From Zones]    Script Date: 11/30/2020 4:57:14 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:14 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update System Config From Zones', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'mymoni', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Insert New System Config Rows]    Script Date: 11/30/2020 4:57:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Insert New System Config Rows', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [mi_masdb].dbo.[mi_ap_update_system_config_from_zone]', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'NightlySystemConfigUpdate', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200809, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e5767518-705d-45bd-80b5-59bce405b995'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [update_2gexclusions]    Script Date: 11/30/2020 4:57:15 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:57:15 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'update_2gexclusions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This procedure looks at "open" (NULL status) 2G accounts in the mi_2gcell table and handles
    new exclusions and former exclusions.

    New exclusions, i.e. accounts not in the ''hijack'' campaign that now have an exclusion, are
    moved to the hijack campaign.

    Former exclusions, i.e. accounts in the ''hijack'' campaign that no longer have an exclusion,
    are moved to the appropriate naildown campaign (group10x).', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:15 PM ******/
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
/****** Object:  Step [step_mi_ap_update_2gexclusions]    Script Date: 11/30/2020 4:57:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'step_mi_ap_update_2gexclusions', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.mi_ap_update_2gexclusions @servarea_campaign=''group998''', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\srvalch01\MASOut\JobLogs\HURRICANE_update_2gexclusions_log.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monday_0845', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20160328, 
		@active_end_date=99991231, 
		@active_start_time=84500, 
		@active_end_time=235959, 
		@schedule_uid=N'1eecfe90-32f8-4f58-8fb7-151ffa80ff3c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [UpdateGreenSkyJobs]    Script Date: 11/30/2020 4:57:15 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/30/2020 4:57:15 PM ******/
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
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:15 PM ******/
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
/****** Object:  Step [Update GreenSky jobs]    Script Date: 11/30/2020 4:57:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update GreenSky jobs', 
		@step_id=2, 
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
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
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

/****** Object:  Job [UpdateRecurAccelAmt]    Script Date: 11/30/2020 4:57:15 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Processing]    Script Date: 11/30/2020 4:57:15 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Processing' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Processing'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'UpdateRecurAccelAmt', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Executes mi_ap_update_recur_accelamt Daily', 
		@category_name=N'Processing', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:15 PM ******/
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
/****** Object:  Step [Run mi_ap_update_recur_accelamt]    Script Date: 11/30/2020 4:57:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run mi_ap_update_recur_accelamt', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC mi_ap_update_recur_accelamt', 
		@database_name=N'mi_masdb', 
		@output_file_name=N'\\wp1nas01\SQLBackup\WP1MASINST02\BackupWP1MASINST02\JobLog\mi_ap_update_recur_accelamt.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20101020, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'e0313ab2-921b-4810-b019-2a17605bb014'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [WSI_Data_Clean_Up]    Script Date: 11/30/2020 4:57:15 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [ExternalAppSupport]    Script Date: 11/30/2020 4:57:15 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'ExternalAppSupport' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'ExternalAppSupport'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'WSI_Data_Clean_Up', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Vince created a mi_ap_purge_wsi_data procedure. It takes a parameter for the regular data that defaults to 24 hours, another parameter for the saved data that defaults to 31 days, and a third parameter to override internal limits on the first two parameters. If the first parameter is less than 6 hours, or the second parameter is less than 10 days, then the third parameter has to be a Y, otherwise an error is generated and nothing happens.
', 
		@category_name=N'ExternalAppSupport', 
		@owner_login_name=N'MONI\gMtMSql_Prd$', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check If AG Primary (If Not Then Quit Reporting Success)]    Script Date: 11/30/2020 4:57:16 PM ******/
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
/****** Object:  Step [Cleanup WSI data]    Script Date: 11/30/2020 4:57:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cleanup WSI data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec mi_wsip_cleanup_wsi_data', 
		@database_name=N'mi_custom', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110419, 
		@active_end_date=99991231, 
		@active_start_time=20500, 
		@active_end_time=235959, 
		@schedule_uid=N'7c2a6d98-7a42-4b8e-87d5-8d815226573c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

