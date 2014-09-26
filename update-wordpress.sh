#!/bin/bash

set -e
set -u

WEB_PATH=/var/www/html
WP_PATH=$(ls -1 $WEB_PATH | grep -v lost.found | tail -n1)
FULL_WP_PATH="$WEB_PATH/$WP_PATH"
TMP_DIR=$(mktemp -d)
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
# make a backup of the current version, keep 3 versions
#
function backup {
        mkdir -p $BACKUP_DIR
        tar -czf $BACKUP_DIR/wordpress-$(date +%F.%s).tar.gz $FULL_WP_PATH
        cd $BACKUP_DIR
        ls -1t $BACKUP_DIR | sed -n '4,$ p' | xargs rm -f
}

#
# do the update
#
function update {
        cd $TMP_DIR
        wget https://wordpress.org/latest.zip
        unzip latest.zip
        wget https://i18n.svn.wordpress.org/fr_FR/$(sed -n 's/^\(\d\.\d\).*/\1/' $version_new)/*.mo
        wget https://i18n.svn.wordpress.org/de_DE/$(sed -n 's/^\(\d\.\d\).*/\1/' $version_new)/*.mo
        cd wordpress

        # exit if version is uptodate
        check_version

        rm -Rf $DELETE_LIST
        chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" .

        rsync -a . $FULL_WP_PATH
}

#
# cleanup all temp stuff
#
function cleanup {
        rm -Rf $TMP_DIR
}


backup
update
cleanup

