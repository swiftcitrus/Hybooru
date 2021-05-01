CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS intarray;

DROP TABLE IF EXISTS meta CASCADE;
CREATE TABLE meta (
  id INTEGER PRIMARY KEY DEFAULT 39,
  hash INTEGER DEFAULT 0
);

INSERT INTO meta DEFAULT VALUES;

CREATE OR REPLACE FUNCTION format_date(TIMESTAMPTZ) RETURNS TEXT
  AS $$ SELECT to_char($1 AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'); $$
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION array_union(acc INTEGER[], val INTEGER[]) RETURNS INTEGER[]
   AS $$ SELECT acc | val; $$
   LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE AGGREGATE union_agg (INTEGER[]) (
  SFUNC = array_union,
  STYPE = INTEGER[],
  INITCOND = '{}',
  PARALLEL = SAFE
);

CREATE OR REPLACE FUNCTION array_intersection(acc INTEGER[], val INTEGER[]) RETURNS INTEGER[]
   AS $$ SELECT acc & val; $$
   LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION array_intersection_final(val INTEGER[]) RETURNS INTEGER[]
   AS $$ SELECT COALESCE(val, '{}'); $$
   LANGUAGE SQL IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE AGGREGATE intersection_agg (INTEGER[]) (
  SFUNC = array_intersection,
  FINALFUNC = array_intersection_final,
  STYPE = INTEGER[],
  PARALLEL = SAFE
);


DROP TABLE IF EXISTS global CASCADE;
CREATE TABLE global (
  id INTEGER PRIMARY KEY DEFAULT 39,
  thumbnail_width INTEGER NOT NULL,
  thumbnail_height INTEGER NOT NULL,
  posts INTEGER NOT NULL,
  tags INTEGER NOT NULL,
  mappings INTEGER NOT NULL,
  needs_tags INTEGER NOT NULL,
  rating_stars INTEGER
);

DROP TABLE IF EXISTS posts CASCADE;
CREATE TABLE posts (
  id INTEGER PRIMARY KEY,
  hash BYTEA NOT NULL,
  size INTEGER,
  width INTEGER,
  height INTEGER,
  duration FLOAT,
  num_frames INTEGER,
  has_audio BOOLEAN,
  rating FLOAT,
  mime INTEGER,
  posted TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TABLE IF EXISTS urls CASCADE;
CREATE TABLE urls (
  id INTEGER,
  postid INTEGER NOT NULL,
  url TEXT NOT NULL,

  PRIMARY KEY(id, postid)
);

DROP TABLE IF EXISTS tags CASCADE;
CREATE TABLE tags (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  subtag TEXT NOT NULL,
  used INTEGER NOT NULL DEFAULT 0
);

DROP TABLE IF EXISTS namespaces CASCADE;
CREATE TABLE namespaces (
  id INTEGER PRIMARY KEY,
  name TEXT,
  color TEXT NOT NULL
);

DROP TABLE IF EXISTS mappings CASCADE;
CREATE TABLE mappings (
  postid INTEGER NOT NULL,
  tagid INTEGER NOT NULL,

  PRIMARY KEY(postid, tagid)
);
