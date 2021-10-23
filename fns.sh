#!/bin/bash

cap() { read foo; printf -v tmp "$foo" }
ret() { echo $tmp }

