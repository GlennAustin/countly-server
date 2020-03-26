#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# use available init system
INITSYS="systemd"

if [ "$INSIDE_DOCKER" = "1" ]
then
	INITSYS="docker" 
elif [[ `/sbin/init --version` =~ upstart ]];
then
    INITSYS="upstart"
elif [ -x /sbin/launchd -a -x /bin/launchctl ];
then
	INITSYS="launchd"
fi 2> /dev/null

bash $DIR/commands/$INITSYS/install.sh
ln -sf $DIR/commands/$INITSYS/countly.sh $DIR/commands/enabled/countly.sh

chmod +x $DIR/commands/countly.sh
ln -sf $DIR/commands/countly.sh /usr/local/bin/countly

cp -f $DIR/commands/scripts/autocomplete/countly /etc/bash_completion.d
