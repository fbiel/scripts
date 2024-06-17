#!/bin/zsh

# Function to print colored text
print_colored() {
  local color=$1
  local text=$2
  echo "\033[${color}m${text}\033[0m"
}

# Iterate over directories in the current working directory
for dir in */; do
  if [[ -d "${dir}" ]]; then
    cd "${dir}"
    if git rev-parse --git-dir > /dev/null 2>&1; then
      # Check if there are uncommitted changes
      if [[ -z $(git status --porcelain) ]]; then
        print_colored "32" "${dir%/}: OK (up to date)"
      else
        # Count the number of modified files
        modified_files=$(git status --porcelain | wc -l)
        # Get the current git branch name
        branch_name=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached HEAD")
        print_colored "31" "${dir%/}: ${modified_files} | ${branch_name}"
      fi
    else
      print_colored "33" "${dir%/}: Not a git repository"
    fi
    cd ..
  fi
done