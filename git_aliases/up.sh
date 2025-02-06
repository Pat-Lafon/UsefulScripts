#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: gup <remote> <branch>"
  return 1
fi

if [ -z "$2" ]; then
  echo "Usage: gup <remote> <branch>"
  return 1
fi

git fetch "$1" && git rebase "$1/$2"
