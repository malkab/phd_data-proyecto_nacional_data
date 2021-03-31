/**

  This transforms and extract the target data to be gridded to the LAEA
  EPSG:3035.

*/
begin;

create schema materialized_views;

create materialized view materialized_views.analisis_centroides as
select
  gid,
  p_cod_ine,
  p_refcat,
  p_mun_refc,
  p_tipo,
  p_parcela,
  p_ipc_4,
  p_df_1,
  p_df_2,
  p_df_3,
  p_df_4,
  p_pu001,
  p_pu002,
  p_pu003,
  p_pu004,
  p_pu005,
  p_pu006,
  p_pu007,
  p_pu008,
  p_pu009,
  p_pu010,
  p_pu011,
  p_pu012,
  p_pu013,
  p_pu014,
  p_pu015,
  p_pu016,
  p_pu017,
  p_pu018,
  p_pu019,
  p_pu020,
  p_pu021,
  p_pu022,
  p_pu023,
  p_pu024,
  p_pu025,
  p_pu026,
  p_pu027,
  p_pu028,
  p_pu029,
  p_dt_1,
  p_dt_2,
  p_dt_3,
  p_dt_4,
  p_dt_5,
  p_dt_6,
  p_dt_7,
  p_dt_8,
  p_dt_9,
  p_dt_10,
  p_dt_11,
  p_dt_12,
  p_dt_13,
  p_dt_14,
  p_dt_15,
  p_dt_17,
  p_dt_18,
  p_dt_19,
  p_dt_20,
  p_dt_21,
  p_dt_22,
  p_dt_23,
  p_dt_24,
  p_dt_25,
  c_num_constru,
  st_transform(p_geom, 3035) as geom_parcela,
  st_transform(p_centroid, 3035) as geom_parcela_centroide,
  st_transform(area_centroide, 3035) as geom_area_centroide,
  -- This should be called geom_volumen_centroide, but at the time of gridding
  -- the script only allowed for geometry columns called "geom"
  st_transform(volumen_centroide, 3035) as geom
from data.analisis_centroides_parcela;

create index idx_geom_parcela_gist
on materialized_views.analisis_centroides
using gist(geom_parcela);

create index idx_geom_parcela_centroide_gist
on materialized_views.analisis_centroides
using gist(geom_parcela_centroide);

create index idx_geom_area_centroide_gist
on materialized_views.analisis_centroides
using gist(geom_area_centroide);

create index idx_geom_volumen_centroide_gist
on materialized_views.analisis_centroides
using gist(geom);

grant usage on schema materialized_views
to cell_readonly, cell_master;

grant all privileges on schema materialized_views
to cell_readonly, cell_master;

grant select on all tables in schema materialized_views
to cell_readonly, cell_master;

commit;
