#!/bin/bash

# Check if a command is available
has_command() {
    command -v "$1" > /dev/null 2>&1
}

# Display how to use this script
usage() {
    cat >&2 <<EOF
usage: $0 [--diff]  # Default. Install not installed packages
Usage: $0 [--full] # Install or update everything
EOF
    exit 1
}

# Get script option from the user
get_opt() {
    case $1 in
        --full)
            is_full_install=true;;
        --diff)
            is_full_install=false;;
        *)
            usage;;
    esac
}

# Log helper
log() {
    echo "$@"
}