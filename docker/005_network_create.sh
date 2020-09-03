#!/bin/bash

# -----------------------------------------------------------------
#
# Cell network creation.
#
# -----------------------------------------------------------------
#
# Creates a Docker network.
#
# -----------------------------------------------------------------

# Check mlkcontext to check. If void, no check will be performed
MATCH_MLKCONTEXT=common
# Network name
NETWORK=$MLKC_APP_NAME





# ---

# Check mlkcontext

if [ ! -z "${MATCH_MLKCONTEXT}" ] ; then

  if [ ! "$(mlkcontext)" = "$MATCH_MLKCONTEXT" ] ; then

    echo Please initialise context $MATCH_MLKCONTEXT

    exit 1

  fi

fi

docker network create $NETWORK
