#!/bin/bash

# Step 1: Ask for the version
read -p "Enter the version: " version

# Step 2: Create a new git branch
branch_name="release/$version"
git checkout -b "$branch_name"

# Step 3: Replace .changesets/config.json
config_file=".changeset/config.json"
config_content='{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "restricted",
  "baseBranch": "release/'"$version"'",
  "updateInternalDependencies": "patch",
  "ignore": [],
  "privatePackages": { "version": false, "tag": false }
}'
echo "$config_content" > "$config_file"

# Commit the changes
git add "$config_file"
git commit -m "Add changesets config for release $version"

echo "Branch '$branch_name' created with changesets config updated."
