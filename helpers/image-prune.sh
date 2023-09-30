#!/bin/bash
IMAGES=$(docker image ls | grep '<none>' | awk '{ print $3 }'); while read p; do docker image rm "$p"; done <<< $IMAGES
