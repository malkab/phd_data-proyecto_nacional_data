# Putting Proyecto Nacional Data again into Production

The goal of this work package is to put again the Proyecto Nacional Data into production at a public server.

Proyecto Nacional data contains a lot of information with all the data items computed at the Proyecto Nacional over the full cadastre.


## IMPORTANT NOTICE!

The DVC repo for this proyect was relocated after the last commit. It is now located at **malkab-phd-data/malkab-phd-data-proyecto_nacional_data**. Please repoint the DVC repo if this project is to be revisited.


## Workflow

This was the initial data file recovered from legacy stuff:

7d887ef572295230b53b77b3e5a59343bd738ab3822aeff5b6ac7196fb0a9357 (sha256sum)
datos_finales_proyecto_nacional_postgis_data.tar.gz

This file has been recovered by a **9.6** (candid_candice?) Docker container and exported to a dump file, stored at **data/000_in**:

5d4f8f1880ed47e95ea6d04986a0b454affcdab63fb7bb76c56e2381585c63b8 (sha256sum)
20200702-203247-datos_finales_proyecto-proyecto_nacional_data

This dump has been imported into a **12.3**, reexporting again to create the final product (stored at **malkab-phd-data/data/000-in**):

146d004d80feb5e699dcee217e049d3c31b219aad6c0a0bc7a2f20e1fac73e7d (sha256sum)
20200901_063604_proyecto_nacional
