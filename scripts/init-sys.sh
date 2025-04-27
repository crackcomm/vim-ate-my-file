#!/bin/bash

sed -i 's/XKBOPTIONS=""/XKBOPTIONS="caps:escape"/g' /etc/default/keyboard
setupcon

