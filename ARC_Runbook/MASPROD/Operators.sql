USE [msdb]
GO

/****** Object:  Operator [Brundige]    Script Date: 11/30/2020 4:57:44 PM ******/
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

/****** Object:  Operator [DBA]    Script Date: 11/30/2020 4:57:44 PM ******/
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

/****** Object:  Operator [Jeff Coleman]    Script Date: 11/30/2020 4:57:44 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'Jeff Coleman', 
		@enabled=1, 
		@weekday_pager_start_time=80000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=80000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=80000, 
		@sunday_pager_end_time=180000, 
		@pager_days=62, 
		@email_address=N'jcoleman@monitronics.com', 
		@category_name=N'[Uncategorized]'
GO

