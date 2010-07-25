#!/bin/bash

if [ -n "$1" ]
then
   knife cookbook upload -o cookbooks/ $1
else
   knife cookbook upload -o cookbooks -a
fi


