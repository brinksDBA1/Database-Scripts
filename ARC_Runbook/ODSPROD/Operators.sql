USE [msdb]
GO

/****** Object:  Operator [AppSupport]    Script Date: 11/30/2020 5:06:35 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'AppSupport', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'AppSupport@monitronics.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [Brundige]    Script Date: 11/30/2020 5:06:35 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'Brundige', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'mbrundige@mymoni.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [DBA]    Script Date: 11/30/2020 5:06:35 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'DBA', 
		@enabled=1, 
		@weekday_pager_start_time=0, 
		@weekday_pager_end_time=235959, 
		@saturday_pager_start_time=0, 
		@saturday_pager_end_time=235959, 
		@sunday_pager_start_time=0, 
		@sunday_pager_end_time=235959, 
		@pager_days=127, 
		@email_address=N'dbateam@monitronics.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [SAM]    Script Date: 11/30/2020 5:06:35 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'SAM', 
		@enabled=1, 
		@weekday_pager_start_time=0, 
		@weekday_pager_end_time=235959, 
		@saturday_pager_start_time=0, 
		@saturday_pager_end_time=235959, 
		@sunday_pager_start_time=0, 
		@sunday_pager_end_time=235959, 
		@pager_days=127, 
		@email_address=N'DBATeam@monitronics.com;sam@monitronics.com;servicedeskteam@monitronics.com;AppSupport@monitronics.c', 
		@category_name=N'[Uncategorized]'
GO

