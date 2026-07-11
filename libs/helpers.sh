#!/bin/bash

# Check if a command is available
has_command() {
    command -v "$1" > /dev/null 2>&1
}

# Display how to use this script
usage() {
    echo "usage: $0 [--diff]  # Default. Install not installed packages"
    echo "Usage: $0 [--full] # Install or update everything"
    exit 1
}

# Get script option from the user
get_opt() {
    if [ -z "$1" ]; then
        is_full_install=false
    elif [ "$#" -eq 1 ]; then
        case $1 in
            --full)
                is_full_install=true;;
            --diff)
                is_full_install=false;;
            *)
                usage;;
        esac
    else
        usage
    fi
}