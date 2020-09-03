# Putting Proyecto Nacional Data again into Production

The goal of this work package is to put again the Proyecto Nacional Data into production at a public server. 

Proyecto Nacional data contains a lot of information with all the data items computed at the Proyecto Nacional over the full cadastre.



## Workflow

This was the initial data file recovered from legacy stuff:

7d887ef572295230b53b77b3e5a59343bd738ab3822aeff5b6ac7196fb0a9357
datos_finales_proyecto_nacional_postgis_data.tar.gz

This file is stored at **euler:/mnt/samsung1500/phd-temp** for final deletion. It contains a PostgreSQL 9.6 data folder.

This file has been recovered by a **9.6** (candid_candice?) Docker container and exported to a dump file, stored at **data/000_in**:

5d4f8f1880ed47e95ea6d04986a0b454affcdab63fb7bb76c56e2381585c63b8
20200702-203247-datos_finales_proyecto-proyecto_nacional_data

This is the final product.
