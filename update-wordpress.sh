#!/bin/bash

set -e
set -u

WEB_PATH=/var/www/html
WP_PATH=$(ls -1 $WEB_PATH | grep -v lost.found | tail -n1)
FULL_WP_PATH="$WEB_PATH/$WP_PATH"
BACKUP_DIR=/var/backup/wordpress
DELETE_LIST="wp-content wp-config.php"

#
# check the version after it was downloaded - exit on same version
#
function check_version {
        version_new=$(grep '^\$wp_version' wp-includes/version.php | grep -o '[0-9.]\+')
        version_old=$(grep '^\$wp_version' $FULL_WP_PATH/wp-includes/version.php | grep -o '[0-9.]\+')
        if [ $version_new -le $version_old ]
        then
                cleanup
                echo "is uptodate"
                exit 0
        fi
}

#
# do the update
#
function update {
        cd /usr/src/wordpress/

        # exit if version is uptodate
        check_version

        rm -Rf $DELETE_LIST
        chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" .

        rsync -a . $FULL_WP_PATH
}

update

