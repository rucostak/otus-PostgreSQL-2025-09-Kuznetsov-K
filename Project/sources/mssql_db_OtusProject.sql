CREATE DATABASE [OtusProject]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'OtusProject', FILENAME = N'D:\SQL\MSSQL12.A\MSSQL\DATA\OtusProject.mdf' , SIZE = 131072KB, MAXSIZE = UNLIMITED, FILEGROWTH = 131072KB )
 LOG ON 
( NAME = N'OtusProject_log', FILENAME = N'E:\SQL\MSSQL12.A\MSSQL\Data\OtusProject_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 131072KB )
 COLLATE Cyrillic_General_CI_AS
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [OtusProject] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [OtusProject].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [OtusProject] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [OtusProject] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [OtusProject] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [OtusProject] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [OtusProject] SET ARITHABORT OFF 
GO
ALTER DATABASE [OtusProject] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [OtusProject] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [OtusProject] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [OtusProject] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [OtusProject] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [OtusProject] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [OtusProject] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [OtusProject] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [OtusProject] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [OtusProject] SET  DISABLE_BROKER 
GO
ALTER DATABASE [OtusProject] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [OtusProject] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [OtusProject] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [OtusProject] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [OtusProject] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [OtusProject] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [OtusProject] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [OtusProject] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [OtusProject] SET  MULTI_USER 
GO
ALTER DATABASE [OtusProject] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [OtusProject] SET DB_CHAINING OFF 
GO
ALTER DATABASE [OtusProject] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [OtusProject] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [OtusProject] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [OtusProject] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'OtusProject', N'ON'
GO
ALTER DATABASE [OtusProject] SET QUERY_STORE = OFF
GO
CREATE USER [tester] FOR LOGIN [tester] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [tester]
GO
GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [public] AS [dbo]
GO
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [public] AS [dbo]
GO
GRANT CONNECT TO [tester] AS [dbo]
GO
USE [OtusProject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document](
	[ID] [uniqueidentifier] NOT NULL,
	[DocTypeID] [uniqueidentifier] NOT NULL,
	[StateID] [uniqueidentifier] NULL,
	[Origin] [nvarchar](3) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[Modified] [datetimeoffset](0) NOT NULL,
	[ModifiedBy] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
 CONSTRAINT [PK_Document] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechnicalAct](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Number] [nvarchar](64) COLLATE Cyrillic_General_CI_AS NULL,
	[Date] [datetimeoffset](0) NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[TenantryID] [uniqueidentifier] NOT NULL,
	[CargoID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_TechnicalAct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Enum](
	[ID] [uniqueidentifier] NOT NULL,
	[ParentID] [uniqueidentifier] NULL,
	[Ordinal] [int] NULL,
	[NameRus] [nvarchar](255) COLLATE Cyrillic_General_CI_AS NULL,
	[NameEng] [nvarchar](255) COLLATE Cyrillic_General_CI_AS NULL,
 CONSTRAINT [PK_Enum] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Enum_ParentID_Ordinal] UNIQUE NONCLUSTERED 
(
	[ParentID] ASC,
	[Ordinal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentErrorDataLog](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[DocumentID] [uniqueidentifier] NOT NULL,
	[RecordID] [uniqueidentifier] NOT NULL,
	[Attribute] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[Level] [int] NOT NULL,
	[Message] [nvarchar](2044) COLLATE Cyrillic_General_CI_AS NULL,
	[ErrorCode] [smallint] NOT NULL,
 CONSTRAINT [PK_DocumentErrorDataLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TechnicalAct_View] AS
SELECT 
	t.[ID],
	d.[DocTypeID],
	d.[StateID],
	d.[Origin],
	e.[Ordinal] as [StateOrdinal],
	d.[Modified],
	d.[ModifiedBy],
	t.[Number],
	t.[Date],
	t.[OwnerID],
	t.[TenantryID],
	t.[CargoID]
FROM [dbo].[TechnicalAct] t
	INNER JOIN [dbo].[Document] d ON d.[ID] = t.[ID]
	INNER JOIN [dbo].[Enum] e ON d.[StateID] = e.[ID] AND e.[Ordinal] < 4
WHERE t.[ID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechnicalActVehicle](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[TechnicalActID] [uniqueidentifier] NOT NULL,
	[Number] [nvarchar](8) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[OriginalCountryID] [uniqueidentifier] NULL,
	[VehicleModelID] [uniqueidentifier] NOT NULL,
	[Capacity] [int] NULL,
	[TareWeight] [int] NULL,
	[Caliber] [int] NULL,
	[NextMaintenanceDate] [datetimeoffset](0) NULL,
	[MileageFlag] [bit] NOT NULL,
	[Ordinal] [int] NOT NULL,
	[NextOwnerRecertification] [datetimeoffset](0) NULL,
	[BuildDate] [datetimeoffset](0) NULL,
	[FactoryOfOriginID] [uniqueidentifier] NULL,
	[EnvelopeModernizationDate] [datetimeoffset](0) NULL,
 CONSTRAINT [PK_TechnicalActVehicle] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TechnicalActVehicle_View] AS
SELECT 
	[ID],
	[TechnicalActID],
	[Number],
	[OriginalCountryID],
	[VehicleModelID],
	[Capacity],
	[TareWeight],
	[Caliber],
	[NextMaintenanceDate],
	[MileageFlag],
	[Ordinal],
	[NextOwnerRecertification],
	[BuildDate],
	[FactoryOfOriginID],
	[EnvelopeModernizationDate]
FROM [dbo].[TechnicalActVehicle]
WHERE [ID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
	AND [TechnicalActID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechnicalData](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SourceID] [uniqueidentifier] NOT NULL,
	[Date] [datetimeoffset](0) NOT NULL,
 CONSTRAINT [PK_TechnicalData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TechnicalData_View] AS
SELECT 
	t.[ID],
	d.[DocTypeID],
	d.[StateID],
	d.[Origin],
	e.[Ordinal] as [StateOrdinal],
	d.[Modified],
	d.[ModifiedBy],
	t.[SourceID],
	t.[Date]
FROM [dbo].[TechnicalData] t
	INNER JOIN [dbo].[Document] d ON d.[ID] = t.[ID]
	INNER JOIN [dbo].[Enum] e ON d.[StateID] = e.[ID] AND e.[Ordinal] < 4
WHERE t.[ID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechnicalDataVehicle](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[TechnicalDataID] [uniqueidentifier] NOT NULL,
	[Number] [nvarchar](8) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[OriginalCountryID] [uniqueidentifier] NULL,
	[Capacity] [int] NULL,
	[TareWeight] [int] NULL,
	[Caliber] [int] NULL,
	[NextMaintenanceDate] [datetimeoffset](0) NULL,
	[MileageFlag] [bit] NULL,
	[Mileage] [int] NULL,
	[NextOwnerRecertification] [datetimeoffset](0) NULL,
	[Ordinal] [int] NOT NULL,
	[MaintenanceAgreement] [nvarchar](255) COLLATE Cyrillic_General_CI_AS NULL,
	[VehicleModelID] [uniqueidentifier] NULL,
	[NextCoatingDate] [datetimeoffset](0) NULL,
	[EnvelopeModernizationDate] [datetimeoffset](0) NULL,
 CONSTRAINT [PK_TechnicalDataVehicle] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TechnicalDataVehicle_View] AS
SELECT 
	[ID],
	[TechnicalDataID],
	[Number],
	[OriginalCountryID],
	[Capacity],
	[TareWeight],
	[Caliber],
	[NextMaintenanceDate],
	[MileageFlag],
	[Mileage],
	[NextOwnerRecertification],
	[Ordinal],
	[MaintenanceAgreement],
	[VehicleModelID],
	[NextCoatingDate],
	[EnvelopeModernizationDate]
FROM [dbo].[TechnicalDataVehicle]
WHERE [ID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
	AND [TechnicalDataID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeaseAct](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Number] [nvarchar](64) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[Date] [datetimeoffset](0) NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[TenantryID] [uniqueidentifier] NOT NULL,
	[CargoID] [uniqueidentifier] NOT NULL,
	[ByOwnerChange] [bit] NULL,
	[LeaseContractID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_LeaseAct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LeaseAct_View] AS
SELECT 
	t.[ID],
	d.[DocTypeID],
	d.[StateID],
	d.[Origin],
	e.[Ordinal] as [StateOrdinal],
	d.[Modified],
	d.[ModifiedBy],
	t.[Number],
	t.[Date],
	t.[OwnerID],
	t.[TenantryID],
	t.[CargoID],
	t.[ByOwnerChange],
	t.[LeaseContractID]
FROM [dbo].[LeaseAct] t
	INNER JOIN [dbo].[Document] d ON d.[ID] = t.[ID]
	INNER JOIN [dbo].[Enum] e ON d.[StateID] = e.[ID] AND e.[Ordinal] < 4
WHERE t.[ID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeaseActVehicle](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[LeaseActID] [uniqueidentifier] NOT NULL,
	[Ordinal] [int] NOT NULL,
	[Number] [nvarchar](8) COLLATE Cyrillic_General_CI_AS NOT NULL,
 CONSTRAINT [PK_LeaseActVehicle] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LeaseActVehicle_View] AS
SELECT 
	[ID],
	[LeaseActID],
	[Ordinal],
	[Number]
FROM [dbo].[LeaseActVehicle]
WHERE [ID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
	AND [LeaseActID] NOT IN (SELECT [RecordID] FROM [dbo].[DocumentErrorDataLog] WHERE [Level] = 2)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cachetechinfohist](
	[ID] [uniqueidentifier] NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[TenantryID] [uniqueidentifier] NULL,
	[CargoID] [uniqueidentifier] NULL,
	[TechnicalDataSourceID] [uniqueidentifier] NULL,
	[VehicleID] [uniqueidentifier] NOT NULL,
	[VehicleNumber] [nvarchar](8) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[DocumentNumber] [nvarchar](64) COLLATE Cyrillic_General_CI_AS NULL,
	[OriginalCountryID] [uniqueidentifier] NULL,
	[VehicleModelID] [uniqueidentifier] NULL,
	[Capacity] [int] NULL,
	[TareWeight] [int] NULL,
	[Caliber] [int] NULL,
	[NextMaintenanceDate] [datetimeoffset](0) NULL,
	[MileageFlag] [bit] NULL,
	[Mileage] [int] NULL,
	[NextOwnerRecertification] [datetimeoffset](0) NULL,
	[BuildDate] [datetimeoffset](0) NULL,
	[FactoryOfOriginID] [uniqueidentifier] NULL,
	[MaintenanceAgreement] [nvarchar](255) COLLATE Cyrillic_General_CI_AS NULL,
	[DateFrom] [datetimeoffset](0) NOT NULL,
	[DateTill] [datetimeoffset](0) NOT NULL,
	[DocTypeID] [uniqueidentifier] NOT NULL,
	[TechnicalActID] [uniqueidentifier] NULL,
	[TechnicalActVehicleID] [uniqueidentifier] NULL,
	[FieldsUpdatedDocumentVehicleID] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[OrdinalFrom] [int] NOT NULL,
	[NextCoatingDate] [datetimeoffset](0) NULL,
	[EnvelopeModernizationDate] [datetimeoffset](0) NULL,
 CONSTRAINT [PK_cachetechinfohist] PRIMARY KEY CLUSTERED 
(
	[VehicleNumber] ASC,
	[OrdinalFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentErrorType](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ErrorCode] [smallint] NOT NULL,
	[Description] [nvarchar](1000) COLLATE Cyrillic_General_CI_AS NULL,
	[Level] [tinyint] NOT NULL,
	[DateFrom] [smalldatetime] NOT NULL,
	[DateTill] [smalldatetime] NULL,
	[DocumentTypeOrder]  AS (CONVERT([smallint],[ErrorCode]/(100))) PERSISTED,
 CONSTRAINT [PK_DocumentErrorType] PRIMARY KEY CLUSTERED 
(
	[ErrorCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_DocumentErrorType] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentType](
	[ID] [uniqueidentifier] NOT NULL,
	[Order] [smallint] NULL,
	[NameRus] [nvarchar](127) COLLATE Cyrillic_General_CI_AS NULL,
	[NameEng] [nvarchar](127) COLLATE Cyrillic_General_CI_AS NULL,
	[NameClass] [nvarchar](48) COLLATE Cyrillic_General_CI_AS NULL,
	[TableName] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NULL,
	[ChildTableName] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NULL,
 CONSTRAINT [PK_DocumentType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_DocumentType_Order] UNIQUE NONCLUSTERED 
(
	[Order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechnicalDataSource](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[NameEng] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[NameRus] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
 CONSTRAINT [PK_TechnicalDataSource] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_cachetechinfohist_VehicleID] ON [dbo].[cachetechinfohist]
(
	[VehicleID] ASC
)
INCLUDE([DateFrom]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_cachetechinfohist_VehicleNumber_DateFrom_DateTill] ON [dbo].[cachetechinfohist]
(
	[VehicleNumber] ASC,
	[DateFrom] ASC,
	[DateTill] ASC
)
INCLUDE([OwnerID],[VehicleModelID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Document_DocTypeID] ON [dbo].[Document]
(
	[DocTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Document_Modified] ON [dbo].[Document]
(
	[Modified] ASC
)
INCLUDE([ModifiedBy]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Document_StateID] ON [dbo].[Document]
(
	[StateID] ASC
)
INCLUDE([Origin]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorDataLog_Attribute] ON [dbo].[DocumentErrorDataLog]
(
	[Attribute] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorDataLog_DocumentID] ON [dbo].[DocumentErrorDataLog]
(
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorDataLog_ErrorCode] ON [dbo].[DocumentErrorDataLog]
(
	[ErrorCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorDataLog_Level] ON [dbo].[DocumentErrorDataLog]
(
	[Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorDataLog_Level_RecordID] ON [dbo].[DocumentErrorDataLog]
(
	[Level] ASC
)
INCLUDE([RecordID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorDataLog_Level_RecordID_Critical] ON [dbo].[DocumentErrorDataLog]
(
	[Level] ASC,
	[RecordID] ASC
)
WHERE ([Level]=(2))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorDataLog_RecordID] ON [dbo].[DocumentErrorDataLog]
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
CREATE NONCLUSTERED INDEX [IX_DocumentErrorType_DocumentTypeOrder] ON [dbo].[DocumentErrorType]
(
	[DocumentTypeOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_DocumentType_ChildTableName] ON [dbo].[DocumentType]
(
	[ChildTableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_DocumentType_NameClass] ON [dbo].[DocumentType]
(
	[NameClass] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_DocumentType_TableName] ON [dbo].[DocumentType]
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Enum_Ordinal] ON [dbo].[Enum]
(
	[Ordinal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Enum_ParentID] ON [dbo].[Enum]
(
	[ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LeaseAct_ByOwnerChange] ON [dbo].[LeaseAct]
(
	[ByOwnerChange] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LeaseAct_CargoID] ON [dbo].[LeaseAct]
(
	[CargoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LeaseAct_Date] ON [dbo].[LeaseAct]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LeaseAct_LeaseContractID] ON [dbo].[LeaseAct]
(
	[LeaseContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_LeaseAct_Number] ON [dbo].[LeaseAct]
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LeaseAct_OwnerID] ON [dbo].[LeaseAct]
(
	[OwnerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LeaseAct_TenantryID] ON [dbo].[LeaseAct]
(
	[TenantryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LeaseActVehicle_LeaseActID] ON [dbo].[LeaseActVehicle]
(
	[LeaseActID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_LeaseActVehicle_Number] ON [dbo].[LeaseActVehicle]
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalAct_CargoID] ON [dbo].[TechnicalAct]
(
	[CargoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalAct_Date] ON [dbo].[TechnicalAct]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalAct_OwnerID] ON [dbo].[TechnicalAct]
(
	[OwnerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalAct_TenantryID] ON [dbo].[TechnicalAct]
(
	[TenantryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalActVehicle_BuildDate] ON [dbo].[TechnicalActVehicle]
(
	[BuildDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalActVehicle_FactoryOfOriginID] ON [dbo].[TechnicalActVehicle]
(
	[FactoryOfOriginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalActVehicle_Number] ON [dbo].[TechnicalActVehicle]
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalActVehicle_OriginalCountryID] ON [dbo].[TechnicalActVehicle]
(
	[OriginalCountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalActVehicle_TechnicalActID] ON [dbo].[TechnicalActVehicle]
(
	[TechnicalActID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalActVehicle_VehicleModelID] ON [dbo].[TechnicalActVehicle]
(
	[VehicleModelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalData_Date] ON [dbo].[TechnicalData]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalData_SourceID] ON [dbo].[TechnicalData]
(
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TechnicalDataSource_NameEng_NameRus] ON [dbo].[TechnicalDataSource]
(
	[NameEng] ASC,
	[NameRus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalDataVehicle_Number] ON [dbo].[TechnicalDataVehicle]
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalDataVehicle_OriginalCountryID] ON [dbo].[TechnicalDataVehicle]
(
	[OriginalCountryID] ASC
)
WHERE ([OriginalCountryID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalDataVehicle_TechnicalDataID] ON [dbo].[TechnicalDataVehicle]
(
	[TechnicalDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TechnicalDataVehicle_VehicleModelID] ON [dbo].[TechnicalDataVehicle]
(
	[VehicleModelID] ASC
)
WHERE ([VehicleModelID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_Modified]  DEFAULT (sysdatetimeoffset()) FOR [Modified]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_ModifiedBy]  DEFAULT (suser_sname()) FOR [ModifiedBy]
GO
ALTER TABLE [dbo].[DocumentErrorDataLog] ADD  CONSTRAINT [DF_DocumentErrorDataLog_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[DocumentErrorType] ADD  CONSTRAINT [DF_DocumentErrorType_ID]  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[DocumentType] ADD  CONSTRAINT [DF_DocumentType_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Enum] ADD  CONSTRAINT [DF_Enum_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[LeaseAct] ADD  CONSTRAINT [DF_LeaseAct_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[LeaseActVehicle] ADD  CONSTRAINT [DF_LeaseActVehicle_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TechnicalAct] ADD  CONSTRAINT [DF_TechnicalAct_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TechnicalActVehicle] ADD  CONSTRAINT [DF_TechnicalActVehicle_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TechnicalActVehicle] ADD  CONSTRAINT [DF_TechnicalActVehicle_MileageFlag]  DEFAULT ((0)) FOR [MileageFlag]
GO
ALTER TABLE [dbo].[TechnicalData] ADD  CONSTRAINT [DF_TechnicalData_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TechnicalDataSource] ADD  CONSTRAINT [DF_TechnicalDataSource_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TechnicalDataVehicle] ADD  CONSTRAINT [DF_TechnicalDataVehicle_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_DocumentType] FOREIGN KEY([DocTypeID])
REFERENCES [dbo].[DocumentType] ([ID])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_DocumentType]
GO
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_Enum] FOREIGN KEY([StateID])
REFERENCES [dbo].[Enum] ([ID])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_Enum]
GO
ALTER TABLE [dbo].[DocumentErrorDataLog]  WITH CHECK ADD  CONSTRAINT [FK_DocumentErrorDataLog_DocumentErrorType] FOREIGN KEY([ErrorCode])
REFERENCES [dbo].[DocumentErrorType] ([ErrorCode])
GO
ALTER TABLE [dbo].[DocumentErrorDataLog] CHECK CONSTRAINT [FK_DocumentErrorDataLog_DocumentErrorType]
GO
ALTER TABLE [dbo].[DocumentErrorType]  WITH CHECK ADD  CONSTRAINT [FK_DocumentErrorType_DocumentType] FOREIGN KEY([DocumentTypeOrder])
REFERENCES [dbo].[DocumentType] ([Order])
GO
ALTER TABLE [dbo].[DocumentErrorType] CHECK CONSTRAINT [FK_DocumentErrorType_DocumentType]
GO
ALTER TABLE [dbo].[Enum]  WITH CHECK ADD  CONSTRAINT [FK_Enum_Enum_ParentID_ID] FOREIGN KEY([ParentID])
REFERENCES [dbo].[Enum] ([ID])
GO
ALTER TABLE [dbo].[Enum] CHECK CONSTRAINT [FK_Enum_Enum_ParentID_ID]
GO
ALTER TABLE [dbo].[LeaseAct]  WITH CHECK ADD  CONSTRAINT [FK_LeaseAct_Document] FOREIGN KEY([ID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[LeaseAct] CHECK CONSTRAINT [FK_LeaseAct_Document]
GO
ALTER TABLE [dbo].[LeaseActVehicle]  WITH CHECK ADD  CONSTRAINT [FK_LeaseActVehicle_LeaseAct] FOREIGN KEY([LeaseActID])
REFERENCES [dbo].[LeaseAct] ([ID])
GO
ALTER TABLE [dbo].[LeaseActVehicle] CHECK CONSTRAINT [FK_LeaseActVehicle_LeaseAct]
GO
ALTER TABLE [dbo].[TechnicalAct]  WITH CHECK ADD  CONSTRAINT [FK_TechnicalAct_Document] FOREIGN KEY([ID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[TechnicalAct] CHECK CONSTRAINT [FK_TechnicalAct_Document]
GO
ALTER TABLE [dbo].[TechnicalActVehicle]  WITH CHECK ADD  CONSTRAINT [FK_TechnicalActVehicle_TechnicalAct] FOREIGN KEY([TechnicalActID])
REFERENCES [dbo].[TechnicalAct] ([ID])
GO
ALTER TABLE [dbo].[TechnicalActVehicle] CHECK CONSTRAINT [FK_TechnicalActVehicle_TechnicalAct]
GO
ALTER TABLE [dbo].[TechnicalData]  WITH CHECK ADD  CONSTRAINT [FK_TechnicalData_Document] FOREIGN KEY([ID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[TechnicalData] CHECK CONSTRAINT [FK_TechnicalData_Document]
GO
ALTER TABLE [dbo].[TechnicalData]  WITH CHECK ADD  CONSTRAINT [FK_TechnicalData_TechnicalDataSource] FOREIGN KEY([SourceID])
REFERENCES [dbo].[TechnicalDataSource] ([ID])
GO
ALTER TABLE [dbo].[TechnicalData] CHECK CONSTRAINT [FK_TechnicalData_TechnicalDataSource]
GO
ALTER TABLE [dbo].[TechnicalDataVehicle]  WITH CHECK ADD  CONSTRAINT [FK_TechnicalDataVehicle_TechnicalData] FOREIGN KEY([TechnicalDataID])
REFERENCES [dbo].[TechnicalData] ([ID])
GO
ALTER TABLE [dbo].[TechnicalDataVehicle] CHECK CONSTRAINT [FK_TechnicalDataVehicle_TechnicalData]
GO
ALTER TABLE [dbo].[DocumentErrorDataLog]  WITH CHECK ADD  CONSTRAINT [CK_DocumentErrorDataLog_Level] CHECK  (([Level]>=(1) AND [Level]<=(2)))
GO
ALTER TABLE [dbo].[DocumentErrorDataLog] CHECK CONSTRAINT [CK_DocumentErrorDataLog_Level]
GO
ALTER TABLE [dbo].[TechnicalDataVehicle]  WITH CHECK ADD  CONSTRAINT [CK_TechnicalDataVehicle_MileageFlag_Mileage] CHECK  (([MileageFlag]=(1) AND [Mileage] IS NOT NULL OR [MileageFlag] IS NULL AND [Mileage] IS NULL OR [MileageFlag]=(0) AND [Mileage] IS NULL))
GO
ALTER TABLE [dbo].[TechnicalDataVehicle] CHECK CONSTRAINT [CK_TechnicalDataVehicle_MileageFlag_Mileage]
GO
CREATE PROCEDURE [dbo].[CacheTechInfoHist_Calc] (@Vehicle nvarchar(8) = NULL, @SkipFieldsUpdated bit = 0, @SkipTechnicalData bit = 0, @SkipTechnicalDataMileageNextMaintenanceChange bit = 0)
AS
SET NOCOUNT ON

DECLARE @Infinity datetimeoffset(0), @ReturnResult bit, @sqlcmd nvarchar(max), @Guid0 uniqueidentifier
SET @Infinity = CAST('99991231' as datetimeoffset(0))
SET @SkipFieldsUpdated = COALESCE(@SkipFieldsUpdated, 0)
SET @SkipTechnicalData = COALESCE(@SkipTechnicalData, 0)
SET @SkipTechnicalDataMileageNextMaintenanceChange = COALESCE(@SkipTechnicalDataMileageNextMaintenanceChange, 0)
SET @Guid0 = '{00000000-0000-0000-0000-000000000000}'

IF OBJECT_ID(N'tempdb..#tich') IS NOT NULL
	DROP TABLE #tich

CREATE TABLE #tich (
	[ID] [uniqueidentifier] NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[TenantryID] [uniqueidentifier] NULL,
	[CargoID] [uniqueidentifier] NULL,
	[TechnicalDataSourceID] [uniqueidentifier] NULL,
	[DocumentVehicleID] [uniqueidentifier] NOT NULL,
	[DocumentVehicleNumber] [nvarchar](8) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[DocumentNumber] [nvarchar](64) COLLATE Cyrillic_General_CI_AS NULL,
	[OriginalCountryID] [uniqueidentifier] NULL,
	[VehicleModelID] [uniqueidentifier] NULL,
	[Capacity] [int] NULL,
	[TareWeight] [int] NULL,
	[Caliber] [int] NULL,
	[NextMaintenanceDate] [datetimeoffset](0) NULL,
	[MileageFlag] [bit] NULL,
	[Mileage] [int] NULL,
	[NextOwnerRecertification] [datetimeoffset](0) NULL,
	[BuildDate] [datetimeoffset](0) NULL,
	[FactoryOfOriginID] [uniqueidentifier] NULL,
	[MaintenanceAgreement] [nvarchar](255) COLLATE Cyrillic_General_CI_AS NULL,
	[NextCoatingDate] [datetimeoffset](0) NULL,
	[EnvelopeModernizationDate] [datetimeoffset](0) NULL,
	[DateFrom] [datetimeoffset](0) NOT NULL,
	[DateTill] [datetimeoffset](0) NOT NULL,
	[DocTypeID] [uniqueidentifier] NOT NULL,
	[TechnicalActID] [uniqueidentifier] NULL,
	[TechnicalActVehicleID] [uniqueidentifier] NULL,
	[Active] [bit] NOT NULL,
	[OriginalCountryID@DocumentVehicleID] [uniqueidentifier] NULL,
	[VehicleModelID@DocumentVehicleID] [uniqueidentifier] NULL,
	[Capacity@DocumentVehicleID] [uniqueidentifier] NULL,
	[TareWeight@DocumentVehicleID] [uniqueidentifier] NULL,
	[Caliber@DocumentVehicleID] [uniqueidentifier] NULL,
	[NextMaintenanceDate@DocumentVehicleID] [uniqueidentifier] NULL,
	[MileageFlag@DocumentVehicleID] [uniqueidentifier] NULL,
	[Mileage@DocumentVehicleID] [uniqueidentifier] NULL,
	[NextOwnerRecertification@DocumentVehicleID] [uniqueidentifier] NULL,
	[MaintenanceAgreement@DocumentVehicleID] [uniqueidentifier] NULL,
	[NextCoatingDate@DocumentVehicleID] [uniqueidentifier] NULL,
	[EnvelopeModernizationDate@DocumentVehicleID] [uniqueidentifier] NULL,
	[FieldsUpdated@DocumentVehicleID] [nvarchar](max) NULL,
	[OrdinalFrom] [int] IDENTITY(1, 1) NOT NULL,
	[OrdinalNext] as ([OrdinalFrom] + 1)
PRIMARY KEY CLUSTERED 
(
	[OrdinalFrom] ASC
))
	
SET @sqlcmd = N'CREATE INDEX [IX_#tich' + REPLACE(CAST(NEWID() as nvarchar(38)), N'-', N'') + N'] ON #tich
([OrdinalFrom], [DocumentVehicleNumber], [OrdinalNext], [Active])'

EXEC sp_executesql @sqlcmd

IF OBJECT_ID('tempdb..#RawDocs') IS NOT NULL
	DROP TABLE #RawDocs

CREATE TABLE #RawDocs (
	[ID] [uniqueidentifier] NOT NULL,
	[OwnerID] [uniqueidentifier] NULL,
	[TenantryID] [uniqueidentifier] NULL,
	[CargoID] [uniqueidentifier] NULL,
	[TechnicalDataSourceID] [uniqueidentifier] NULL,
	[DocumentVehicleID] [uniqueidentifier] NOT NULL,
	[DocumentVehicleNumber] [nvarchar](8) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[DocumentNumber] [nvarchar](64) COLLATE Cyrillic_General_CI_AS NULL,
	[OriginalCountryID] [uniqueidentifier] NULL,
	[VehicleModelID] [uniqueidentifier] NULL,
	[Capacity] [int] NULL,
	[TareWeight] [int] NULL,
	[Caliber] [int] NULL,
	[NextMaintenanceDate] [datetimeoffset](0) NULL,
	[MileageFlag] [bit] NULL,
	[Mileage] [int] NULL,
	[NextOwnerRecertification] [datetimeoffset](0) NULL,
	[BuildDate] [datetimeoffset](0) NULL,
	[FactoryOfOriginID] [uniqueidentifier] NULL,
	[MaintenanceAgreement] [nvarchar](255) COLLATE Cyrillic_General_CI_AS NULL,
	[NextCoatingDate] [datetimeoffset](0) NULL,
	[EnvelopeModernizationDate] [datetimeoffset](0) NULL,
	[DateFrom] [datetimeoffset](0) NOT NULL,
	[DateTill] [datetimeoffset](0) NULL,
	[DocTypeID] [uniqueidentifier] NOT NULL,
	[TechnicalActID] [uniqueidentifier] NULL,
	[TechnicalActVehicleID] [uniqueidentifier] NULL,
	[Active] [bit] NOT NULL,
	[OriginalCountryID@DocumentVehicleID] [uniqueidentifier] NULL,
	[VehicleModelID@DocumentVehicleID] [uniqueidentifier] NULL,
	[Capacity@DocumentVehicleID] [uniqueidentifier] NULL,
	[TareWeight@DocumentVehicleID] [uniqueidentifier] NULL,
	[Caliber@DocumentVehicleID] [uniqueidentifier] NULL,
	[NextMaintenanceDate@DocumentVehicleID] [uniqueidentifier] NULL,
	[MileageFlag@DocumentVehicleID] [uniqueidentifier] NULL,
	[Mileage@DocumentVehicleID] [uniqueidentifier] NULL,
	[NextOwnerRecertification@DocumentVehicleID] [uniqueidentifier] NULL,
	[MaintenanceAgreement@DocumentVehicleID] [uniqueidentifier] NULL,
	[NextCoatingDate@DocumentVehicleID] [uniqueidentifier] NULL,
	[EnvelopeModernizationDate@DocumentVehicleID] [uniqueidentifier] NULL
)

-- Register owner change
IF OBJECT_ID(N'tempdb..#LeaseAct') IS NOT NULL
	DROP TABLE #LeaseAct
CREATE TABLE #LeaseAct (
	[ID] [uniqueidentifier] NOT NULL,
	[DocTypeID] [uniqueidentifier] NOT NULL,
	[LeaseActVehicleID] [uniqueidentifier] NOT NULL,
	[LeaseActVehicleNumber] [nvarchar](8) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[LeaseActNumber] [nvarchar](64) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[Date] [datetimeoffset](0) NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[TenantryID] [uniqueidentifier] NOT NULL,
	[CargoID] [uniqueidentifier] NOT NULL,
	[ByOwnerChange] [bit] NULL
)

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': start'

INSERT INTO #RawDocs ([ID], [OwnerID], [TenantryID], [CargoID], [DocumentVehicleID], [DocumentVehicleNumber], [DocumentNumber],
	[OriginalCountryID], [VehicleModelID], [Capacity], [TareWeight], [Caliber], [NextMaintenanceDate], [MileageFlag],
	[NextOwnerRecertification], [BuildDate], [FactoryOfOriginID], [EnvelopeModernizationDate], [DateFrom], [DateTill], [DocTypeID], [TechnicalActID], [TechnicalActVehicleID], [Active],
	[OriginalCountryID@DocumentVehicleID], [VehicleModelID@DocumentVehicleID], [Capacity@DocumentVehicleID], [TareWeight@DocumentVehicleID],
	[Caliber@DocumentVehicleID], [NextMaintenanceDate@DocumentVehicleID], [MileageFlag@DocumentVehicleID],
	[NextOwnerRecertification@DocumentVehicleID], [EnvelopeModernizationDate@DocumentVehicleID])
	SELECT tav.[ID], tav.[OwnerID], tav.[TenantryID], tav.[CargoID], tawv.[ID] as [DocumentVehicleID],
		tawv.[Number] as [DocumentVehicleNumber], tav.[Number] as [DocumentNumber], tawv.[OriginalCountryID],
		tawv.[VehicleModelID], tawv.[Capacity], tawv.[TareWeight], tawv.[Caliber],
		CASE @SkipTechnicalDataMileageNextMaintenanceChange WHEN 0 THEN tawv.[NextMaintenanceDate] END, 
		CASE @SkipTechnicalDataMileageNextMaintenanceChange WHEN 0 THEN tawv.[MileageFlag] END,
		tawv.[NextOwnerRecertification], tawv.[BuildDate], tawv.[FactoryOfOriginID], tawv.[EnvelopeModernizationDate],
		tav.[Date] as [DateFrom], @Infinity as [DateTill], tav.[DocTypeID], 
		tav.[ID] as [TechnicalActID], tawv.[ID] as [TechnicalActVehicleID], 1 as [Active],
		CASE WHEN tawv.[OriginalCountryID] IS NOT NULL THEN tawv.[ID] ELSE NULL END as [OriginalCountryID@DocumentVehicleID],
		tawv.[ID] as [VehicleModelID@DocumentVehicleID],
		CASE WHEN tawv.[Capacity] IS NOT NULL THEN tawv.[ID] ELSE NULL END as [Capacity@DocumentVehicleID],
		CASE WHEN tawv.[TareWeight] IS NOT NULL THEN tawv.[ID] ELSE NULL END as [TareWeight@DocumentVehicleID],
		CASE WHEN tawv.[Caliber] IS NOT NULL THEN tawv.[ID] ELSE NULL END as [Caliber@DocumentVehicleID],
		CASE WHEN @SkipTechnicalDataMileageNextMaintenanceChange = 0 AND tawv.[NextMaintenanceDate] IS NOT NULL THEN tawv.[ID] ELSE NULL END as [NextMaintenanceDate@DocumentVehicleID],
		CASE @SkipTechnicalDataMileageNextMaintenanceChange WHEN 0 THEN tawv.[ID] END as [MileageFlag@DocumentVehicleID],
		CASE WHEN tawv.[NextOwnerRecertification] IS NOT NULL THEN tawv.[ID] ELSE NULL END as [NextOwnerRecertification@DocumentVehicleID],
		CASE WHEN tawv.[EnvelopeModernizationDate] IS NOT NULL THEN tawv.[ID] ELSE NULL END as [EnvelopeModernizationDate@DocumentVehicleID]
	FROM [dbo].[TechnicalAct_View] tav
		INNER JOIN [dbo].[TechnicalActVehicle_View] tawv
			ON tav.[ID] = tawv.[TechnicalActID]
	WHERE @Vehicle IS NULL OR tawv.Number = @Vehicle

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': ' + CAST(@@ROWCOUNT as nvarchar(10)) + N' TechAct rows found.'

INSERT INTO #LeaseAct ([ID], [DocTypeID], [LeaseActVehicleID], [LeaseActVehicleNumber], [LeaseActNumber], [Date], [OwnerID],
	[TenantryID], [CargoID], [ByOwnerChange])
	SELECT lav.[ID], lav.[DocTypeID], lawv.[ID] as [LeaseActVehicleID], lawv.[Number] as [LeaseActVehicleNumber],
		lav.[Number] as [LeaseActNumber], lav.[Date], lav.[OwnerID], lav.[TenantryID], lav.[CargoID], lav.[ByOwnerChange]
	FROM [dbo].[LeaseAct_View] lav
		INNER JOIN [dbo].[LeaseActVehicle_View] lawv
			ON lav.[ID] = lawv.[LeaseActID]
				AND lav.[ByOwnerChange] = 1
	WHERE @Vehicle IS NULL OR lawv.Number = @Vehicle

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': ' + CAST(@@ROWCOUNT as nvarchar(10)) + N' LeaseAct rows found.'

IF @SkipTechnicalData = 0
	INSERT INTO #RawDocs ([ID], [TechnicalDataSourceID], [DocumentVehicleID], [DocumentVehicleNumber],
		[OriginalCountryID], [VehicleModelID], [Capacity], [TareWeight], [Caliber], [NextMaintenanceDate], [MileageFlag], [Mileage],
		[NextOwnerRecertification], [MaintenanceAgreement], [NextCoatingDate], [EnvelopeModernizationDate], [DateFrom], [DateTill], [DocTypeID], [Active], 
		[OriginalCountryID@DocumentVehicleID], [VehicleModelID@DocumentVehicleID], [Capacity@DocumentVehicleID], [TareWeight@DocumentVehicleID],
		[Caliber@DocumentVehicleID], [NextMaintenanceDate@DocumentVehicleID], [MileageFlag@DocumentVehicleID], [Mileage@DocumentVehicleID],
		[NextOwnerRecertification@DocumentVehicleID], [MaintenanceAgreement@DocumentVehicleID], [NextCoatingDate@DocumentVehicleID], [EnvelopeModernizationDate@DocumentVehicleID])
		SELECT tdv.[ID], tdv.[SourceID] as [TechnicalDataSourceID], tdwv.[ID] as [DocumentVehicleID], 
			tdwv.[Number] as [DocumentVehicleNumber], tdwv.[OriginalCountryID], tdwv.[VehicleModelID], tdwv.[Capacity], 
			tdwv.[TareWeight], tdwv.[Caliber],
			CASE @SkipTechnicalDataMileageNextMaintenanceChange WHEN 0 THEN tdwv.[NextMaintenanceDate] END,
			CASE @SkipTechnicalDataMileageNextMaintenanceChange WHEN 0 THEN tdwv.[MileageFlag] END,
			CASE @SkipTechnicalDataMileageNextMaintenanceChange WHEN 0 THEN tdwv.[Mileage] END,
			tdwv.[NextOwnerRecertification], tdwv.[MaintenanceAgreement], tdwv.[NextCoatingDate], tdwv.[EnvelopeModernizationDate],
			tdv.[Date] as [DateFrom], @Infinity as [DateTill], tdv.[DocTypeID], 0 as [Active],
			CASE WHEN tdwv.[OriginalCountryID] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [OriginalCountryID@DocumentVehicleID],
			CASE WHEN tdwv.[VehicleModelID] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [VehicleModelID@DocumentVehicleID],
			CASE WHEN tdwv.[Capacity] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [Capacity@DocumentVehicleID],
			CASE WHEN tdwv.[TareWeight] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [TareWeight@DocumentVehicleID],
			CASE WHEN tdwv.[Caliber] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [Caliber@DocumentVehicleID],
			CASE WHEN @SkipTechnicalDataMileageNextMaintenanceChange = 0 AND tdwv.[NextMaintenanceDate] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [NextMaintenanceDate@DocumentVehicleID],
			CASE WHEN @SkipTechnicalDataMileageNextMaintenanceChange = 0 AND tdwv.[MileageFlag] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [MileageFlag@DocumentVehicleID],
			CASE WHEN @SkipTechnicalDataMileageNextMaintenanceChange = 0 AND (tdwv.[Mileage] IS NOT NULL OR tdwv.[MileageFlag] IS NOT NULL) THEN tdwv.[ID] ELSE NULL END as [Mileage@DocumentVehicleID],
			CASE WHEN tdwv.[NextOwnerRecertification] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [NextOwnerRecertification@DocumentVehicleID],
			CASE WHEN tdwv.[MaintenanceAgreement] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [MaintenanceAgreement@DocumentVehicleID],
			CASE WHEN tdwv.[NextCoatingDate] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [NextCoatingDate@DocumentVehicleID],
			CASE WHEN tdwv.[EnvelopeModernizationDate] IS NOT NULL THEN tdwv.[ID] ELSE NULL END as [EnvelopeModernizationDate@DocumentVehicleID]
		FROM [dbo].[TechnicalData_View] tdv
			INNER JOIN [dbo].[TechnicalDataVehicle_View] tdwv
				ON tdv.[ID] = tdwv.[TechnicalDataID]
		WHERE (@Vehicle IS NULL OR tdwv.Number = @Vehicle)
			AND (
				@SkipTechnicalDataMileageNextMaintenanceChange = 0
				OR tdwv.[OriginalCountryID] IS NOT NULL
				OR tdwv.[VehicleModelID] IS NOT NULL
				OR tdwv.[Capacity] IS NOT NULL
				OR tdwv.[TareWeight] IS NOT NULL
				OR tdwv.[Caliber] IS NOT NULL
				OR tdwv.[NextOwnerRecertification] IS NOT NULL
				OR tdwv.[MaintenanceAgreement] IS NOT NULL
				OR tdwv.[NextCoatingDate] IS NOT NULL
				OR tdwv.[EnvelopeModernizationDate] IS NOT NULL)

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': ' + CAST(@@ROWCOUNT as nvarchar(10)) + N' TechData rows found.'

INSERT INTO #RawDocs ([ID], [OwnerID], [TenantryID], [CargoID], [DocumentVehicleID], [DocumentVehicleNumber], [DocumentNumber],
		[DateFrom], [DateTill], [DocTypeID], [Active])
	SELECT l.[ID], l.[OwnerID], l.[TenantryID], l.[CargoID], l.[LeaseActVehicleID] as [DocumentVehicleID],
		l.[LeaseActVehicleNumber] as [DocumentVehicleNumber], l.[LeaseActNumber] as [DocumentNumber], 
		l.[Date] as [DateFrom], @Infinity as [DateTill], l.[DocTypeID], 0 as [Active]
	FROM #LeaseAct l

INSERT INTO #tich (
	[ID], [OwnerID], [TenantryID], [CargoID], [TechnicalDataSourceID], [DocumentVehicleID], [DocumentVehicleNumber], [DocumentNumber],
	[OriginalCountryID], [VehicleModelID], [Capacity], [TareWeight], [Caliber], [NextMaintenanceDate], [MileageFlag], [Mileage],
	[NextOwnerRecertification], [BuildDate], [FactoryOfOriginID], [MaintenanceAgreement], [NextCoatingDate], [EnvelopeModernizationDate], [DateFrom], [DateTill],
	[DocTypeID], [TechnicalActID], [TechnicalActVehicleID], [Active], [OriginalCountryID@DocumentVehicleID],
	[VehicleModelID@DocumentVehicleID], [Capacity@DocumentVehicleID], [TareWeight@DocumentVehicleID], [Caliber@DocumentVehicleID],
	[NextMaintenanceDate@DocumentVehicleID], [MileageFlag@DocumentVehicleID], [Mileage@DocumentVehicleID], [NextOwnerRecertification@DocumentVehicleID],
	[MaintenanceAgreement@DocumentVehicleID], [NextCoatingDate@DocumentVehicleID], [EnvelopeModernizationDate@DocumentVehicleID])
	SELECT [ID], COALESCE([OwnerID], @Guid0), [TenantryID], [CargoID], [TechnicalDataSourceID], [DocumentVehicleID], [DocumentVehicleNumber], [DocumentNumber],
		[OriginalCountryID], [VehicleModelID], [Capacity], [TareWeight], [Caliber], [NextMaintenanceDate], [MileageFlag], [Mileage],
		[NextOwnerRecertification], [BuildDate], [FactoryOfOriginID], [MaintenanceAgreement], [NextCoatingDate], [EnvelopeModernizationDate], [DateFrom], [DateTill],
		[DocTypeID], [TechnicalActID], [TechnicalActVehicleID], [Active], [OriginalCountryID@DocumentVehicleID],
		[VehicleModelID@DocumentVehicleID], [Capacity@DocumentVehicleID], [TareWeight@DocumentVehicleID], [Caliber@DocumentVehicleID],
		[NextMaintenanceDate@DocumentVehicleID], [MileageFlag@DocumentVehicleID], [Mileage@DocumentVehicleID], [NextOwnerRecertification@DocumentVehicleID],
		[MaintenanceAgreement@DocumentVehicleID], [NextCoatingDate@DocumentVehicleID], [EnvelopeModernizationDate@DocumentVehicleID]
	FROM #RawDocs
	ORDER BY [DocumentVehicleNumber], [DateFrom], [DocTypeID]

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': datetill calc started.'

UPDATE t
SET t.[DateTill] = t1.[DateFrom]
FROM #tich t
	INNER JOIN #tich t1
		ON t.[DocumentVehicleNumber] = t1.[DocumentVehicleNumber]
			AND t.[OrdinalNext] = t1.[OrdinalFrom]

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': techdata calc started.'

DECLARE @cnt int = 0, @cnt_total int = 0, @while_cnt int = 0

WHILE 1 = 1
BEGIN
	IF @SkipFieldsUpdated = 0
		UPDATE t1
		SET t1.[Active] = 1,
			t1.[OwnerID] = CASE t1.[OwnerID] WHEN @Guid0 THEN t0.[OwnerID] ELSE t1.[OwnerID] END,
			t1.[TenantryID] = COALESCE(t1.[TenantryID], t0.[TenantryID]), 
			t1.[CargoID] = COALESCE(t1.[CargoID], t0.[CargoID]), 
			--t1.[TechnicalDataSourceID] = COALESCE(t1.[TechnicalDataSourceID], t0.[TechnicalDataSourceID]), 
			t1.[DocumentNumber] = COALESCE(t1.[DocumentNumber], t0.[DocumentNumber]),
			t1.[OriginalCountryID] = COALESCE(t1.[OriginalCountryID], t0.[OriginalCountryID]), 
			t1.[VehicleModelID] = COALESCE(t1.[VehicleModelID], t0.[VehicleModelID]), 
			t1.[Capacity] = COALESCE(t1.[Capacity], t0.[Capacity]), 
			t1.[TareWeight] = COALESCE(t1.[TareWeight], t0.[TareWeight]), 
			t1.[Caliber] = COALESCE(t1.[Caliber], t0.[Caliber]), 
			t1.[NextMaintenanceDate] = COALESCE(t1.[NextMaintenanceDate], t0.[NextMaintenanceDate]), 
			t1.[MileageFlag] = COALESCE(t1.[MileageFlag], t0.[MileageFlag]), 
			t1.[Mileage] = CASE WHEN t1.[MileageFlag] IS NOT NULL THEN t1.[Mileage] ELSE t0.[Mileage] END,
			t1.[NextOwnerRecertification] = CASE t1.[OwnerID] WHEN @Guid0 THEN COALESCE(t1.[NextOwnerRecertification], t0.[NextOwnerRecertification]) ELSE t1.[NextOwnerRecertification] END, -- Относится к владельцу, а не к ТС (не наследуется при переуступке)
			t1.[MaintenanceAgreement] = COALESCE(t1.[MaintenanceAgreement], t0.[MaintenanceAgreement]),
			t1.[NextCoatingDate] = COALESCE(t1.[NextCoatingDate], t0.[NextCoatingDate]),
			t1.[BuildDate] = COALESCE(t1.[BuildDate], t0.[BuildDate]),
			t1.[FactoryOfOriginID] = COALESCE(t1.[FactoryOfOriginID], t0.[FactoryOfOriginID]),		
			t1.[EnvelopeModernizationDate] = COALESCE(t1.[EnvelopeModernizationDate], t0.[EnvelopeModernizationDate]), 
			t1.[TechnicalActID] = COALESCE(t1.[TechnicalActID], t0.[TechnicalActID]),
			t1.[TechnicalActVehicleID] = COALESCE(t1.[TechnicalActVehicleID], t0.[TechnicalActVehicleID]),
			t1.[OriginalCountryID@DocumentVehicleID] = COALESCE(t1.[OriginalCountryID@DocumentVehicleID], t0.[OriginalCountryID@DocumentVehicleID]),
			t1.[VehicleModelID@DocumentVehicleID] = COALESCE(t1.[VehicleModelID@DocumentVehicleID], t0.[VehicleModelID@DocumentVehicleID]),
			t1.[Capacity@DocumentVehicleID] = COALESCE(t1.[Capacity@DocumentVehicleID], t0.[Capacity@DocumentVehicleID]),
			t1.[TareWeight@DocumentVehicleID] = COALESCE(t1.[TareWeight@DocumentVehicleID], t0.[TareWeight@DocumentVehicleID]),
			t1.[Caliber@DocumentVehicleID] = COALESCE(t1.[Caliber@DocumentVehicleID], t0.[Caliber@DocumentVehicleID]),
			t1.[NextMaintenanceDate@DocumentVehicleID] = COALESCE(t1.[NextMaintenanceDate@DocumentVehicleID], t0.[NextMaintenanceDate@DocumentVehicleID]),
			t1.[MileageFlag@DocumentVehicleID] = COALESCE(t1.[MileageFlag@DocumentVehicleID], t0.[MileageFlag@DocumentVehicleID]),
			t1.[Mileage@DocumentVehicleID] = COALESCE(t1.[Mileage@DocumentVehicleID], t0.[Mileage@DocumentVehicleID]),
			t1.[NextOwnerRecertification@DocumentVehicleID] = CASE t1.[OwnerID] WHEN @Guid0 THEN COALESCE(t1.[NextOwnerRecertification@DocumentVehicleID], t0.[NextOwnerRecertification@DocumentVehicleID]) ELSE t1.[NextOwnerRecertification@DocumentVehicleID] END,
			t1.[MaintenanceAgreement@DocumentVehicleID] = COALESCE(t1.[MaintenanceAgreement@DocumentVehicleID], t0.[MaintenanceAgreement@DocumentVehicleID]),
			t1.[NextCoatingDate@DocumentVehicleID] = COALESCE(t1.[NextCoatingDate@DocumentVehicleID], t0.[NextCoatingDate@DocumentVehicleID]),
			t1.[EnvelopeModernizationDate@DocumentVehicleID] = COALESCE(t1.[EnvelopeModernizationDate@DocumentVehicleID], t0.[EnvelopeModernizationDate@DocumentVehicleID])
		FROM #tich t0
			INNER JOIN #tich t1
				ON t0.[DocumentVehicleNumber] = t1.[DocumentVehicleNumber]
					AND t0.[OrdinalNext] = t1.[OrdinalFrom]
					AND t0.[Active] = 1
					AND t1.[Active] = 0
	ELSE
		UPDATE t1
		SET t1.[Active] = 1,
			t1.[OwnerID] = CASE t1.[OwnerID] WHEN @Guid0 THEN t0.[OwnerID] ELSE t1.[OwnerID] END,
			t1.[TenantryID] = COALESCE(t1.[TenantryID], t0.[TenantryID]), 
			t1.[CargoID] = COALESCE(t1.[CargoID], t0.[CargoID]), 
			--t1.[TechnicalDataSourceID] = COALESCE(t1.[TechnicalDataSourceID], t0.[TechnicalDataSourceID]), 
			t1.[DocumentNumber] = COALESCE(t1.[DocumentNumber], t0.[DocumentNumber]),
			t1.[OriginalCountryID] = COALESCE(t1.[OriginalCountryID], t0.[OriginalCountryID]), 
			t1.[VehicleModelID] = COALESCE(t1.[VehicleModelID], t0.[VehicleModelID]), 
			t1.[Capacity] = COALESCE(t1.[Capacity], t0.[Capacity]), 
			t1.[TareWeight] = COALESCE(t1.[TareWeight], t0.[TareWeight]), 
			t1.[Caliber] = COALESCE(t1.[Caliber], t0.[Caliber]), 
			t1.[NextMaintenanceDate] = COALESCE(t1.[NextMaintenanceDate], t0.[NextMaintenanceDate]), 
			t1.[MileageFlag] = COALESCE(t1.[MileageFlag], t0.[MileageFlag]), 
			t1.[Mileage] = CASE WHEN t1.[MileageFlag] IS NOT NULL THEN t1.[Mileage] ELSE t0.[Mileage] END,
			t1.[NextOwnerRecertification] = CASE t1.[OwnerID] WHEN @Guid0 THEN COALESCE(t1.[NextOwnerRecertification], t0.[NextOwnerRecertification]) ELSE t1.[NextOwnerRecertification] END, -- Относится к владельцу, а не к ТС (не наследуется при переуступке)
			t1.[MaintenanceAgreement] = COALESCE(t1.[MaintenanceAgreement], t0.[MaintenanceAgreement]),
			t1.[NextCoatingDate] = COALESCE(t1.[NextCoatingDate], t0.[NextCoatingDate]),
			t1.[BuildDate] = COALESCE(t1.[BuildDate], t0.[BuildDate]),
			t1.[FactoryOfOriginID] = COALESCE(t1.[FactoryOfOriginID], t0.[FactoryOfOriginID]),		
			t1.[EnvelopeModernizationDate] = COALESCE(t1.[EnvelopeModernizationDate], t0.[EnvelopeModernizationDate]),
			t1.[TechnicalActID] = COALESCE(t1.[TechnicalActID], t0.[TechnicalActID]),
			t1.[TechnicalActVehicleID] = COALESCE(t1.[TechnicalActVehicleID], t0.[TechnicalActVehicleID])
		FROM #tich t0
			INNER JOIN #tich t1
				ON t0.[DocumentVehicleNumber] = t1.[DocumentVehicleNumber]
					AND t0.[OrdinalNext] = t1.[OrdinalFrom]
					AND t0.[Active] = 1
					AND t1.[Active] = 0

	SET @cnt = @@ROWCOUNT
	SET @cnt_total = @cnt_total + @cnt
	SET @while_cnt = @while_cnt + 1

	IF (@while_cnt % 10) = 0
		PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': ' + CAST(@cnt_total as nvarchar(10)) + N' rows updated; step #' + CAST(@while_cnt as nvarchar(10))

	IF @cnt = 0
		BREAK
END

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': ' + CAST(@cnt_total as nvarchar(10)) + N' rows proceeded; last step #' + CAST(@while_cnt as nvarchar(10))

IF @SkipFieldsUpdated = 0
	UPDATE #tich
	SET [FieldsUpdated@DocumentVehicleID] = CAST(
				COALESCE(N'[OriginalCountryID]={' + CAST([OriginalCountryID@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[VehicleModelID]={' + CAST([VehicleModelID@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[Capacity]={' + CAST([Capacity@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[TareWeight]={' + CAST([TareWeight@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[Caliber]={' + CAST([Caliber@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[NextMaintenanceDate]={' + CAST([NextMaintenanceDate@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[MileageFlag]={' + CAST([MileageFlag@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[Mileage]={' + CAST([Mileage@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[NextOwnerRecertification]={' + CAST([NextOwnerRecertification@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[MaintenanceAgreement]={' + CAST([MaintenanceAgreement@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[NextCoatingDate]={' + CAST([NextCoatingDate@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
				+ COALESCE(N'[EnvelopeModernizationDate]={' + CAST([EnvelopeModernizationDate@DocumentVehicleID] as nvarchar(38)) + N'}', N'')
			as nvarchar(max))

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': techdata calc completed.'

DELETE FROM [dbo].[cachetechinfohist] WHERE (@Vehicle IS NULL OR [VehicleNumber] = @Vehicle)

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': ' + CAST(@@ROWCOUNT as nvarchar(10)) + N' expired rows deleted.'

INSERT INTO [dbo].[cachetechinfohist]
	([ID], [OwnerID], [TenantryID], [CargoID], [TechnicalDataSourceID],
	 [VehicleID], [VehicleNumber], [DocumentNumber], [OriginalCountryID],
	 [VehicleModelID], [Capacity], [TareWeight], [Caliber],
	 [NextMaintenanceDate], [MileageFlag], [Mileage],
	 [NextOwnerRecertification], [BuildDate], [FactoryOfOriginID],
	 [MaintenanceAgreement], [DateFrom], [DateTill], [DocTypeID],
	 [TechnicalActID], [TechnicalActVehicleID], [FieldsUpdatedDocumentVehicleID],
	 [OrdinalFrom], [NextCoatingDate], [EnvelopeModernizationDate])
	 SELECT [ID], [OwnerID], [TenantryID], [CargoID], [TechnicalDataSourceID],
			[DocumentVehicleID], [DocumentVehicleNumber], [DocumentNumber],
			[OriginalCountryID], [VehicleModelID], [Capacity], [TareWeight], [Caliber],
			[NextMaintenanceDate], [MileageFlag], [Mileage],
			[NextOwnerRecertification], [BuildDate], [FactoryOfOriginID],
			[MaintenanceAgreement], [DateFrom], [DateTill], [DocTypeID],
			[TechnicalActID], [TechnicalActVehicleID], [FieldsUpdated@DocumentVehicleID],
			[OrdinalFrom], [NextCoatingDate], [EnvelopeModernizationDate]
	 FROM #tich

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': ' + CAST(@@ROWCOUNT as nvarchar(10)) + N' rows cached.'

PRINT FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss.fffff', N'ru-RU') + N': completed.'

RETURN @@ERROR
GO
ALTER DATABASE [OtusProject] SET  READ_WRITE 
GO
