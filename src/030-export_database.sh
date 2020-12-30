#!/bin/bash

# Version: 2020-12-28

# -----------------------------------------------------------------
#
# Export the database in its current status.
#
# -----------------------------------------------------------------
#
# Creates database backups.
#
# -----------------------------------------------------------------

# Check mlkcontext to check. If void, no check will be performed.
MATCH_MLKCONTEXT=
# Documentation for the backup to be stored in the README.md. Must be quoted.
DOC="Backup of the datos_finales_proyecto_nacional database."
# The network to connect to. Remember that when attaching to the network of an
# existing container (using container:name) the HOST is "localhost".
NETWORK=$MLKC_PROYECTO_NACIONAL_NETWORK
# The DB to dump.
DB=datos_finales_proyecto_nacional
# Dump name suffix. It will prefixed by the name of the database and the
# timestamp.
DUMP_SUFFIX=datos_finales_proyecto_nacional
# Tables to dump, if any, like in (schema.table0 schema.table1 "schema.\"bad
# name\"").
TABLES=
# Schemas to dump, if any, like in (schema0 schema1 "\"schema bad name\"").
SCHEMAS=
# The folder to leave the dump.
BACKUPS_FOLDER=$(pwd)/../data/900_out/
# Encoding.
ENCODING=UTF8
# Container name.
CONTAINER_NAME=
# The version of Docker PG image to use.
POSTGIS_DOCKER_TAG=gargantuan_giraffe
# The host.
HOST=$MLKC_PROYECTO_NACIONAL_DATA_PG_HOST
# The port.
PORT=$MLKC_PROYECTO_NACIONAL_DATA_PG_PORT
# The user.
USER=postgres
# The pass.
PASS=$MLKC_PROYECTO_NACIONAL_DATA_PG_PASS
# Dump format (p plain text, c custom, d directory, t tar).
FORMAT=c
# Verbose.
VERBOSE=true
# Compression level.
ZLEVEL=9





# ---

# Check mlkcontext is present at the system
if command -v mlkcontext &> /dev/null
then

  echo -------------
  echo WORKING AT $(mlkcontext)
  echo -------------

  # Check mlkcontext
  if [ ! -z "${MATCH_MLKCONTEXT}" ] ; then

    if [ ! "$(mlkcontext)" = "$MATCH_MLKCONTEXT" ] ; then

      echo Please initialise context $MATCH_MLKCONTEXT
      exit 1

    fi

  fi

fi

# Create the backup folder
mkdir -p $BACKUPS_FOLDER

# Verbosiness
if [ "$VERBOSE" = true ] ; then VERBOSE="-v" ; else VERBOSE="" ; fi

# Network
if [ ! -z "${NETWORK}" ] ; then NETWORK="--network=${NETWORK}" ; fi

# Container name
if [ ! -z "${CONTAINER_NAME}" ] ; then

    CONTAINER_NAME="--name=${CONTAINER_NAME}"

fi

# Dump name
DUMP_NAME=$(date '+%Y%m%d_%H%M%S')_$DB_$DUMP_SUFFIX

# Dump command processing, mandatory options
DUMP_COMMAND="PGPASSWORD=${PASS} pg_dump -b -F ${FORMAT} ${VERBOSE} \
    -Z ${ZLEVEL} -E ${ENCODING} -f ${DUMP_NAME} \
    -h ${HOST} -p ${PORT} -U ${USER}"

# Add tables and/or schemas, if any
if [ ! -z "${TABLES}" ] ; then

    for TABLE in "${TABLES[@]}" ; do

        DUMP_COMMAND="${DUMP_COMMAND} -t ${TABLE} "

    done

fi

if [ ! -z "${SCHEMAS}" ] ; then

    for SCHEMA in "${SCHEMAS[@]}" ; do

        DUMP_COMMAND="${DUMP_COMMAND} -n ${SCHEMA} "

    done

fi

# Write documentation, if any
if [ ! -z "${DOC}" ] ; then

    echo "$DOC" > $BACKUPS_FOLDER/${DUMP_NAME}_README.md

fi

# Final command run
DUMP_COMMAND="${DUMP_COMMAND} ${DB}"

eval    docker run -ti --rm \
            $NETWORK \
            $CONTAINER_NAME \
            $CONTAINER_HOST_NAME \
            -v $BACKUPS_FOLDER:/ext_src/ \
            --entrypoint /bin/bash \
            --workdir /ext_src/ \
            malkab/postgis:$POSTGIS_DOCKER_TAG \
            -c \"${DUMP_COMMAND}\"
