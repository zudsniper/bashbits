#!/bin/bash
# screendump.sh v0.0.1
#
# creates alias 'screendump' to post all terminal output to termbin.com
# BE CAREFUL THIS WILL EXPOSE ANY SENSITIVE INFORMATION THAT IS WRITTEN TO TERMINAL IN PLAIN TEXT!!
# ---------------------------
# $ source screendump.sh
# $ screendump 
# 
alias screendump='which screen &>/dev/null || sudo apt-get install -y screen; which nc &>/dev/null || sudo apt-get install -y netcat; screen -L -dm bash -c "cat /dev/stdout | nc termbin.com 9999"'