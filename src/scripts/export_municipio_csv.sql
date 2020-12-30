/**

  Extract municipio table

*/
\copy (select gid, cod_mun, municipio, provincia, cod_ent, st_transform(geom, 3035) as geom from context.municipio) to ../../data/900_out/municipio.csv with csv header quote '"' encoding 'utf-8' null '-'
