#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    tput setaf 1
    echo "Root privileges needed. Run the script with sudo." 1>&2
    tput sgr0
    exit 1
fi

# theme name
THEME_NAME=assets
tput setaf 4
echo "------------------------------------------------" 1>&2
echo " Uninstalling $THEME_NAME Grub Theme " 1>&2
echo "------------------------------------------------" 1>&2
tput sgr0

# Remove the installed grub theme folder if it exists
GRUB_DIR=/boot/grub2
if [[ ! -d $GRUB_DIR ]]; then
    GRUB_DIR=/boot/grub
    if [[ ! -d $GRUB_DIR ]]; then
        tput setaf 1
        echo "Could not find the grub directory" 1>&2
        tput sgr0
        exit 1
    fi
fi
THEME_DIR="$GRUB_DIR/themes/$THEME_NAME"
if [[ ! -d "$THEME_DIR" ]]; then
    tput setaf 1
    echo "Theme directory $THEME_DIR does not exist. Nothing to uninstall." 1>&2
    tput sgr0
    exit 1
else
    tput setaf 3
    echo "Deleting theme directory: $THEME_DIR" 1>&2
    tput sgr0
    rm -rf "$THEME_DIR"
fi

# Restore original grub config file if backup exists
GRUB_DEFAULT_FILE="/etc/default/grub"
if [[ -f "${GRUB_DEFAULT_FILE}.bak" ]]; then
    tput setaf 3
    echo "Restoring original grub config file: $GRUB_DEFAULT_FILE" 1>&2
    tput sgr0
    rm -f "$GRUB_DEFAULT_FILE"
    mv "${GRUB_DEFAULT_FILE}.bak" "$GRUB_DEFAULT_FILE"
else
    tput setaf 1
    echo "Backup grub config file (${GRUB_DEFAULT_FILE}.bak) does not exist. Nothing to restore." 1>&2
    tput sgr0
fi

# Update grub configuration
GRUB_MKCONFIG=grub2-mkconfig
if ! command -v $GRUB_MKCONFIG >/dev/null 2>&1 ; then
    GRUB_MKCONFIG=grub-mkconfig
    if ! command -v $GRUB_MKCONFIG >/dev/null 2>&1 ; then
        tput setaf 1
        echo "Could not find grub-mkconfig or grub2-mkconfig" 1>&2
        tput sgr0
        exit 1
    fi
fi

# Update grub config
$GRUB_MKCONFIG -o $GRUB_DIR/grub.cfg

# final message
tput setaf 2
echo "--------------------------------------------------" 1>&2
echo " $THEME_NAME Grub Theme Has Been Uninstalled " 1>&2
echo "--------------------------------------------------" 1>&2
tput sgr0
