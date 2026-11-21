#!/usr/bin/env bash

recording=0

if pgrep -x wf-recorder >/dev/null 2>&1 ||
   pgrep -x obs >/dev/null 2>&1 ||
   pgrep -f '[g]pu-screen-recorder' >/dev/null 2>&1; then
    recording=1
fi

if (( recording )); then
    printf '{"text":"REC","class":"recording","tooltip":"Screen recording active"}\n'
else
    printf '{"text":"","class":"idle","tooltip":""}\n'
fi
