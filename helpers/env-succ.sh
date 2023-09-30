#!/bin/bash
export $(cat .env | xargs) && $1
