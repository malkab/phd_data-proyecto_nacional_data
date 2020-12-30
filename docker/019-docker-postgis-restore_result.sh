#!/bin/bash

# -----------------------------------------------------------------
#
# This restore restores the resulting, postprocessed dump
# 20200901_063604_proyecto_nacional.
#
# -----------------------------------------------------------------
#
# Restores a database in a PostgreSQL container.
#
# -----------------------------------------------------------------

# Check mlkcontext to check. If void, no check will be performed
MATCH_MLKCONTEXT=
# Dump name to restore, including any folder, relative to this script's
# folder
DUMP_NAME=../data/900_out/20200901_063604_proyecto_nacional
# The network to connect to. Remember that when attaching to the network
# of an existing container (using container:name) the HOST is
# "localhost"
NETWORK=$MLKC_PROYECTO_NACIONAL_APP_NAME
# Admin DB
ADMIN_DB=postgres
# Host
HOST=$MLKC_PROYECTO_NACIONAL_DATA_HOST
# Port
PORT=5432
# User
USER=postgres
# Pass
PASS=$MLKC_PROYECTO_NACIONAL_DATA_POSTGIS_PASSWORD
# The version of Docker PG image to use
POSTGIS_DOCKER_TAG=gargantuan_giraffe
# Container name
CONTAINER_NAME=
# Verbose
VERBOSE=true
# Dump format (p plain text, c custom, d directory, t tar)
FORMAT=c
# Create database
CREATE=true





# ---

# Check mlkcontext
if [ ! -z "${MATCH_MLKCONTEXT}" ] ; then

  if [ ! "$(mlkcontext)" = "$MATCH_MLKCONTEXT" ] ; then

    echo Please initialise context $MATCH_MLKCONTEXT

    exit 1

  fi

fi

# Help function
help(){
cat <<EOF
Dumps a database with Docker, change parameters in the script.

    ./docker-postgis-backup-restore -q -h

Usage:
    -q    Quiet mode: do not ask for interactive
          documentation of the backup.
    -h    This help.
EOF

return 0
}

# Options processing
POS=0

while getopts :hq opt
do
	case "$opt" in
	    h) help
           exit 0
	       ;;
	    q) VERBOSE=false
	       ;;
	    ?) help
           exit 0
	       ;;
	esac
done

# Verbosiness
if [ "$VERBOSE" = true ]; then VERBOSE="-v"; else VERBOSE="" ; fi

# Create database
if [ "$CREATE" = true ]; then CREATE="-C"; else CREATE="" ; fi

# Network
if [ ! -z "${NETWORK}" ]; then NETWORK="--network=${NETWORK}"; fi

# Container name
if [ ! -z "${CONTAINER_NAME}" ];
    then CONTAINER_NAME="--name=${CONTAINER_NAME}"; fi

# Dump command processing, mandatory options
RESTORE_COMMAND="PGPASSWORD=${PASS} pg_restore \
    ${CREATE} -d ${ADMIN_DB} -F ${FORMAT} ${VERBOSE} \
    -h ${HOST} -p ${PORT} -U ${USER} dump"

# Final command run
eval    docker run -ti --rm \
            $NETWORK \
            $CONTAINER_NAME \
            $CONTAINER_HOST_NAME \
            -v $(pwd)/$DUMP_NAME:/ext_src/dump \
            --entrypoint /bin/bash \
            --workdir /ext_src/ \
            malkab/postgis:$POSTGIS_DOCKER_TAG \
            -c \"${RESTORE_COMMAND}\"
