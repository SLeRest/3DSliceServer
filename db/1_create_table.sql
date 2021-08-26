CREATE SCHEMA "3DSLICESERVER";

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
	  NEW."UPDATED_AT" = NOW();
	  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE "3DSLICESERVER"."PART" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"NAME" varchar(255) NOT NULL,
	"UNIT" varchar(10) NOT NULL,
	"FILE" bytea,
	"FILE_SIZE" bigint DEFAULT NULL,
	"FORMAT" varchar(10) NOT NULL,
	"VOLUME" float DEFAULT NULL,
	"VOLUME_SUPPORT" float DEFAULT NULL,
	"X" float DEFAULT NULL,
	"Y" float DEFAULT NULL,
	"Z" float DEFAULT NULL,
	"CREATED_AT" timestamp without time zone NOT NULL DEFAULT now(),
	"UPDATED_AT" timestamp without time zone NOT NULL DEFAULT now()
);
ALTER SEQUENCE "3DSLICESERVER"."PART_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_part
BEFORE UPDATE ON "3DSLICESERVER"."PART"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE "3DSLICESERVER"."GROUP" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"NAME" varchar(255) NOT NULL UNIQUE,
	"CREATED_AT" timestamp without time zone NOT NULL DEFAULT now(),
	"UPDATED_AT" timestamp without time zone NOT NULL DEFAULT now()
);
ALTER SEQUENCE "3DSLICESERVER"."GROUP_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_group
BEFORE UPDATE ON "3DSLICESERVER"."GROUP"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE "3DSLICESERVER"."USER" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"USERNAME" varchar(255) NOT NULL UNIQUE,
	"EMAIL" varchar(255) NOT NULL UNIQUE,
	"PASSWORD" text NOT NULL,
	"DISABLE" boolean DEFAULT TRUE,
	"SUPERUSER" boolean DEFAULT FALSE,
	"CREATED_AT" timestamp without time zone NOT NULL DEFAULT now(),
	"UPDATED_AT" timestamp without time zone NOT NULL DEFAULT now()
);
ALTER SEQUENCE "3DSLICESERVER"."USER_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_user
BEFORE UPDATE ON "3DSLICESERVER"."USER"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE "3DSLICESERVER"."USER_GROUP" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"USER_ID" integer NOT NULL, -- foreign key
	"GROUP_ID" integer NOT NULL, -- foreign key
	"CREATED_AT" timestamp without time zone NOT NULL DEFAULT now(),
	"UPDATED_AT" timestamp without time zone NOT NULL DEFAULT now(),

	CONSTRAINT "USER" FOREIGN KEY ("USER_ID")
	REFERENCES "3DSLICESERVER"."USER" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT "GROUP" FOREIGN KEY ("GROUP_ID")
	REFERENCES "3DSLICESERVER"."GROUP" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
ALTER SEQUENCE "3DSLICESERVER"."USER_GROUP_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_user_group
BEFORE UPDATE ON "3DSLICESERVER"."USER_GROUP"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

--  TODO Trigger after insert/update dans permission pour check si
-- USER_ID et GROUP_ID ne sont pas NULL en meme temp

CREATE TABLE "3DSLICESERVER"."PERMISSION" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"USER_ID" integer DEFAULT NULL, -- foreign key
	"GROUP_ID" integer DEFAULT NULL, -- foreign key
	"PART_ID" integer NOT NULL,
	"READ" boolean DEFAULT FALSE,
	"WRITE" boolean DEFAULT FALSE,
	"DELETE" boolean DEFAULT FALSE,
	"CREATED_AT" timestamp without time zone NOT NULL DEFAULT now(),
	"UPDATED_AT" timestamp without time zone NOT NULL DEFAULT now(),

	CONSTRAINT "USER" FOREIGN KEY ("USER_ID")
	REFERENCES "3DSLICESERVER"."USER" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT "GROUP" FOREIGN KEY ("GROUP_ID")
	REFERENCES "3DSLICESERVER"."GROUP" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT "PART" FOREIGN KEY ("PART_ID")
	REFERENCES "3DSLICESERVER"."PART" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
ALTER SEQUENCE "3DSLICESERVER"."PERMISSION_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_permission
BEFORE UPDATE ON "3DSLICESERVER"."PERMISSION"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE "3DSLICESERVER"."TECHNOLOGIE" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"NAME" varchar(255) NOT NULL
);
ALTER SEQUENCE "3DSLICESERVER"."TECHNOLOGIE_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_technologie
BEFORE UPDATE ON "3DSLICESERVER"."TECHNOLOGIE"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE "3DSLICESERVER"."SLICER" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"NAME" varchar(255) NOT NULL,
	"VERSION" varchar(10) NOT NULL
);
ALTER SEQUENCE "3DSLICESERVER"."SLICER_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_slicer
BEFORE UPDATE ON "3DSLICESERVER"."SLICER"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE "3DSLICESERVER"."MACHINE" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"MANUFACTURER" varchar(255) NOT NULL,
	"MODEL" varchar(255) NOT NULL,
	"MODE" varchar(255) DEFAULT NULL,
	"POWER" varchar(255) DEFAULT NULL,
	"AM_PROCESS" varchar(255) DEFAULT NULL,
    "GENERAL_MATERIAL_TYPE" varchar(255) DEFAULT NULL,
    "SPECIFIC_MATERIAL_TYPE" varchar(255) DEFAULT NULL,
    "X" float DEFAULT NULL,
    "Y" float DEFAULT NULL,
    "Z" float DEFAULT NULL
);
ALTER SEQUENCE "3DSLICESERVER"."MACHINE_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_machine
BEFORE UPDATE ON "3DSLICESERVER"."MACHINE"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE "3DSLICESERVER"."MATERIAL" (
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"SUPPLIER" varchar(255) NOT NULL,
	"NAME" varchar(255) NOT NULL,
    "GENERAL_TYPE" varchar(255) NOT NULL,
    "SPECIFIC_TYPE" varchar(255) NOT NULL,
	"AM_PROCESS" varchar(255) DEFAULT NULL,
	"POST_PROCESS" BOOLEAN DEFAULT NULL,
	"ULTIMATE_TENSILE_STRENGTH_MIN" float DEFAULT NULL, -- (MPa)
	"ULTIMATE_TENSILE_STRENGTH_MAX" float DEFAULT NULL, -- (MPa)
	"TENSILE_MODULUS_MIN" float DEFAULT NULL, -- (MPa)
	"TENSILE_MODULUS_MAX" float DEFAULT NULL, -- (MPa)
	"ELONGATION_AT_BREAK_MIN" float DEFAULT NULL, -- (%)
	"ELONGATION_AT_BREAK_MAX" float DEFAULT NULL, -- (%)
	"FLEXURAL_STRENGTH_MIN" float DEFAULT NULL, -- (MPa)
	"FLEXURAL_STRENGTH_MAX" float DEFAULT NULL, -- (MPa)
	"FLEXURAL_MODULUS_MIN" float DEFAULT NULL, -- (MPa)
	"FLEXURAL_MODULUS_MAX" float DEFAULT NULL, -- (MPa)
	"HARDNESS_SHORE_SCALE" varchar(255) DEFAULT NULL, -- (MPa)
	"HARDNESS_MIN" float DEFAULT NULL, -- TODO type ?
	"HARDNESS_MAX" float DEFAULT NULL, -- TODO type ?
	"HDT_MIN" float DEFAULT NULL, -- (C)
	"HDT_MAX" float DEFAULT NULL, -- (C)
	"GLASS_TRANSITION_TEMP_MIN" float DEFAULT NULL, -- (C)
	"GLASS_TRANSITION_TEMP_MAX" float DEFAULT NULL, -- (C)
	"PART_DENSITY" float DEFAULT NULL, -- (g/cm3)
	"FLAMMABILITY" varchar(255) DEFAULT NULL, -- TODO se renseigner sur les categories
	"USP_CLASS_VI_CERTIFIED" boolean DEFAULT NULL, -- TODO certification qui correspond a quoi ?
	"AVAILABILITY" boolean DEFAULT NULL -- TODO surement un bool, a check, on met string pour l'instant
);
ALTER SEQUENCE "3DSLICESERVER"."MATERIAL_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_material
BEFORE UPDATE ON "3DSLICESERVER"."MATERIAL"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();


CREATE TABLE "3DSLICESERVER"."SLICE" ( -- TODO check si on peut creer des nom de schema qui commence avec un number
	"ID" SERIAL PRIMARY KEY NOT NULL,
	"GCODE" text DEFAULT NULL,
	"PRINT_TIME" interval DEFAULT NULL,
	"SLICE_TIME" interval DEFAULT NULL,
	"PART_ID" integer DEFAULT NULL, -- foreign key
	"STATUS" varchar(50) DEFAULT NULL,
	"COLOR" varchar(10)[] DEFAULT NULL, -- peut avoir plusieurs couleurs, format RGB
	"SLICER_ID" integer DEFAULT NULL, -- foreign key
	"MATERIAL_ID" integer DEFAULT NULL, -- foreign key
	"MACHINE_ID" integer DEFAULT NULL, -- foreign key
	"CREATED_AT" timestamp without time zone NOT NULL DEFAULT now(),
	"UPDATED_AT" timestamp without time zone NOT NULL DEFAULT now(),

	CONSTRAINT "PART" FOREIGN KEY ("PART_ID")
	REFERENCES "3DSLICESERVER"."PART" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE SET NULL,


	CONSTRAINT "SLICER" FOREIGN KEY ("SLICER_ID")
	REFERENCES "3DSLICESERVER"."SLICER" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE SET NULL,

	CONSTRAINT "MATERIAL" FOREIGN KEY ("MATERIAL_ID")
	REFERENCES "3DSLICESERVER"."MATERIAL" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE SET NULL,

	CONSTRAINT "MACHINE" FOREIGN KEY ("MACHINE_ID")
	REFERENCES "3DSLICESERVER"."MACHINE" ("ID") MATCH SIMPLE
	ON UPDATE CASCADE
	ON DELETE SET NULL
);
ALTER SEQUENCE "3DSLICESERVER"."SLICE_ID_seq" RESTART WITH 1453;

CREATE TRIGGER set_timestamp_slice
BEFORE UPDATE ON "3DSLICESERVER"."SLICE"
FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp();
