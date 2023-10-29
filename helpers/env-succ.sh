#!/bin/bash
# env-succ.sh v1.0.0
# ------------------
# by @rawleyfowler on github
# 
# exports all environment variables from a local `.env` file into the current shell environment, 
# then executes a specified command.
# ---------------
export $(cat .env | xargs) && $1
