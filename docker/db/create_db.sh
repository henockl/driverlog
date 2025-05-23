#!/bin/sh

psql --set=DATABASE=$DATABASE --set=APP=$APP --set=OWNER=$OWNER --set=PASSWORD=$POSTGRES_PASSWORD -d postgres << EOF

\set SCHEMA :APP '_owner'

CREATE ROLE :OWNER PASSWORD :'PASSWORD' LOGIN CREATEDB NOCREATEROLE NOSUPERUSER;
CREATE DATABASE :DATABASE encoding 'utf8' CONNECTION LIMIT 100;
REVOKE ALL ON DATABASE :DATABASE FROM public;
GRANT CONNECT, TEMPORARY, CREATE ON DATABASE :DATABASE TO :OWNER;

\connect :DATABASE

CREATE EXTENSION hstore;
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
CREATE EXTENSION postgis_topology;

CREATE SCHEMA :SCHEMA;
ALTER SCHEMA :SCHEMA OWNER TO :OWNER;

\connect postgres
ALTER DATABASE :DATABASE SET search_path=:SCHEMA,public,pg_temp;
ALTER DATABASE :DATABASE OWNER TO :OWNER;
EOF