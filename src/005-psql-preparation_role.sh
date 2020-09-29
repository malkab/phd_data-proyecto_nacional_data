#!/bin/bash

# Version 2020-09-28

# -----------------------------------------------------------------
#
# psql session to DB.
#
# -----------------------------------------------------------------
#
# Creates a volatile PostGIS container to either create an interactive
# psql session or run a SQL script with the same client.
#
# -----------------------------------------------------------------

# Check mlkcontext to check. If void, no check will be performed
MATCH_MLKCONTEXT=
# The network to connect to. Remember that when attaching to the network
# of an existing container (using container:name) the HOST is
# "localhost"
NETWORK=
# These two options are mutually excluyent. Use null at both for
# an interactive psql session. In case of passing a script, files
# must exist at a mounted volume at the VOLUMES section.
SCRIPT=
COMMAND="create role nacional password '${MLKC_PROYECTO_NACIONAL_DATA_NACIONAL_PASSWORD}';"
# Container name
CONTAINER_NAME=$MLKC_PHD_DATA_APP_psql
# Container host name
CONTAINER_HOST_NAME=$MLKC_PHD_DATA_APP_psql
# Work dir
WORKDIR=/ext_src/
# The version of Docker PG image to use
POSTGIS_DOCKER_TAG=gargantuan_giraffe
# The host
HOST=$MLKC_PROYECTO_NACIONAL_DATA_HOST
# The port
PORT=$MLKC_PROYECTO_NACIONAL_DATA_PG_EXTERNAL_PORT
# The user
USER=postgres
# The pass
PASS=$MLKC_PROYECTO_NACIONAL_DATA_POSTGRES_PASSWORD
# The DB
DB=postgres
# Declare volumes, a line per volume, complete in source:destination
# form. No strings needed, $(pwd)/../data/:/ext_src/ works perfectly
VOLUMES=(
  $(pwd):/ext_src/
)
# Output to files. This will run the script silently and
# output results and errors to out.txt and error.txt. Use only
# if running a script or command (-f -c SCRIPT parameter).
OUTPUT_FILES=false





# ---

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

if [ ! -z "${NETWORK}" ] ; then NETWORK="--network=${NETWORK}" ; fi

if [ ! -z "${CONTAINER_NAME}" ] ; then

  CONTAINER_NAME="--name=${CONTAINER_NAME}"

fi

if [ ! -z "${CONTAINER_HOST_NAME}" ] ; then

  CONTAINER_HOST_NAME="--hostname=${CONTAINER_HOST_NAME}"

fi

VOLUMES_F=

if [ ! -z "${VOLUMES}" ] ; then

  for E in "${VOLUMES[@]}" ; do

    VOLUMES_F="${VOLUMES_F} -v ${E} "

  done

fi

if [ ! -z "${SCRIPT}" ] ; then

  SCRIPT="-f ${SCRIPT}"

fi

if [ ! -z "${COMMAND}" ] ; then

  COMMAND="-c \\\"${COMMAND}\\\""

fi

if [ ! -z "${WORKDIR}" ] ; then

  WORKDIR="--workdir ${WORKDIR}"

fi

if [ "$OUTPUT_FILES" == "true" ] ; then

  OUTPUT_FILES=" 1>out.txt 2>error.txt"

else

  OUTPUT_FILES=""

fi

eval    docker run -ti --rm \
          $NETWORK \
          $CONTAINER_NAME \
          $CONTAINER_HOST_NAME \
          $VOLUMES_F \
          $WORKDIR \
          --entrypoint /bin/bash \
          malkab/postgis:$POSTGIS_DOCKER_TAG \
          -c "\"PGPASSWORD=${PASS} psql -h ${HOST} -p ${PORT} -U ${USER} ${DB} ${SCRIPT} ${COMMAND} ${OUTPUT_FILES}\""
