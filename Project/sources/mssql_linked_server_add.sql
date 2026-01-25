EXEC master.dbo.sp_addlinkedserver @server = N'PG1', @srvproduct=N'', @provider=N'MSDASQL', @provstr=N'Driver={PostgreSQL Unicode(x64)};Server=192.168.10.158;Port=5432;Database=otusproject;UID=********;PWD=*******'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'PG1',@useself=N'False',@locallogin=NULL,@rmtuser=N'********',@rmtpassword='########'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'collation compatible', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'data access', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'dist', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'pub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'rpc', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'rpc out', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'sub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'connect timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'collation name', @optvalue=null
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'lazy schema validation', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'query timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'use remote collation', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'PG1', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO
