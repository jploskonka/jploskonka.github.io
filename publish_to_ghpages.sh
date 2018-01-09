#!/usr/bin/env bash

DIR=$(dirname "$0")

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out master branch into public"
git worktree add -B master public origin/master

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo

echo "copying CNAME"
cp CNAME public/

echo "Updating master branch"
if [[ $CI ]]; then
  message="[CI] publish_to_gphages.sh"
else
  message="publish_to_ghpages.sh"
fi
cd public && git add --all && git commit -m $message && git push origin master
