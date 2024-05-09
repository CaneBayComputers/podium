#!/bin/bash

PKGS=( firefox firefox-locale-en gufw celluloid hexchat hypnotix redshift-gtk rhythmbox timeshift thunderbird warpinator webapp-manager mintbackup bulky mintwelcome onboard )

for PKG in "${PKGS[@]}"
do
        if sudo apt-get -y -q purge "$PKG"; then true; fi
done