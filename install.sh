#!/bin/bash

# root privileges check
if [[ $EUID -ne 0 ]]; then
    tput setaf 1
    printf "\n"
    echo "Root privileges needed. Run the script with sudo." 1>&2
    printf "\n"
    tput sgr0
    exit 1
fi

# theme name
THEME_NAME=assets
tput setaf 4
printf "\n"
echo "----------------------------------------------" 1>&2
echo " Installing $THEME_NAME Grub Theme " 1>&2
echo "----------------------------------------------" 1>&2
printf "\n"
tput sgr0

# grub directory check
GRUB_DIR=/boot/grub2
if [[ ! -d $GRUB_DIR ]]; then
    GRUB_DIR=/boot/grub
    if [[ ! -d $GRUB_DIR ]]; then
        tput setaf 1
        printf "\n"
        echo "Could not find the grub directory" 1>&2
        printf "\n"
        tput sgr0
        exit 1
    fi
fi

# update-grub command check
GRUB_MKCONFIG=grub2-mkconfig
if ! command -v $GRUB_MKCONFIG >/dev/null 2>&1 ; then
    GRUB_MKCONFIG=grub-mkconfig
    if ! command -v $GRUB_MKCONFIG >/dev/null 2>&1 ; then
        tput setaf 1
        printf "\n"
        echo "Command '$GRUB_MKCONFIG' not found" 1>&2
        printf "\n"
        tput sgr0
        exit 1
    fi
fi

# Font size input validation
printf "\n"
read -p "Enter your desired font size (points): " FONT_SIZE 1>&2
printf "\n"
if ! [[ "$FONT_SIZE" =~ ^[1-9][0-9]*$|^0$ ]]; then
    tput setaf 1
    printf "\n"
    echo "Invalid input. Please enter a valid number in points." 1>&2
    printf "\n"
    tput sgr0
    exit 1
fi
tput setaf 3
printf "\n"
echo "Selected font size: $FONT_SIZE points" 1>&2
printf "\n"
tput sgr0
grub-mkfont -s $FONT_SIZE -o ./$THEME_NAME/custom.pf2 ./$THEME_NAME/original.ttf

# Boot time input validation
printf "\n"
read -p "Enter boot time to delay automatic boot (seconds): " BOOT_TIME 1>&2
printf "\n"
if ! [[ "$BOOT_TIME" =~ ^[1-9][0-9]*$|^0$ ]]; then
    tput setaf 1
    printf "\n"
    echo "Invalid input. Please enter a valid number in seconds." 1>&2
    printf "\n"
    tput sgr0
    exit 1
fi
tput setaf 3
printf "\n"
echo "Selected boot time: $BOOT_TIME seconds" 1>&2
printf "\n"
tput sgr0

# Replace GRUB_TIMEOUT variable
GRUB_DEFAULT_FILE="/etc/default/grub"
if [[ ! -f "$GRUB_DEFAULT_FILE" ]]; then
    tput setaf 1
    printf "\n"
    echo "File $GRUB_DEFAULT_FILE does not exist. Exiting." 1>&2
    printf "\n"
    tput sgr0
    exit 1
fi
if grep -qE '^[[:space:]]*GRUB_TIMEOUT[[:space:]]*=' "$GRUB_DEFAULT_FILE"; then
    cp "$GRUB_DEFAULT_FILE" "${GRUB_DEFAULT_FILE}.bak"
    sed -i -E "s|^[[:space:]]*GRUB_TIMEOUT[[:space:]]*=.*|GRUB_TIMEOUT=$BOOT_TIME|" "$GRUB_DEFAULT_FILE"
   else
    cp "$GRUB_DEFAULT_FILE" "${GRUB_DEFAULT_FILE}.bak"
    echo "GRUB_TIMEOUT=$BOOT_TIME" >> "$GRUB_DEFAULT_FILE"
fi

# Copy theme folder to grub directory
mkdir -p $GRUB_DIR/themes
THEME_DIR=$GRUB_DIR/themes/$THEME_NAME
rm -rf $THEME_DIR
cp -rf $THEME_NAME $GRUB_DIR/themes

# Replace GRUB_THEME variable
sed -i '/GRUB_THEME=/d' /etc/default/grub
sed -i -e '$a\' /etc/default/grub
echo "GRUB_THEME=\""$THEME_DIR"/theme.txt\"" >> /etc/default/grub

# Update grub config
$GRUB_MKCONFIG -o $GRUB_DIR/grub.cfg

# final message
tput setaf 2
printf "\n"
echo "--------------------------------------------------" 1>&2
echo " $THEME_NAME Grub Theme Has Been Installed " 1>&2
echo "--------------------------------------------------" 1>&2
printf "\n"
tput sgr0
