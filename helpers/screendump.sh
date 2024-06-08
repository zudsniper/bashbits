#!/bin/bash
# screendump.sh v0.1.0
#
# creates alias 'screendump' to post all terminal output to termbin.com
# BE CAREFUL THIS WILL EXPOSE ANY SENSITIVE INFORMATION THAT IS WRITTEN TO TERMINAL IN PLAIN TEXT!!
# ---------------------------
# $ source screendump.sh
# $ screendump 
# 
alias screendump='which screen &>/dev/null || sudo apt-get install -y screen; which nc &>/dev/null || sudo apt-get install -y netcat; screen -L -dm bash -c "cat /dev/stdout | nc termbin.com 9999" | tee /tmp/termbin_link && echo \"Termbin link: $(cat /tmp/termbin_link)\"'