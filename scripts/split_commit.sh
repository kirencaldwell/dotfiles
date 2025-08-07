#!/bin/bash
# Split a commit into multiple commits

echo "Splitting commit 'git reset HEAD^'"
git reset HEAD^
echo "Now add files and make commits to split into multiple commits"
