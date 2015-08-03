#!/bin/bash
if [ $# -eq 0 ]
then
  echo "usage: $0 <outputdir>"
else
  cd "$(dirname "$0")"
  [ -d $1 ] || mkdir $1
  cat *.tag > $1/compiled.tag && cd $1
  riot -m compiled.tag Studio.js
  rm compiled.tag
fi