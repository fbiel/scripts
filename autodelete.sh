#!/bin/bash

# Check that an argument has been provided
if [ -z "$1" ]
then
  echo "Usage: $0 directory_path"
  exit 1
fi

# Loop through the directory and all subdirectories
find "$1" -type f -mtime +30 -delete
find "$1" -type d -empty -delete