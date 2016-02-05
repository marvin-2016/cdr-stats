#!/bin/bash
#
# CDR-Stats License
# http://www.cdr-stats.org
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (C) 2011-2015 Star2Billing S.L.
#
# The Initial Developer of the Original Code is
# Arezqui Belaid <info@star2billing.com>

BRANCH='develop'

#Install mode can me either CLONE or DOWNLOAD

INSTALL_DIR='/usr/share/cdrstats'
CDRSTATS_ENV="cdr-stats"
SCRIPT_NOTICE="This install script is only intended to run on Debian 7.X"

#Django bug https://code.djangoproject.com/ticket/16017
export LANG="en_US.UTF-8"

# Identify Linux Distribution
func_identify_os() {
    if [ -f /etc/debian_version ] ; then
        DIST='DEBIAN'
        if [ "$(lsb_release -cs)" != "wheezy" ] && [ "$(lsb_release -cs)" != "jessie" ]; then
            echo $SCRIPT_NOTICE
            exit 255
        fi
        DEBIANCODE=$(lsb_release -cs)
    elif [ -f /etc/redhat-release ] ; then
        DIST='CENTOS'
        if [ "$(awk '{print $3}' /etc/redhat-release)" != "6.2" ] && [ "$(awk '{print $3}' /etc/redhat-release)" != "6.3" ] && [ "$(awk '{print $3}' /etc/redhat-release)" != "6.4" ] && [ "$(awk '{print $3}' /etc/redhat-release)" != "6.5" ]; then
            echo $SCRIPT_NOTICE
            exit 255
        fi
    else
        echo $SCRIPT_NOTICE
        exit 1
    fi
}

#Fuction to create the virtual env
func_activate_virtualenv() {
    #Prepare settings for installation
    case $DIST in
        'DEBIAN')
            SCRIPT_VIRTUALENVWRAPPER="/usr/share/virtualenvwrapper/virtualenvwrapper.sh"
        ;;
        'CENTOS')
            SCRIPT_VIRTUALENVWRAPPER="/usr/bin/virtualenvwrapper.sh"
        ;;
    esac

    # Setup virtualenv
    export WORKON_HOME=/opt/miniconda/envs/
    source $SCRIPT_VIRTUALENVWRAPPER

    workon $CDRSTATS_ENV

    echo "Virtualenv $CDRSTATS_ENV activated"
}

#Function to install the code source
func_update_source(){

    #get CDR-Stats
    echo "Update CDR-Stats..."
    cd /usr/src/
    rm -rf cdr-stats
    mkdir /var/log/cdr-stats

    git clone -b $BRANCH git://github.com/marvin-2016/cdr-stats.git
    cd cdr-stats

    # Copy files
    cp -r /usr/src/cdr-stats/cdr_stats/* $INSTALL_DIR/
}

#Function to prepare settings_local.py
func_backup_settings(){
    #Copy settings_local.py into tmp dir
    cp $INSTALL_DIR/cdr_stats/settings_local.py /tmp/settings_local.py
}

#Function to prepare settings_local.py
func_restore_settings(){
    #Copy settings_local.py from tmp dir
    mv /tmp/settings_local.py $INSTALL_DIR/cdr_stats/settings_local.py
}

#Update Django CDR-stats
func_django_cdrstats_update(){
    cd $INSTALL_DIR/
    python manage.py syncdb --noinput
    python manage.py migrate

    echo ""
    echo "Collects the static files"
    python manage.py collectstatic --noinput

    #Load Countries Dialcode
    python manage.py load_country_dialcode

    #Load default gateways & billing data
    python manage.py loaddata voip_gateway/fixtures/voip_gateway.json
    python manage.py loaddata voip_gateway/fixtures/voip_provider.json
    python manage.py load_sample_voip_billing
}
