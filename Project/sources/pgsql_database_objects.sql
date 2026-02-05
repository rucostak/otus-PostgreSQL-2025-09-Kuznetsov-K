-- DROP SCHEMA dbo2;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA dbo2 AUTHORIZATION rucostak;
-- dbo2.cachetechinfohist definition

-- Drop table

-- DROP TABLE dbo2.cachetechinfohist;

CREATE TABLE dbo2.cachetechinfohist (
	id uuid NOT NULL,
	ownerid uuid NOT NULL,
	tenantryid uuid NULL,
	cargoid uuid NULL,
	technicaldatasourceid uuid NULL,
	vehicleid uuid NOT NULL,
	vehiclenumber text NOT NULL,
	documentnumber text NULL,
	originalcountryid uuid NULL,
	vehiclemodelid uuid NULL,
	capacity int4 NULL,
	tareweight int4 NULL,
	caliber int4 NULL,
	nextmaintenancedate timestamptz NULL,
	mileageflag bool NULL,
	mileage int4 NULL,
	nextownerrecertification timestamptz NULL,
	builddate timestamptz NULL,
	factoryoforiginid uuid NULL,
	maintenanceagreement text NULL,
	datefrom timestamptz NOT NULL,
	datetill timestamptz NOT NULL,
	doctypeid uuid NOT NULL,
	technicalactid uuid NULL,
	technicalactvehicleid uuid NULL,
	fieldsupdateddocumentvehicleid text NULL,
	ordinalfrom int4 NOT NULL,
	nextcoatingdate timestamptz NULL,
	envelopemodernizationdate timestamptz NULL,
	CONSTRAINT idx_23629_pk_cachetechinfohist PRIMARY KEY (vehiclenumber, ordinalfrom)
);
CREATE INDEX idx_23629_ix_cachetechinfohist_vehicleid ON dbo2.cachetechinfohist USING btree (vehicleid, datefrom);
CREATE INDEX idx_23629_ix_cachetechinfohist_vehiclenumber_datefrom_datetill ON dbo2.cachetechinfohist USING btree (vehiclenumber, datefrom, datetill, ownerid, vehiclemodelid);


-- dbo2.documenttype definition

-- Drop table

-- DROP TABLE dbo2.documenttype;

CREATE TABLE dbo2.documenttype (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	"order" int2 NULL,
	namerus text NULL,
	nameeng text NULL,
	nameclass text NULL,
	tablename text NULL,
	childtablename text NULL,
	CONSTRAINT idx_23677_pk_documenttype PRIMARY KEY (id)
);
CREATE INDEX idx_23677_ix_documenttype_childtablename ON dbo2.documenttype USING btree (childtablename);
CREATE INDEX idx_23677_ix_documenttype_nameclass ON dbo2.documenttype USING btree (nameclass);
CREATE INDEX idx_23677_ix_documenttype_tablename ON dbo2.documenttype USING btree (tablename);
CREATE UNIQUE INDEX idx_23677_uq_documenttype_order ON dbo2.documenttype USING btree ("order");


-- dbo2.technicaldatasource definition

-- Drop table

-- DROP TABLE dbo2.technicaldatasource;

CREATE TABLE dbo2.technicaldatasource (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nameeng text NOT NULL,
	namerus text NOT NULL,
	CONSTRAINT idx_23744_pk_technicaldatasource PRIMARY KEY (id)
);
CREATE UNIQUE INDEX idx_23744_uq_technicaldatasource_nameeng_namerus ON dbo2.technicaldatasource USING btree (nameeng, namerus);


-- dbo2.documenterrortype definition

-- Drop table

-- DROP TABLE dbo2.documenterrortype;

CREATE TABLE dbo2.documenterrortype (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	errorcode int2 NOT NULL,
	description text NULL,
	"level" int2 NOT NULL,
	datefrom timestamptz NOT NULL,
	datetill timestamptz NULL,
	documenttypeorder int2 NULL,
	CONSTRAINT idx_23667_pk_documenterrortype PRIMARY KEY (errorcode),
	CONSTRAINT fk_documenterrortype_documenttype FOREIGN KEY (documenttypeorder) REFERENCES dbo2.documenttype("order")
);
CREATE INDEX idx_23667_ix_documenterrortype_documenttypeorder ON dbo2.documenterrortype USING btree (documenttypeorder);
CREATE UNIQUE INDEX idx_23667_uq_documenterrortype ON dbo2.documenterrortype USING btree (id);


-- dbo2."enum" definition

-- Drop table

-- DROP TABLE dbo2."enum";

CREATE TABLE dbo2."enum" (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	parentid uuid NULL,
	ordinal int4 NULL,
	namerus text NULL,
	nameeng text NULL,
	CONSTRAINT idx_23684_pk_enum PRIMARY KEY (id),
	CONSTRAINT fk_enum_enum_parentid_id FOREIGN KEY (parentid) REFERENCES dbo2."enum"(id)
);
CREATE INDEX idx_23684_ix_enum_ordinal ON dbo2.enum USING btree (ordinal);
CREATE INDEX idx_23684_ix_enum_parentid ON dbo2.enum USING btree (parentid);
CREATE UNIQUE INDEX idx_23684_uq_enum_parentid_ordinal ON dbo2.enum USING btree (parentid, ordinal);


-- dbo2."document" definition

-- Drop table

-- DROP TABLE dbo2."document";

CREATE TABLE dbo2."document" (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	doctypeid uuid NOT NULL,
	stateid uuid NULL,
	origin text NOT NULL,
	modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modifiedby text DEFAULT 'suser_sname()'::text NOT NULL,
	CONSTRAINT idx_23642_pk_document PRIMARY KEY (id),
	CONSTRAINT fk_document_documenttype FOREIGN KEY (doctypeid) REFERENCES dbo2.documenttype(id),
	CONSTRAINT fk_document_enum FOREIGN KEY (stateid) REFERENCES dbo2."enum"(id)
);
CREATE INDEX idx_23642_ix_document_doctypeid ON dbo2.document USING btree (doctypeid);
CREATE INDEX idx_23642_ix_document_modified ON dbo2.document USING btree (modified, modifiedby);
CREATE INDEX idx_23642_ix_document_stateid ON dbo2.document USING btree (stateid, origin);


-- dbo2.documenterrordatalog definition

-- Drop table

-- DROP TABLE dbo2.documenterrordatalog;

CREATE TABLE dbo2.documenterrordatalog (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	documentid uuid NOT NULL,
	recordid uuid NOT NULL,
	"attribute" text NOT NULL,
	"level" int4 NOT NULL,
	message text NULL,
	errorcode int2 NOT NULL,
	CONSTRAINT idx_23655_pk_documenterrordatalog PRIMARY KEY (id),
	CONSTRAINT fk_documenterrordatalog_documenterrortype FOREIGN KEY (errorcode) REFERENCES dbo2.documenterrortype(errorcode)
);
CREATE INDEX idx_23655_ix_documenterrordatalog_attribute ON dbo2.documenterrordatalog USING btree (attribute);
CREATE INDEX idx_23655_ix_documenterrordatalog_documentid ON dbo2.documenterrordatalog USING btree (documentid);
CREATE INDEX idx_23655_ix_documenterrordatalog_errorcode ON dbo2.documenterrordatalog USING btree (errorcode);
CREATE INDEX idx_23655_ix_documenterrordatalog_level ON dbo2.documenterrordatalog USING btree (level);
CREATE INDEX idx_23655_ix_documenterrordatalog_level_recordid ON dbo2.documenterrordatalog USING btree (level, recordid);
CREATE INDEX idx_23655_ix_documenterrordatalog_level_recordid_critical ON dbo2.documenterrordatalog USING btree (level, recordid) WHERE (level = 2);
CREATE INDEX idx_23655_ix_documenterrordatalog_recordid ON dbo2.documenterrordatalog USING btree (recordid);


-- dbo2.leaseact definition

-- Drop table

-- DROP TABLE dbo2.leaseact;

CREATE TABLE dbo2.leaseact (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	"number" text NOT NULL,
	"date" timestamptz NOT NULL,
	ownerid uuid NOT NULL,
	tenantryid uuid NOT NULL,
	cargoid uuid NOT NULL,
	byownerchange bool NULL,
	leasecontractid uuid NULL,
	CONSTRAINT idx_23691_pk_leaseact PRIMARY KEY (id),
	CONSTRAINT fk_leaseact_document FOREIGN KEY (id) REFERENCES dbo2."document"(id)
);
CREATE INDEX idx_23691_ix_leaseact_byownerchange ON dbo2.leaseact USING btree (byownerchange);
CREATE INDEX idx_23691_ix_leaseact_cargoid ON dbo2.leaseact USING btree (cargoid);
CREATE INDEX idx_23691_ix_leaseact_date ON dbo2.leaseact USING btree (date);
CREATE INDEX idx_23691_ix_leaseact_leasecontractid ON dbo2.leaseact USING btree (leasecontractid);
CREATE INDEX idx_23691_ix_leaseact_number ON dbo2.leaseact USING btree (number);
CREATE INDEX idx_23691_ix_leaseact_ownerid ON dbo2.leaseact USING btree (ownerid);
CREATE INDEX idx_23691_ix_leaseact_tenantryid ON dbo2.leaseact USING btree (tenantryid);


-- dbo2.leaseactvehicle definition

-- Drop table

-- DROP TABLE dbo2.leaseactvehicle;

CREATE TABLE dbo2.leaseactvehicle (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	leaseactid uuid NOT NULL,
	ordinal int4 NOT NULL,
	"number" text NOT NULL,
	CONSTRAINT idx_23703_pk_leaseactvehicle PRIMARY KEY (id),
	CONSTRAINT fk_leaseactvehicle_leaseact FOREIGN KEY (leaseactid) REFERENCES dbo2.leaseact(id)
);
CREATE INDEX idx_23703_ix_leaseactvehicle_leaseactid ON dbo2.leaseactvehicle USING btree (leaseactid);
CREATE INDEX idx_23703_ix_leaseactvehicle_number ON dbo2.leaseactvehicle USING btree (number);


-- dbo2.technicalact definition

-- Drop table

-- DROP TABLE dbo2.technicalact;

CREATE TABLE dbo2.technicalact (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	"number" text NULL,
	"date" timestamptz NOT NULL,
	ownerid uuid NOT NULL,
	tenantryid uuid NOT NULL,
	cargoid uuid NOT NULL,
	CONSTRAINT idx_23713_pk_technicalact PRIMARY KEY (id),
	CONSTRAINT fk_technicalact_document FOREIGN KEY (id) REFERENCES dbo2."document"(id)
);
CREATE INDEX idx_23713_ix_technicalact_cargoid ON dbo2.technicalact USING btree (cargoid);
CREATE INDEX idx_23713_ix_technicalact_date ON dbo2.technicalact USING btree (date);
CREATE INDEX idx_23713_ix_technicalact_ownerid ON dbo2.technicalact USING btree (ownerid);
CREATE INDEX idx_23713_ix_technicalact_tenantryid ON dbo2.technicalact USING btree (tenantryid);


-- dbo2.technicalactvehicle definition

-- Drop table

-- DROP TABLE dbo2.technicalactvehicle;

CREATE TABLE dbo2.technicalactvehicle (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	technicalactid uuid NOT NULL,
	"number" text NOT NULL,
	originalcountryid uuid NULL,
	vehiclemodelid uuid NOT NULL,
	capacity int4 NULL,
	tareweight int4 NULL,
	caliber int4 NULL,
	nextmaintenancedate timestamptz NULL,
	mileageflag bool DEFAULT false NOT NULL,
	ordinal int4 NOT NULL,
	nextownerrecertification timestamptz NULL,
	builddate timestamptz NULL,
	factoryoforiginid uuid NULL,
	envelopemodernizationdate timestamptz NULL,
	CONSTRAINT idx_23724_pk_technicalactvehicle PRIMARY KEY (id),
	CONSTRAINT fk_technicalactvehicle_technicalact FOREIGN KEY (technicalactid) REFERENCES dbo2.technicalact(id)
);
CREATE INDEX idx_23724_ix_technicalactvehicle_builddate ON dbo2.technicalactvehicle USING btree (builddate);
CREATE INDEX idx_23724_ix_technicalactvehicle_factoryoforiginid ON dbo2.technicalactvehicle USING btree (factoryoforiginid);
CREATE INDEX idx_23724_ix_technicalactvehicle_number ON dbo2.technicalactvehicle USING btree (number);
CREATE INDEX idx_23724_ix_technicalactvehicle_originalcountryid ON dbo2.technicalactvehicle USING btree (originalcountryid);
CREATE INDEX idx_23724_ix_technicalactvehicle_technicalactid ON dbo2.technicalactvehicle USING btree (technicalactid);
CREATE INDEX idx_23724_ix_technicalactvehicle_vehiclemodelid ON dbo2.technicalactvehicle USING btree (vehiclemodelid);


-- dbo2.technicaldata definition

-- Drop table

-- DROP TABLE dbo2.technicaldata;

CREATE TABLE dbo2.technicaldata (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	sourceid uuid NOT NULL,
	"date" timestamptz NOT NULL,
	CONSTRAINT idx_23737_pk_technicaldata PRIMARY KEY (id),
	CONSTRAINT fk_technicaldata_document FOREIGN KEY (id) REFERENCES dbo2."document"(id),
	CONSTRAINT fk_technicaldata_technicaldatasource FOREIGN KEY (sourceid) REFERENCES dbo2.technicaldatasource(id)
);
CREATE INDEX idx_23737_ix_technicaldata_date ON dbo2.technicaldata USING btree (date);
CREATE INDEX idx_23737_ix_technicaldata_sourceid ON dbo2.technicaldata USING btree (sourceid);


-- dbo2.technicaldatavehicle definition

-- Drop table

-- DROP TABLE dbo2.technicaldatavehicle;

CREATE TABLE dbo2.technicaldatavehicle (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	technicaldataid uuid NOT NULL,
	"number" text NOT NULL,
	originalcountryid uuid NULL,
	capacity int4 NULL,
	tareweight int4 NULL,
	caliber int4 NULL,
	nextmaintenancedate timestamptz NULL,
	mileageflag bool NULL,
	mileage int4 NULL,
	nextownerrecertification timestamptz NULL,
	ordinal int4 NOT NULL,
	maintenanceagreement text NULL,
	vehiclemodelid uuid NULL,
	nextcoatingdate timestamptz NULL,
	envelopemodernizationdate timestamptz NULL,
	CONSTRAINT idx_23753_pk_technicaldatavehicle PRIMARY KEY (id),
	CONSTRAINT fk_technicaldatavehicle_technicaldata FOREIGN KEY (technicaldataid) REFERENCES dbo2.technicaldata(id)
);
CREATE INDEX idx_23753_ix_technicaldatavehicle_number ON dbo2.technicaldatavehicle USING btree (number);
CREATE INDEX idx_23753_ix_technicaldatavehicle_originalcountryid ON dbo2.technicaldatavehicle USING btree (originalcountryid) WHERE (originalcountryid IS NOT NULL);
CREATE INDEX idx_23753_ix_technicaldatavehicle_technicaldataid ON dbo2.technicaldatavehicle USING btree (technicaldataid);
CREATE INDEX idx_23753_ix_technicaldatavehicle_vehiclemodelid ON dbo2.technicaldatavehicle USING btree (vehiclemodelid) WHERE (vehiclemodelid IS NOT NULL);


-- dbo2.leaseact_view source

CREATE OR REPLACE VIEW dbo2.leaseact_view
AS SELECT t.id,
    d.doctypeid,
    d.stateid,
    d.origin,
    e.ordinal AS stateordinal,
    d.modified,
    d.modifiedby,
    t.number,
    t.date,
    t.ownerid,
    t.tenantryid,
    t.cargoid,
    t.byownerchange,
    t.leasecontractid
   FROM dbo2.leaseact t
     JOIN dbo2.document d ON d.id = t.id
     JOIN dbo2.enum e ON d.stateid = e.id AND e.ordinal < 4
  WHERE NOT (t.id IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2));


-- dbo2.leaseactvehicle_view source

CREATE OR REPLACE VIEW dbo2.leaseactvehicle_view
AS SELECT id,
    leaseactid,
    ordinal,
    number
   FROM dbo2.leaseactvehicle
  WHERE NOT (id IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2)) AND NOT (leaseactid IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2));


-- dbo2.technicalact_view source

CREATE OR REPLACE VIEW dbo2.technicalact_view
AS SELECT t.id,
    d.doctypeid,
    d.stateid,
    d.origin,
    e.ordinal AS stateordinal,
    d.modified,
    d.modifiedby,
    t.number,
    t.date,
    t.ownerid,
    t.tenantryid,
    t.cargoid
   FROM dbo2.technicalact t
     JOIN dbo2.document d ON d.id = t.id
     JOIN dbo2.enum e ON d.stateid = e.id AND e.ordinal < 4
  WHERE NOT (t.id IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2));


-- dbo2.technicalactvehicle_view source

CREATE OR REPLACE VIEW dbo2.technicalactvehicle_view
AS SELECT id,
    technicalactid,
    number,
    originalcountryid,
    vehiclemodelid,
    capacity,
    tareweight,
    caliber,
    nextmaintenancedate,
    mileageflag,
    ordinal,
    nextownerrecertification,
    builddate,
    factoryoforiginid,
    envelopemodernizationdate
   FROM dbo2.technicalactvehicle
  WHERE NOT (id IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2)) AND NOT (technicalactid IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2));


-- dbo2.technicaldata_view source

CREATE OR REPLACE VIEW dbo2.technicaldata_view
AS SELECT t.id,
    d.doctypeid,
    d.stateid,
    d.origin,
    e.ordinal AS stateordinal,
    d.modified,
    d.modifiedby,
    t.sourceid,
    t.date
   FROM dbo2.technicaldata t
     JOIN dbo2.document d ON d.id = t.id
     JOIN dbo2.enum e ON d.stateid = e.id AND e.ordinal < 4
  WHERE NOT (t.id IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2));


-- dbo2.technicaldatavehicle_view source

CREATE OR REPLACE VIEW dbo2.technicaldatavehicle_view
AS SELECT id,
    technicaldataid,
    number,
    originalcountryid,
    capacity,
    tareweight,
    caliber,
    nextmaintenancedate,
    mileageflag,
    mileage,
    nextownerrecertification,
    ordinal,
    maintenanceagreement,
    vehiclemodelid,
    nextcoatingdate,
    envelopemodernizationdate
   FROM dbo2.technicaldatavehicle
  WHERE NOT (id IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2)) AND NOT (technicaldataid IN ( SELECT documenterrordatalog.recordid
           FROM dbo2.documenterrordatalog
          WHERE documenterrordatalog.level = 2));



-- DROP PROCEDURE dbo2.cachetechinfohist_calc(varchar, bool, bool, bool);

CREATE OR REPLACE PROCEDURE dbo2.cachetechinfohist_calc(IN v_vehicle character varying DEFAULT NULL::character varying, IN v_skipfieldsupdated boolean DEFAULT false, IN v_skiptechnicaldata boolean DEFAULT false, IN v_skiptechnicaldatamileagenextmaintenancechange boolean DEFAULT false)
 LANGUAGE plpgsql
AS $procedure$
DECLARE v_Infinity timestamptz;
	v_sqlcmd text;
	v_Guid0 uuid;
	v_cnt integer = 1;
	v_while_cnt integer = 0;	-- кол-во циклов обновления тех.данных
	v_cnt_total integer = 0;	-- нарастающий итог обновлённых тех.данных
	v_rows integer;

BEGIN	-- начнём транзакцию

	v_Infinity = '99991231'::timestamptz;
	v_SkipFieldsUpdated = COALESCE(v_SkipFieldsUpdated, false);
	v_SkipTechnicalData = COALESCE(v_SkipTechnicalData, false);
	v_SkipTechnicalDataMileageNextMaintenanceChange = COALESCE(v_SkipTechnicalDataMileageNextMaintenanceChange, false);
	v_Guid0 = '{00000000-0000-0000-0000-000000000000}';

	--v_Vehicle = '52017043';

--drop table if exists lt_tich;

CREATE TEMPORARY TABLE lt_tich (
	ID uuid NOT NULL,
	OwnerID uuid NOT NULL,
	TenantryID uuid NULL,
	CargoID uuid NULL,
	TechnicalDataSourceID uuid NULL,
	DocumentVehicleID uuid NOT NULL,
	DocumentVehicleNumber varchar(8) NOT NULL,
	DocumentNumber varchar(64) NULL,
	OriginalCountryID uuid NULL,
	VehicleModelID uuid NULL,
	Capacity int4 NULL,
	TareWeight int4 NULL,
	Caliber int4 NULL,
	NextMaintenanceDate timestamptz NULL,
	MileageFlag boolean NULL,
	Mileage int4 NULL,
	NextOwnerRecertification timestamptz NULL,
	BuildDate timestamptz NULL,
	FactoryOfOriginID uuid NULL,
	MaintenanceAgreement text NULL,
	NextCoatingDate timestamptz NULL,
	EnvelopeModernizationDate timestamptz NULL,
	DateFrom timestamptz NOT NULL,
	DateTill timestamptz NOT NULL,
	DocTypeID uuid NOT NULL,
	TechnicalActID uuid NULL,
	TechnicalActVehicleID uuid NULL,
	Active boolean NOT NULL,
	OriginalCountryIDv_DocumentVehicleID uuid NULL,
	VehicleModelIDv_DocumentVehicleID uuid NULL,
	Capacityv_DocumentVehicleID uuid NULL,
	TareWeightv_DocumentVehicleID uuid NULL,
	Caliberv_DocumentVehicleID uuid NULL,
	NextMaintenanceDatev_DocumentVehicleID uuid NULL,
	MileageFlagv_DocumentVehicleID uuid NULL,
	Mileagev_DocumentVehicleID uuid NULL,
	NextOwnerRecertificationv_DocumentVehicleID uuid NULL,
	MaintenanceAgreementv_DocumentVehicleID uuid NULL,
	NextCoatingDatev_DocumentVehicleID uuid NULL,
	EnvelopeModernizationDatev_DocumentVehicleID uuid NULL,
	FieldsUpdatedv_DocumentVehicleID varchar(2048) NULL,
	OrdinalFrom int4 GENERATED ALWAYS AS IDENTITY NOT NULL,	-- кластеризация особого смысла не имеет, поскольку не выполняется автоматически при изменении данных
	--OrdinalNext int4 GENERATED ALWAYS AS (OrdinalFrom + 1)	-- вычисляемые колонки не индексируются
	primary key (DocumentVehicleNumber, OrdinalFrom, Active)
) on commit drop;
	
--CREATE INDEX ON lt_tich (DocumentVehicleNumber ASC, OrdinalFrom ASC, Active ASC);

--drop table if exists lt_RawDocs;

CREATE TEMPORARY TABLE lt_RawDocs (
	ID uuid NOT NULL,
	OwnerID uuid NULL,
	TenantryID uuid NULL,
	CargoID uuid NULL,
	TechnicalDataSourceID uuid NULL,
	DocumentVehicleID uuid NOT NULL,
	DocumentVehicleNumber text NOT NULL,
	DocumentNumber text NULL,
	OriginalCountryID uuid NULL,
	VehicleModelID uuid NULL,
	Capacity int4 NULL,
	TareWeight int4 NULL,
	Caliber int4 NULL,
	NextMaintenanceDate timestamptz NULL,
	MileageFlag boolean NULL,
	Mileage int4 NULL,
	NextOwnerRecertification timestamptz NULL,
	BuildDate timestamptz NULL,
	FactoryOfOriginID uuid NULL,
	MaintenanceAgreement text NULL,
	NextCoatingDate timestamptz NULL,
	EnvelopeModernizationDate timestamptz NULL,
	DateFrom timestamptz NOT NULL,
	DateTill timestamptz NULL,
	DocTypeID uuid NOT NULL,
	TechnicalActID uuid NULL,
	TechnicalActVehicleID uuid NULL,
	Active boolean NOT NULL,
	OriginalCountryIDv_DocumentVehicleID uuid NULL,
	VehicleModelIDv_DocumentVehicleID uuid NULL,
	Capacityv_DocumentVehicleID uuid NULL,
	TareWeightv_DocumentVehicleID uuid NULL,
	Caliberv_DocumentVehicleID uuid NULL,
	NextMaintenanceDatev_DocumentVehicleID uuid NULL,
	MileageFlagv_DocumentVehicleID uuid NULL,
	Mileagev_DocumentVehicleID uuid NULL,
	NextOwnerRecertificationv_DocumentVehicleID uuid NULL,
	MaintenanceAgreementv_DocumentVehicleID uuid NULL,
	NextCoatingDatev_DocumentVehicleID uuid NULL,
	EnvelopeModernizationDatev_DocumentVehicleID uuid NULL
) on commit drop;

--drop table if exists lt_LeaseAct;

-- Register owner change
CREATE TEMPORARY TABLE lt_LeaseAct (
	ID uuid NOT NULL,
	DocTypeID uuid NOT NULL,
	LeaseActVehicleID uuid NOT NULL,
	LeaseActVehicleNumber text NOT NULL,
	LeaseActNumber text NOT NULL,
	Date timestamptz NOT NULL,
	OwnerID uuid NOT NULL,
	TenantryID uuid NOT NULL,
	CargoID uuid NOT NULL,
	ByOwnerChange boolean NULL
) on commit drop;

raise notice '%: start', CLOCK_TIMESTAMP();

INSERT INTO lt_RawDocs (ID, OwnerID, TenantryID, CargoID, DocumentVehicleID, DocumentVehicleNumber, DocumentNumber,
	OriginalCountryID, VehicleModelID, Capacity, TareWeight, Caliber, NextMaintenanceDate, MileageFlag,
	NextOwnerRecertification, BuildDate, FactoryOfOriginID, EnvelopeModernizationDate, DateFrom, DateTill, DocTypeID, TechnicalActID, TechnicalActVehicleID, Active,
	OriginalCountryIDv_DocumentVehicleID, VehicleModelIDv_DocumentVehicleID, Capacityv_DocumentVehicleID, TareWeightv_DocumentVehicleID,
	Caliberv_DocumentVehicleID, NextMaintenanceDatev_DocumentVehicleID, MileageFlagv_DocumentVehicleID,
	NextOwnerRecertificationv_DocumentVehicleID, EnvelopeModernizationDatev_DocumentVehicleID)
	SELECT tav.ID, tav.OwnerID, tav.TenantryID, tav.CargoID, tawv.ID as DocumentVehicleID,
		tawv.Number as DocumentVehicleNumber, tav.Number as DocumentNumber, tawv.OriginalCountryID,
		tawv.VehicleModelID, tawv.Capacity, tawv.TareWeight, tawv.Caliber,
		CASE v_SkipTechnicalDataMileageNextMaintenanceChange WHEN false THEN tawv.NextMaintenanceDate END, 
		CASE v_SkipTechnicalDataMileageNextMaintenanceChange WHEN false THEN tawv.MileageFlag END,
		tawv.NextOwnerRecertification, tawv.BuildDate, tawv.FactoryOfOriginID, tawv.EnvelopeModernizationDate,
		tav.Date as DateFrom, v_Infinity as DateTill, tav.DocTypeID, 
		tav.ID as TechnicalActID, tawv.ID as TechnicalActVehicleID, true as Active,
		CASE WHEN tawv.OriginalCountryID IS NOT NULL THEN tawv.ID ELSE NULL END as OriginalCountryIDv_DocumentVehicleID,
		tawv.ID as VehicleModelIDv_DocumentVehicleID,
		CASE WHEN tawv.Capacity IS NOT NULL THEN tawv.ID ELSE NULL END as Capacityv_DocumentVehicleID,
		CASE WHEN tawv.TareWeight IS NOT NULL THEN tawv.ID ELSE NULL END as TareWeightv_DocumentVehicleID,
		CASE WHEN tawv.Caliber IS NOT NULL THEN tawv.ID ELSE NULL END as Caliberv_DocumentVehicleID,
		CASE WHEN v_SkipTechnicalDataMileageNextMaintenanceChange = false AND tawv.NextMaintenanceDate IS NOT NULL THEN tawv.ID ELSE NULL END as NextMaintenanceDatev_DocumentVehicleID,
		CASE v_SkipTechnicalDataMileageNextMaintenanceChange WHEN false THEN tawv.ID END as MileageFlagv_DocumentVehicleID,
		CASE WHEN tawv.NextOwnerRecertification IS NOT NULL THEN tawv.ID ELSE NULL END as NextOwnerRecertificationv_DocumentVehicleID,
		CASE WHEN tawv.EnvelopeModernizationDate IS NOT NULL THEN tawv.ID ELSE NULL END as EnvelopeModernizationDatev_DocumentVehicleID
	FROM dbo2.TechnicalAct_View tav
		INNER JOIN dbo2.TechnicalActVehicle_View tawv
			ON tav.ID = tawv.TechnicalActID
	where (v_Vehicle is null or tawv.number = v_Vehicle);

GET DIAGNOSTICS v_rows = row_count;
raise notice '%: % TechAct rows found.', CLOCK_TIMESTAMP(), v_rows;

INSERT INTO lt_LeaseAct (ID, DocTypeID, LeaseActVehicleID, LeaseActVehicleNumber, LeaseActNumber, Date, OwnerID,
	TenantryID, CargoID, ByOwnerChange)
	SELECT lav.ID, lav.DocTypeID, lawv.ID as LeaseActVehicleID, lawv.Number as LeaseActVehicleNumber,
		lav.Number as LeaseActNumber, lav.Date, lav.OwnerID, lav.TenantryID, lav.CargoID, lav.ByOwnerChange
	FROM dbo2.LeaseAct_View lav
		INNER JOIN dbo2.LeaseActVehicle_View lawv
			ON lav.ID = lawv.LeaseActID
				AND lav.ByOwnerChange = true
	where (v_Vehicle is null or lawv.Number = v_Vehicle);


GET DIAGNOSTICS v_rows = row_count;
raise notice '%: % LeaseAct rows found.', CLOCK_TIMESTAMP(), v_rows;

IF v_SkipTechnicalData = false then
begin
	INSERT INTO lt_RawDocs (ID, TechnicalDataSourceID, DocumentVehicleID, DocumentVehicleNumber,
		OriginalCountryID, VehicleModelID, Capacity, TareWeight, Caliber, NextMaintenanceDate, MileageFlag, Mileage,
		NextOwnerRecertification, MaintenanceAgreement, NextCoatingDate, EnvelopeModernizationDate, DateFrom, DateTill, DocTypeID, Active, 
		OriginalCountryIDv_DocumentVehicleID, VehicleModelIDv_DocumentVehicleID, Capacityv_DocumentVehicleID, TareWeightv_DocumentVehicleID,
		Caliberv_DocumentVehicleID, NextMaintenanceDatev_DocumentVehicleID, MileageFlagv_DocumentVehicleID, Mileagev_DocumentVehicleID,
		NextOwnerRecertificationv_DocumentVehicleID, MaintenanceAgreementv_DocumentVehicleID, NextCoatingDatev_DocumentVehicleID, EnvelopeModernizationDatev_DocumentVehicleID)
		SELECT tdv.ID, tdv.SourceID as TechnicalDataSourceID, tdwv.ID as DocumentVehicleID, 
			tdwv.Number as DocumentVehicleNumber, tdwv.OriginalCountryID, tdwv.VehicleModelID, tdwv.Capacity, 
			tdwv.TareWeight, tdwv.Caliber,
			CASE v_SkipTechnicalDataMileageNextMaintenanceChange WHEN false THEN tdwv.NextMaintenanceDate END,
			CASE v_SkipTechnicalDataMileageNextMaintenanceChange WHEN false THEN tdwv.MileageFlag END,
			CASE v_SkipTechnicalDataMileageNextMaintenanceChange WHEN false THEN tdwv.Mileage END,
			tdwv.NextOwnerRecertification, tdwv.MaintenanceAgreement, tdwv.NextCoatingDate, tdwv.EnvelopeModernizationDate,
			tdv.Date as DateFrom, v_Infinity as DateTill, tdv.DocTypeID, false as Active,
			CASE WHEN tdwv.OriginalCountryID IS NOT NULL THEN tdwv.ID ELSE NULL END as OriginalCountryIDv_DocumentVehicleID,
			CASE WHEN tdwv.VehicleModelID IS NOT NULL THEN tdwv.ID ELSE NULL END as VehicleModelIDv_DocumentVehicleID,
			CASE WHEN tdwv.Capacity IS NOT NULL THEN tdwv.ID ELSE NULL END as Capacityv_DocumentVehicleID,
			CASE WHEN tdwv.TareWeight IS NOT NULL THEN tdwv.ID ELSE NULL END as TareWeightv_DocumentVehicleID,
			CASE WHEN tdwv.Caliber IS NOT NULL THEN tdwv.ID ELSE NULL END as Caliberv_DocumentVehicleID,
			CASE WHEN v_SkipTechnicalDataMileageNextMaintenanceChange = false AND tdwv.NextMaintenanceDate IS NOT NULL THEN tdwv.ID ELSE NULL END as NextMaintenanceDatev_DocumentVehicleID,
			CASE WHEN v_SkipTechnicalDataMileageNextMaintenanceChange = false AND tdwv.MileageFlag IS NOT NULL THEN tdwv.ID ELSE NULL END as MileageFlagv_DocumentVehicleID,
			CASE WHEN v_SkipTechnicalDataMileageNextMaintenanceChange = false AND (tdwv.Mileage IS NOT NULL OR tdwv.MileageFlag IS NOT NULL) THEN tdwv.ID ELSE NULL END as Mileagev_DocumentVehicleID,
			CASE WHEN tdwv.NextOwnerRecertification IS NOT NULL THEN tdwv.ID ELSE NULL END as NextOwnerRecertificationv_DocumentVehicleID,
			CASE WHEN tdwv.MaintenanceAgreement IS NOT NULL THEN tdwv.ID ELSE NULL END as MaintenanceAgreementv_DocumentVehicleID,
			CASE WHEN tdwv.NextCoatingDate IS NOT NULL THEN tdwv.ID ELSE NULL END as NextCoatingDatev_DocumentVehicleID,
			CASE WHEN tdwv.EnvelopeModernizationDate IS NOT NULL THEN tdwv.ID ELSE NULL END as EnvelopeModernizationDatev_DocumentVehicleID
		FROM dbo2.TechnicalData_View tdv
			INNER JOIN dbo2.TechnicalDataVehicle_View tdwv
				ON tdv.ID = tdwv.TechnicalDataID
		WHERE (v_Vehicle is null or tdwv.Number = v_Vehicle) AND (v_SkipTechnicalDataMileageNextMaintenanceChange = false
			OR tdwv.OriginalCountryID IS NOT NULL
			OR tdwv.VehicleModelID IS NOT NULL
			OR tdwv.Capacity IS NOT NULL
			OR tdwv.TareWeight IS NOT NULL
			OR tdwv.Caliber IS NOT NULL
			OR tdwv.NextOwnerRecertification IS NOT NULL
			OR tdwv.MaintenanceAgreement IS NOT NULL
			OR tdwv.NextCoatingDate IS NOT NULL
			OR tdwv.EnvelopeModernizationDate IS NOT NULL);	

	GET DIAGNOSTICS v_rows = row_count;
	raise notice '%: % TechData rows found.', CLOCK_TIMESTAMP(), v_rows;
end;
end if;

INSERT INTO lt_RawDocs (ID, OwnerID, TenantryID, CargoID, DocumentVehicleID, DocumentVehicleNumber, DocumentNumber,
		DateFrom, DateTill, DocTypeID, Active)
	SELECT l.ID, l.OwnerID, l.TenantryID, l.CargoID, l.LeaseActVehicleID as DocumentVehicleID,
		l.LeaseActVehicleNumber as DocumentVehicleNumber, l.LeaseActNumber as DocumentNumber, 
		l.Date as DateFrom, v_Infinity as DateTill, l.DocTypeID, false as Active
	FROM lt_LeaseAct l;

INSERT INTO lt_tich (
	ID, OwnerID, TenantryID, CargoID, TechnicalDataSourceID, DocumentVehicleID, DocumentVehicleNumber, DocumentNumber,
	OriginalCountryID, VehicleModelID, Capacity, TareWeight, Caliber, NextMaintenanceDate, MileageFlag, Mileage,
	NextOwnerRecertification, BuildDate, FactoryOfOriginID, MaintenanceAgreement, NextCoatingDate, EnvelopeModernizationDate, DateFrom, DateTill,
	DocTypeID, TechnicalActID, TechnicalActVehicleID, Active, OriginalCountryIDv_DocumentVehicleID,
	VehicleModelIDv_DocumentVehicleID, Capacityv_DocumentVehicleID, TareWeightv_DocumentVehicleID, Caliberv_DocumentVehicleID,
	NextMaintenanceDatev_DocumentVehicleID, MileageFlagv_DocumentVehicleID, Mileagev_DocumentVehicleID, NextOwnerRecertificationv_DocumentVehicleID,
	MaintenanceAgreementv_DocumentVehicleID, NextCoatingDatev_DocumentVehicleID, EnvelopeModernizationDatev_DocumentVehicleID)
	SELECT ID, COALESCE(OwnerID, v_Guid0), TenantryID, CargoID, TechnicalDataSourceID, DocumentVehicleID, DocumentVehicleNumber, DocumentNumber,
		OriginalCountryID, VehicleModelID, Capacity, TareWeight, Caliber, NextMaintenanceDate, MileageFlag, Mileage,
		NextOwnerRecertification, BuildDate, FactoryOfOriginID, MaintenanceAgreement, NextCoatingDate, EnvelopeModernizationDate, DateFrom, DateTill,
		DocTypeID, TechnicalActID, TechnicalActVehicleID, Active, OriginalCountryIDv_DocumentVehicleID,
		VehicleModelIDv_DocumentVehicleID, Capacityv_DocumentVehicleID, TareWeightv_DocumentVehicleID, Caliberv_DocumentVehicleID,
		NextMaintenanceDatev_DocumentVehicleID, MileageFlagv_DocumentVehicleID, Mileagev_DocumentVehicleID, NextOwnerRecertificationv_DocumentVehicleID,
		MaintenanceAgreementv_DocumentVehicleID, NextCoatingDatev_DocumentVehicleID, EnvelopeModernizationDatev_DocumentVehicleID
	FROM lt_RawDocs
	ORDER BY DocumentVehicleNumber, DateFrom, DocTypeID;

raise notice '%: datetill calc started.', CLOCK_TIMESTAMP();

UPDATE lt_tich t
SET DateTill = t1.DateFrom
FROM lt_tich t1
WHERE t.DocumentVehicleNumber = t1.DocumentVehicleNumber
	AND t.OrdinalFrom + 1 = t1.OrdinalFrom;

raise notice '%: techdata calc started.', CLOCK_TIMESTAMP();

WHILE v_cnt > 0 LOOP
	BEGIN
		IF v_SkipFieldsUpdated = false then
			UPDATE lt_tich t1
			SET Active = true,
				OwnerID = CASE t1.OwnerID WHEN v_Guid0 THEN t0.OwnerID ELSE t1.OwnerID END,
				TenantryID = COALESCE(t1.TenantryID, t0.TenantryID), 
				CargoID = COALESCE(t1.CargoID, t0.CargoID), 
				--TechnicalDataSourceID = COALESCE(t1.TechnicalDataSourceID, t0.TechnicalDataSourceID), 
				DocumentNumber = COALESCE(t1.DocumentNumber, t0.DocumentNumber),
				OriginalCountryID = COALESCE(t1.OriginalCountryID, t0.OriginalCountryID), 
				VehicleModelID = COALESCE(t1.VehicleModelID, t0.VehicleModelID), 
				Capacity = COALESCE(t1.Capacity, t0.Capacity), 
				TareWeight = COALESCE(t1.TareWeight, t0.TareWeight), 
				Caliber = COALESCE(t1.Caliber, t0.Caliber), 
				NextMaintenanceDate = COALESCE(t1.NextMaintenanceDate, t0.NextMaintenanceDate), 
				MileageFlag = COALESCE(t1.MileageFlag, t0.MileageFlag), 
				Mileage = CASE WHEN t1.MileageFlag IS NOT NULL THEN t1.Mileage ELSE t0.Mileage END,
				NextOwnerRecertification = CASE t1.OwnerID WHEN v_Guid0 THEN COALESCE(t1.NextOwnerRecertification, t0.NextOwnerRecertification) ELSE t1.NextOwnerRecertification END, -- Относится к владельцу, а не к ТС (не наследуется при переуступке)
				MaintenanceAgreement = COALESCE(t1.MaintenanceAgreement, t0.MaintenanceAgreement),
				NextCoatingDate = COALESCE(t1.NextCoatingDate, t0.NextCoatingDate),
				BuildDate = COALESCE(t1.BuildDate, t0.BuildDate),
				FactoryOfOriginID = COALESCE(t1.FactoryOfOriginID, t0.FactoryOfOriginID),		
				EnvelopeModernizationDate = COALESCE(t1.EnvelopeModernizationDate, t0.EnvelopeModernizationDate), 
				TechnicalActID = COALESCE(t1.TechnicalActID, t0.TechnicalActID),
				TechnicalActVehicleID = COALESCE(t1.TechnicalActVehicleID, t0.TechnicalActVehicleID),
				OriginalCountryIDv_DocumentVehicleID = COALESCE(t1.OriginalCountryIDv_DocumentVehicleID, t0.OriginalCountryIDv_DocumentVehicleID),
				VehicleModelIDv_DocumentVehicleID = COALESCE(t1.VehicleModelIDv_DocumentVehicleID, t0.VehicleModelIDv_DocumentVehicleID),
				Capacityv_DocumentVehicleID = COALESCE(t1.Capacityv_DocumentVehicleID, t0.Capacityv_DocumentVehicleID),
				TareWeightv_DocumentVehicleID = COALESCE(t1.TareWeightv_DocumentVehicleID, t0.TareWeightv_DocumentVehicleID),
				Caliberv_DocumentVehicleID = COALESCE(t1.Caliberv_DocumentVehicleID, t0.Caliberv_DocumentVehicleID),
				NextMaintenanceDatev_DocumentVehicleID = COALESCE(t1.NextMaintenanceDatev_DocumentVehicleID, t0.NextMaintenanceDatev_DocumentVehicleID),
				MileageFlagv_DocumentVehicleID = COALESCE(t1.MileageFlagv_DocumentVehicleID, t0.MileageFlagv_DocumentVehicleID),
				Mileagev_DocumentVehicleID = COALESCE(t1.Mileagev_DocumentVehicleID, t0.Mileagev_DocumentVehicleID),
				NextOwnerRecertificationv_DocumentVehicleID = CASE t1.OwnerID WHEN v_Guid0 THEN COALESCE(t1.NextOwnerRecertificationv_DocumentVehicleID, t0.NextOwnerRecertificationv_DocumentVehicleID) ELSE t1.NextOwnerRecertificationv_DocumentVehicleID END,
				MaintenanceAgreementv_DocumentVehicleID = COALESCE(t1.MaintenanceAgreementv_DocumentVehicleID, t0.MaintenanceAgreementv_DocumentVehicleID),
				NextCoatingDatev_DocumentVehicleID = COALESCE(t1.NextCoatingDatev_DocumentVehicleID, t0.NextCoatingDatev_DocumentVehicleID),
				EnvelopeModernizationDatev_DocumentVehicleID = COALESCE(t1.EnvelopeModernizationDatev_DocumentVehicleID, t0.EnvelopeModernizationDatev_DocumentVehicleID)
			FROM lt_tich t0
			WHERE t0.DocumentVehicleNumber = t1.DocumentVehicleNumber
				AND t0.OrdinalFrom + 1 = t1.OrdinalFrom
				AND t0.Active = true
				AND t1.Active = false;
		ELSE
			UPDATE lt_tich t1
			SET Active = true,
				OwnerID = CASE t1.OwnerID WHEN v_Guid0 THEN t0.OwnerID ELSE t1.OwnerID END,
				TenantryID = COALESCE(t1.TenantryID, t0.TenantryID), 
				CargoID = COALESCE(t1.CargoID, t0.CargoID), 
				--TechnicalDataSourceID = COALESCE(t1.TechnicalDataSourceID, t0.TechnicalDataSourceID), 
				DocumentNumber = COALESCE(t1.DocumentNumber, t0.DocumentNumber),
				OriginalCountryID = COALESCE(t1.OriginalCountryID, t0.OriginalCountryID), 
				VehicleModelID = COALESCE(t1.VehicleModelID, t0.VehicleModelID), 
				Capacity = COALESCE(t1.Capacity, t0.Capacity), 
				TareWeight = COALESCE(t1.TareWeight, t0.TareWeight), 
				Caliber = COALESCE(t1.Caliber, t0.Caliber), 
				NextMaintenanceDate = COALESCE(t1.NextMaintenanceDate, t0.NextMaintenanceDate), 
				MileageFlag = COALESCE(t1.MileageFlag, t0.MileageFlag), 
				Mileage = CASE WHEN t1.MileageFlag IS NOT NULL THEN t1.Mileage ELSE t0.Mileage END,
				NextOwnerRecertification = CASE t1.OwnerID WHEN v_Guid0 THEN COALESCE(t1.NextOwnerRecertification, t0.NextOwnerRecertification) ELSE t1.NextOwnerRecertification END, -- Относится к владельцу, а не к ТС (не наследуется при переуступке)
				MaintenanceAgreement = COALESCE(t1.MaintenanceAgreement, t0.MaintenanceAgreement),
				NextCoatingDate = COALESCE(t1.NextCoatingDate, t0.NextCoatingDate),
				BuildDate = COALESCE(t1.BuildDate, t0.BuildDate),
				FactoryOfOriginID = COALESCE(t1.FactoryOfOriginID, t0.FactoryOfOriginID),		
				EnvelopeModernizationDate = COALESCE(t1.EnvelopeModernizationDate, t0.EnvelopeModernizationDate),
				TechnicalActID = COALESCE(t1.TechnicalActID, t0.TechnicalActID),
				TechnicalActVehicleID = COALESCE(t1.TechnicalActVehicleID, t0.TechnicalActVehicleID)
			FROM lt_tich t0
			WHERE t0.DocumentVehicleNumber = t1.DocumentVehicleNumber
				AND t0.OrdinalFrom + 1 = t1.OrdinalFrom
				AND t0.Active = true
				AND t1.Active = false;
		END IF;
	
		GET DIAGNOSTICS v_cnt = row_count;
		v_cnt_total = v_cnt_total + v_cnt;
		v_while_cnt = v_while_cnt + 1;
	
		if (v_while_cnt % 10) = 0 then
			raise notice '%: % rows updated; step #%', CLOCK_TIMESTAMP(), v_cnt_total, v_while_cnt;
		end if;
	END;
END LOOP;

raise notice '%: % rows proceeded; last step #%', CLOCK_TIMESTAMP(), v_cnt_total, v_while_cnt;

IF v_SkipFieldsUpdated = false then
	UPDATE lt_tich
	SET FieldsUpdatedv_DocumentVehicleID = CAST(
				COALESCE('[OriginalCountryID]={'::varchar(255) || OriginalCountryIDv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[VehicleModelID]={'::varchar(255) || VehicleModelIDv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[Capacity]={'::varchar(255) || Capacityv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[TareWeight]={'::varchar(255) || TareWeightv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[Caliber]={'::varchar(255) || Caliberv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[NextMaintenanceDate]={'::varchar(255) || NextMaintenanceDatev_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[MileageFlag]={'::varchar(255) || MileageFlagv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[Mileage]={'::varchar(255) || Mileagev_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[NextOwnerRecertification]={'::varchar(255) || NextOwnerRecertificationv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[MaintenanceAgreement]={'::varchar(255) || MaintenanceAgreementv_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[NextCoatingDate]={'::varchar(255) || NextCoatingDatev_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
				|| COALESCE('[EnvelopeModernizationDate]={'::varchar(255) || EnvelopeModernizationDatev_DocumentVehicleID::varchar(38) || '}'::varchar(255), '')
			as text);
end if;

raise notice '%: techdata calc completed.', CLOCK_TIMESTAMP();

delete from dbo2.cachetechinfohist where (v_Vehicle is null or VehicleNumber = v_Vehicle);

GET DIAGNOSTICS v_cnt = row_count;
raise notice '%: % expired rows deleted.', CLOCK_TIMESTAMP(), v_cnt;

insert
	into
	dbo2.cachetechinfohist (id,
	ownerid,
	tenantryid,
	cargoid,
	technicaldatasourceid,
	vehicleid,
	vehiclenumber,
	documentnumber,
	originalcountryid,
	vehiclemodelid,
	capacity,
	tareweight,
	caliber,
	nextmaintenancedate,
	mileageflag,
	mileage,
	nextownerrecertification,
	builddate,
	factoryoforiginid,
	maintenanceagreement,
	datefrom,
	datetill,
	doctypeid,
	technicalactid,
	technicalactvehicleid,
	fieldsupdateddocumentvehicleid,
	ordinalfrom,
	nextcoatingdate,
	envelopemodernizationdate)

	select ID,
	OwnerID,
	TenantryID,
	CargoID,
	TechnicalDataSourceID,
	DocumentVehicleID,
	DocumentVehicleNumber,
	DocumentNumber,
	OriginalCountryID,
	VehicleModelID,
	Capacity,
	TareWeight,
	Caliber,
	NextMaintenanceDate,
	MileageFlag,
	Mileage,
	NextOwnerRecertification,
	BuildDate,
	FactoryOfOriginID,
	MaintenanceAgreement,
	DateFrom,
	DateTill,
	DocTypeID,
	TechnicalActID,
	TechnicalActVehicleID,
	FieldsUpdatedv_DocumentVehicleID,
	ordinalfrom,
	NextCoatingDate,
	EnvelopeModernizationDate
	from lt_tich
	;

GET DIAGNOSTICS v_cnt = row_count;
raise notice '%: % rows cached.', CLOCK_TIMESTAMP(), v_cnt;

commit;	-- завершим транзакцию

raise notice '%: Completed.', CLOCK_TIMESTAMP();
end;
$procedure$
;