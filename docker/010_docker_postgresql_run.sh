#!/bin/bash

# -----------------------------------------------------------------
#
# Document here the purpose of the script.
#
# -----------------------------------------------------------------
#
# Creates a container with an instance of PostgreSQL, either interactive
# and volatile or persistent in a volume.
#
# -----------------------------------------------------------------

# Check mlkcontext to check. If void, no check will be performed
MATCH_MLKCONTEXT=common
# Volatile (-ti --rm or -d)
VOLATILE=true
# Network to connect to. Remember that when attaching to the network
# of an existing container (using container:name) the HOST is
# "localhost". Keep in mind that linking to a container and using the -p
# option for debugging results in a conflict. Use an external network if
# both features are needed
NETWORK=$MLKC_APP_NAME
# The port to expose to the host
PORT=5434
# Container name, this is the HOST to connect to in a Docker network
CONTAINER_NAME=proyecto_nacional_data_latest
# Container host name
CONTAINER_HOST_NAME=proyecto_nacional_data_latest
# A set of volumes in the form ("source:destination" "source:destination")
VOLUMES=(
  $(pwd):/ext-src
)
# The data dir can be a folder routed with $(pwd) or a name for a
# system-wide volume, or even drop it altogether for in-container data
PG_DATA_DIR=$(pwd)/../docker_persistent_volumes
# The version of PG to use
PG_DOCKER_TAG=gargantuan_giraffe
# Locale
LOCALE=en_US
# postgresql.conf config
POSTGRESQL_CONF=
# pg_hba.conf config
PG_HBA_CONF=
# postgres user password (postgres if blank)
PASSWORD=





# ---

# Check mlkcontext

if [ ! -z "${MATCH_MLKCONTEXT}" ] ; then

  if [ ! "$(mlkcontext)" = "$MATCH_MLKCONTEXT" ] ; then

    echo Please initialise context $MATCH_MLKCONTEXT

    exit 1

  fi

fi

# Command string

if [ ! -z "${NETWORK}" ]; then NETWORK="--network=${NETWORK}" ; fi

if [ ! -z "${CONTAINER_NAME}" ]; then CONTAINER_NAME="--name=${CONTAINER_NAME}" ; fi

if [ ! -z "${PG_DATA_DIR}" ]; then PG_DATA_DIR="-v ${PG_DATA_DIR}:/data/" ; fi

if [ ! -z "${CONTAINER_HOST_NAME}" ]; then CONTAINER_HOST_NAME="--hostname=${CONTAINER_HOST_NAME}" ; fi

if [ ! -z "${POSTGRESQL_CONF}" ]; then POSTGRESQL_CONF="-v ${POSTGRESQL_CONF}:/default_confs/postgresql.conf" ; fi

if [ ! -z "${PASSWORD}" ]; then PASSWORD="-e PASSWORD=${PASSWORD}" ; fi

if [ ! -z "${PG_HBA_CONF}" ]; then PG_HBA_CONF="-v ${PG_HBA_CONF}:/default_confs/pg_hba.conf" ; fi

if [ "$VOLATILE" = true ] ; then

    INTERACTIVE="--rm -ti"

else

    INTERACTIVE="-d"

fi

VOLUMES_F=

if [ ! -z "${VOLUMES}" ] ; then

  for E in "${VOLUMES[@]}" ; do

    VOLUMES_F="${VOLUMES_F} -v ${E} "

  done

fi

eval    docker run $INTERACTIVE \
            $NETWORK \
            $CONTAINER_NAME \
            $CONTAINER_HOST_NAME \
            $VOLUMES_F \
            $PG_DATA_DIR \
            $POSTGRESQL_CONF \
            $PG_HBA_CONF \
            $PASSWORD \
            -e "LOCALE=${LOCALE}" \
            -p $PORT:5432 \
            malkab/postgis:$PG_DOCKER_TAG
