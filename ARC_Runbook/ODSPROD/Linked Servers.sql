USE [master]
GO

/****** Object:  LinkedServer [ADSI]    Script Date: 11/30/2020 5:07:00 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'ADSI', @srvproduct=N'Active Directory Service Interfaces', @provider=N'ADsDSOObject', @datasrc=N'pms.monitronics.pvt'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'ADSI',@useself=N'False',@locallogin=NULL,@rmtuser=N'PMS\svc_SQL2K8_Prod',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [ADSITest]    Script Date: 11/30/2020 5:07:00 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'ADSITest', @srvproduct=N'Active Directory Service Interfaces', @provider=N'ADsDSOObject', @datasrc=N'pms.monitronics.pvt'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'ADSITest',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ADSITest', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [CHAPLIN]    Script Date: 11/30/2020 5:07:00 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'CHAPLIN', @srvproduct=N'SQL', @provider=N'SQLNCLI', @datasrc=N'CHAPLIN,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'CHAPLIN',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'CHAPLIN', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [MASF]    Script Date: 11/30/2020 5:07:01 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'MASF', @srvproduct=N'SQL', @provider=N'SQLNCLI11', @datasrc=N'MASF'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'MASF',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MASF', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [MASPROD]    Script Date: 11/30/2020 5:07:01 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'MASPROD', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'MASPROD,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'MASPROD',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MASPROD', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [NORADTOO]    Script Date: 11/30/2020 5:07:01 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'NORADTOO', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'NORADTOO',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'NORADTOO', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [ODSPROD]    Script Date: 11/30/2020 5:07:01 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'ODSPROD', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'ODSPROD,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'ODSPROD',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'ODSPROD', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [repl_distributor]    Script Date: 11/30/2020 5:07:01 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'repl_distributor', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'repl_distributor',@useself=N'False',@locallogin=NULL,@rmtuser=N'distributor_admin',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'data access', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'dist', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'repl_distributor', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [SQL2]    Script Date: 11/30/2020 5:07:01 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SQL2', @srvproduct=N'SQL', @provider=N'SQLNCLI11', @datasrc=N'SQL2'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SQL2',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [SQL3]    Script Date: 11/30/2020 5:07:01 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SQL3', @srvproduct=N'', @provider=N'MSDASQL', @provstr=N'DRIVER={SQL Server};SERVER=SQL3;uid=link_ro;Password=m0nitr0nics;'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SQL3',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [SRVODS03]    Script Date: 11/30/2020 5:07:02 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SRVODS03', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SRVODS03',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [SRVODS03V2]    Script Date: 11/30/2020 5:07:02 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SRVODS03V2', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'SRVODS03V2,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SRVODS03V2',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [VERTEXPRODA]    Script Date: 11/30/2020 5:07:02 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'VERTEXPRODA', @srvproduct=N'SQL', @provider=N'SQLNCLI11', @datasrc=N'VERTEXPRODA'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'VERTEXPRODA',@useself=N'False',@locallogin=NULL,@rmtuser=N'vertex_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODA', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [VERTEXPRODB]    Script Date: 11/30/2020 5:07:02 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'VERTEXPRODB', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'VERTEXPRODB',@useself=N'False',@locallogin=NULL,@rmtuser=N'vertex_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [VV1ODSINST01]    Script Date: 11/30/2020 5:07:02 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'VV1ODSINST01', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'VV1ODSINST01,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'VV1ODSINST01',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'VV1ODSINST01', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [WP1SQL02]    Script Date: 11/30/2020 5:07:02 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'WP1SQL02', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'WP1SQL02,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'WP1SQL02',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [WP1SQLCL02]    Script Date: 11/30/2020 5:07:03 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'WP1SQLCL02', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'WP1SQLCL02,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'WP1SQLCL02',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQLCL02', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [WPSITSQL01]    Script Date: 11/30/2020 5:07:03 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'WPSITSQL01', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'WPSITSQL01',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'data access', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'sub', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

