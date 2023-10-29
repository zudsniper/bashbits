#!/bin/bash
# image-prune.sh v1.0.0
# --------------
# by @rawleyfowler on github
# 
# removes all Docker images that have the tag <none> by identifying their IDs and then deleting them.
# ---------------
# > "nice lil one-liner @rawleyfowler"   
# > -- @zudsniper
IMAGES=$(docker image ls | grep '<none>' | awk '{ print $3 }'); while read p; do docker image rm "$p"; done <<< $IMAGES
