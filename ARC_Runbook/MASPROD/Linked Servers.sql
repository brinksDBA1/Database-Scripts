USE [master]
GO

/****** Object:  LinkedServer [ADSI]    Script Date: 11/30/2020 4:58:20 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'ADSI', @srvproduct=N'Active Directory Service Interfaces', @provider=N'ADSDSOObject', @datasrc=N'pms.monitronics.pvt'
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

/****** Object:  LinkedServer [ODSPROD]    Script Date: 11/30/2020 4:58:20 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'ODSPROD', @srvproduct=N'SQL', @provider=N'SQLNCLI', @datasrc=N'ODSPROD,4275'
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

/****** Object:  LinkedServer [SQL2]    Script Date: 11/30/2020 4:58:20 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SQL2', @srvproduct=N'SQL', @provider=N'SQLNCLI', @datasrc=N'SQL2'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SQL2',@useself=N'False',@locallogin=NULL,@rmtuser=N'Link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SQL2', @optname=N'rpc out', @optvalue=N'true'
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

/****** Object:  LinkedServer [SQL3]    Script Date: 11/30/2020 4:58:20 PM ******/
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

EXEC master.dbo.sp_serveroption @server=N'SQL3', @optname=N'rpc out', @optvalue=N'false'
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

/****** Object:  LinkedServer [SRVODS03]    Script Date: 11/30/2020 4:58:20 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SRVODS03', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'SRVODS03,4275'
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

/****** Object:  LinkedServer [SRVODS03V2]    Script Date: 11/30/2020 4:58:20 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SRVODS03V2', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'SRVODS03V2\INST2'
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

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SRVODS03V2', @optname=N'rpc out', @optvalue=N'false'
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

/****** Object:  LinkedServer [VERTEXPRODA]    Script Date: 11/30/2020 4:58:20 PM ******/
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

/****** Object:  LinkedServer [VERTEXPRODB]    Script Date: 11/30/2020 4:58:20 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'VERTEXPRODB', @srvproduct=N'SQL', @provider=N'SQLNCLI11', @datasrc=N'VERTEXPRODB'
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

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'VERTEXPRODB', @optname=N'rpc out', @optvalue=N'false'
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

/****** Object:  LinkedServer [WP1SQL02]    Script Date: 11/30/2020 4:58:20 PM ******/
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

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WP1SQL02', @optname=N'rpc out', @optvalue=N'true'
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

/****** Object:  LinkedServer [WP1SQLCL02]    Script Date: 11/30/2020 4:58:21 PM ******/
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

/****** Object:  LinkedServer [WPSITSQL01]    Script Date: 11/30/2020 4:58:21 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'WPSITSQL01', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'WPSITSQL01,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'WPSITSQL01',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSITSQL01', @optname=N'sub', @optvalue=N'false'
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

/****** Object:  LinkedServer [WPSTGSQL01]    Script Date: 11/30/2020 4:58:21 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'WPSTGSQL01', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'WPSTGSQL01,4275'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'WPSTGSQL01',@useself=N'False',@locallogin=NULL,@rmtuser=N'link_ro',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'WPSTGSQL01', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

