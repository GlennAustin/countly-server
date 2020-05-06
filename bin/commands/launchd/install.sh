#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make sure that brew is installed - we'll need it.
# brew can only be installed on a non-root user, so get the original user and install/run brew as them.
if [ ! -x /usr/local/bin/brew ]
then
	if [ $EUID == 0 ]
	then
		echo "Brew can't be installed as root"
		exit 1
	fi
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Make sure that mongodb is installed
MONGODB=mongodb-community@3.6
if [ -z "$(sudo -u $SUDO_USER brew list | grep "$MONGODB")" ]
then
	# mongodb is now on its own brew tap. make sure we have it tapped.
	if [ $EUID == 0 ]
	then
		echo "Brew can't be run as root"
		exit 1
	fi
	if [ -z "$(brew tap | grep mongodb/brew)" ]
	then
		brew tap mongodb/brew
	fi
	brew install "$MONGODB"
fi

# Make sure that mongodb is running
MONGO_RUNNING="$(sudo brew services list | grep "$MONGODB")"
if [ -z "$MONGO_RUNNING" -o "$(echo "$MONGO_RUNNING" | sed -E -e 's/^[^[:space:]]+[[:space:]]([[:alpha:]]+)[[:space:]].+$/\1/')" = "stopped" ]
then
	sudo brew services start $mongodb
fi

# Make sure that nodeenv is installed under brew
if [ -z "$(sudo -u $SUDO_USER brew list | grep nodeenv)" ]
then
	if [ $EUID == 0 ]
	then
		echo "Brew can't be run as root"
		exit 1
	fi
	brew install nodeenv
fi

# Make sure that nodeenv is set up for countly
COUNTLY_DIR="$( cd "$DIR"/../../.. && pwd )"
if [ ! -d "$COUNTLY_DIR/.nodeenv" ]
then
	( cd "$COUNTLY_DIR" && nodeenv -n 10.19.0 .nodeenv )
fi

# Create a symbolic link to this countly in /usr/local/countly-current
rm -f /usr/local/countly-current
ln -s "$COUNTLY_DIR" /usr/local/countly-current

if [ -f /Library/LaunchDaemons/com.countly.dashboard.plist ];
then
    sudo launchctl unload /Library/LaunchDaemons/com.countly.dashboard.plist
fi
if [ -f /Library/LaunchDaemons/com.countly.api.plist ];
then
    sudo launchctl unload /Library/LaunchDaemons/com.countly.api.plist
fi

sudo cp $DIR/com.countly.api.plist /Library/LaunchDaemons/
sudo cp $DIR/com.countly.dashboard.plist /Library/LaunchDaemons/

sudo launchctl load /Library/LaunchDaemons/com.countly.api.plist
sudo launchctl load /Library/LaunchDaemons/com.countly.dashboard.plist
