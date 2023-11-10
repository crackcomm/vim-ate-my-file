#!/bin/sh -e

sel=$(slop -f "-i %i -g %g")
shotgun $sel - | xclip -t 'image/png' -selection clipboard
