/**

  SQL table creation to recreate the municipio table. EPSG: 3035 (LAEA)

*/

begin;

create table caca.municipio(
  gid integer primary key,
  cod_mun character varying(10),
  municipio character varying(50),
  provincia character varying(20),
  cod_ent character varying(10),
  geom geometry(MultiPolygon,3035)
);

create index municipio_geom_gist
on caca.municipio using gist(geom);

\copy caca.municipio from 'municipio.csv' with csv header quote '"' encoding 'utf-8' null '-'

commit;

vacuum analyze caca.municipio;
