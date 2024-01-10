#!/bin/bash

# -----------------------------------------------------------------
#
# Synchronizes arbitrary assets to S3. If using the -d option, file
# deletion may accur, use with caution. Perform first a dry run (the
# default) to check what will be done.
#
# Assets no longer existing locally will be identified and checked
# if they exists at the target bucket. If so, the user will be
# prompted to delete them, optionally.
#
# WARNING! Perform always a dry run first.
#
# -----------------------------------------------------------------
# Check mlkctxt to check. If void, no check will be performed. Use NOTNULL to
# enforce any context.
MATCH_MLKCTXT=
# Target LFS bucket
TARGET_BUCKET=s3://mlk-lfs
# Arbitrary folders to upload, in the form
# (docker/backups whatever/whatever/folder)
ITEMS=(
  data/900_out/20201230_133949_datos_finales_proyecto_nacional
  data/000_in/20200702-203247-datos_finales_proyecto_nacional-proyecto_nacional_data
)
# Exclude this files from all uploads
EXCLUDES=("*.DS_Store" ".gitignore")
# S3 storage class
STORAGE_CLASS=STANDARD_IA





# ---

# Check mlkctxt
if command -v mlkctxt &> /dev/null ; then

  if [ ! -z "$MATCH_MLKCTXT" ] ; then

    mlkctxtcheck $MATCH_MLKCTXT

    if [ ! $? -eq 0 ] ; then

      echo Invalid context set, required $MATCH_MLKCTXT

      exit 1

    fi

  fi

fi

# Help function
help(){
cat <<EOF
Uploads LFS data to S3, check script config. By default the script is
run dry and without delete.

  ./s3-lfs-upload.sh -o -d -h

Usage:
  -r        Perform the operation (DRYRUN false).
  -d        DELETE true... use with caution!!!
  -h        This help.
EOF

return 0
}

# Default values
DRYRUN=true
DELETE=false

# Options processing
POS=0

while getopts rdh opt ; do
	case "$opt" in
    h) help
        exit 0
        ;;
    r) DRYRUN=false
        ;;
    d) DELETE=true
        ;;
    ?) help
        exit 0
        ;;
	esac
done

# Process DELETE
if [ "$DELETE" = true ] ; then
  DELETE_F="--delete"
else
  DELETE_F=""
fi

# Inform about deletion
if [ "$DELETE" = true ] && [ "$DRYRUN" = false ]; then

  read -p "WARNING! Delete option has been selected. Use with care. If the LFS
content is not present at the repo because is wasn't downloaded, this
can potentially erase data at S3. Please run dry first to be sure.

Proceed? (y/N): " -t 10 STR
  if [ ! "$STR" == "y" ] ; then

	  echo skipping...
    exit 0

  fi

fi


# Interactive documentation, if any
if [ "$DRYRUN" = true ]; then
  DRYRUN_F="--dryrun"
else
  DRYRUN_F=
fi

# Add excludes to an AWS command stored in an AWS_COMMAND env
insert_excludes(){
  if [ ! -z "${EXCLUDES}" ] ; then
    for E in "${EXCLUDES[@]}" ; do
      AWS_COMMAND="${AWS_COMMAND} --exclude \"${E}\" "
    done
  fi
}

# Get the project-family/project path
WP1=${PWD##*/}
cd ..
WP0=${PWD##*/}
cd $WP1
GIT_PROJECT_PATH=$WP0/$WP1

# Uploads arbitrary folders
if [ ! -z "${ITEMS}" ] ; then

  for ITEM in "${ITEMS[@]}" ; do

    echo
    echo --------------------
    echo Uploading $ITEM
    echo --------------------

    # Check if the item exists
    if [ ! -e $ITEM ] ; then

      echo $ITEM does not exist on local, consider removing it at ITEMS...

      DESTINATION=$TARGET_BUCKET/$GIT_PROJECT_PATH/$ITEM

      aws s3 ls $DESTINATION 1> /dev/null

      # If exit code is 0, the item exists at the target bucket
      if [ $? -eq 0 ] ; then

        if [ "$DELETE" = true ] && [ "$DRYRUN" = false ]; then

          read -p "WARNING! Item ${ITEM} was
not found locally, but exists at the remote bucket. Attempt deletion? (y/N): " -t 10 STR

          if [ "$STR" == "y" ] ; then
            aws s3 rm $DESTINATION --recursive
            aws s3 rm $DESTINATION
          else
            echo skipping deletion attempt...
          fi

        fi

      fi

    else

      # Detect if the item is a file or a folder
      if [ ! -f $ITEM ] ; then

        DESTINATION=$TARGET_BUCKET/$GIT_PROJECT_PATH/$ITEM

        AWS_COMMAND="aws s3 sync $DELETE_F $DRYRUN_F \
          --storage-class $STORAGE_CLASS \
          $ITEM $DESTINATION"

        insert_excludes

      else

        # Get the path and the file name
        FOLDER=`dirname $ITEM`
        FILE=`basename $ITEM`

        DESTINATION=$TARGET_BUCKET/$GIT_PROJECT_PATH

        AWS_COMMAND="aws s3 sync $DELETE_F $DRYRUN_F \
          --exclude \"*\" \
          --include \"${ITEM}\" \
          --storage-class $STORAGE_CLASS \
          . $DESTINATION"

      fi

      eval $AWS_COMMAND

    fi

  done

fi

echo
