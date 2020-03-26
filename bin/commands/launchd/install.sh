#!/bin/bash

if [ $EUID != 0 ];
then
	sudo "$0" "$@"
	exit
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f /Library/LaunchDaemons/com.countly.dashboard.plist ];
then
    launchctl unload /Library/LaunchDaemons/com.countly.dashboard.plist
fi
if [ -f /Library/LaunchDaemons/com.countly.api.plist ];
then
    launchctl unload /Library/LaunchDaemons/com.countly.api.plist
fi

cp $DIR/com.countly.dashboard.plist /Library/LaunchDaemons/
cp $DIR/com.countly.api.plist /Library/LaunchDaemons/

launchctl load /Library/LaunchDaemons/com.countly.dashboard.plist
launchctl load /Library/LaunchDaemons/com.countly.api.plist
