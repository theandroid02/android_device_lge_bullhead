#!/bin/bash

#set -e
export DEVICE=bullhead
export VENDOR=lge

echo "Extracting proprietary files..."

if [ $# -eq 0 ]; then
  SRC=adb
else
  if [ $# -eq 1 ]; then
    SRC=$1
  else
    echo "$0: bad number of arguments"
    echo ""
    echo "usage: $0 [PATH_TO_EXPANDED_ROM]"
    echo ""
    echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
    echo "the device using adb pull."
    exit 1
  fi
fi

function extract() {
    for FILE in `egrep -v '(^#|^$)' $1`; do
      OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
      FILE=`echo ${PARSING_ARRAY[0]} | sed -e "s/^-//g"`
      echo "Extracting $FILE..."
      DEST=${PARSING_ARRAY[1]}
      if [ -z $DEST ]; then
        DEST=$FILE
      fi
      DIR=`dirname $FILE`
      if [ ! -d $BASE/$DIR ]; then
        if [ $(echo $DIR | grep system) ]; then
            DIR2=${DIR#'system/'}
            mkdir -p $BASE/$DIR2
        elif [ $(echo $DIR | grep vendor) ]; then
            DIR2=${DIR#'vendor/'}
            mkdir -p $BASE/$DIR2
        fi
      fi
      if [ -z $SRC/$DEST ]; then
          if [ $(echo $DEST | grep system) ]; then
              DEST=${DEST#'system/'}
          elif [ $(echo $DEST | grep vendor) ]; then
              DEST=${DEST#'vendor/'}
          fi
          cp $SRC/$DEST $BASE/$DEST
      else
          DIR=`dirname $DEST`
          if [ ! -d $BASE/$DIR ]; then
              mkdir -p $2/$DIR
          fi
          if [ $(echo $DEST | grep system) ]; then
              DEST=${DEST#'system/'}
          elif [ $(echo $DEST | grep vendor) ]; then
              DEST=${DEST#'vendor/'}
          fi
          cp $SRC/$FILE $BASE/$DEST
      fi
    done
}

BASE=../../../vendor/$VENDOR/$DEVICE/proprietary
rm -rf $BASE/*

extract ../../$VENDOR/$DEVICE/proprietary-blobs.txt $BASE

./setup-makefiles.sh
