#!/bin/bash
# Display git workflow instructions

echo "Setup stack: git checkout --track origin/master -b kcaldwell/project_name"
echo "Make changes"
echo "Make commit message and copy to clibpard: gcm"
echo "Commit changes: git commit"
echo "Paste commit message"
echo "Test things"
echo "Log observations from Argus and copy to clipboard: argus_obs obs1 obs2 | copy"
echo "Add observations to PR: gca"
echo "Paste observations"
