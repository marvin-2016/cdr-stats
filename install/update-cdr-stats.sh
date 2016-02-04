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
#

#
# To download and run the script on your server :
#
# cd /usr/src/ ; rm update-cdr-stats.sh ; wget --no-check-certificate https://raw.github.com/marvin-2016/cdr-stats/master/install/update-cdr-stats.sh -O update-cdr-stats.sh ; bash update-cdr-stats.sh
#
# Install develop branch
# cd /usr/src/ ; rm update-cdr-stats.sh ; wget --no-check-certificate https://raw.github.com/marvin-2016/cdr-stats/develop/install/update-cdr-stats.sh -O update-cdr-stats.sh ; bash update-cdr-stats.sh
#

BRANCH='develop'

#Get Scripts dependencies
cd /usr/src/
rm cdr-stats-update-functions.sh
wget --no-check-certificate https://raw.github.com/marvin-2016/cdr-stats/$BRANCH/install/cdr-stats-update-functions.sh -O cdr-stats-update-functions.sh

#Include cdr-stats update functions
source cdr-stats-update-functions.sh


#Identify the OS
func_identify_os

echo "========================================================================="
echo ""
echo "CDR-Stats update will start now!"
echo ""
echo "Press Enter to continue or CTRL-C to exit"
echo ""
read INPUT

func_activate_virtualenv
func_backup_settings
func_update_source
func_restore_settings
func_django_cdrstats_update

echo ""
echo "Congratulations, CDR-Stats is now updated!"
echo "--------------------------------------------"
echo ""
echo "Thank you for installing CDR-Stats"
echo "Yours,"
echo "The Star2Billing Team"
echo "http://www.star2billing.com and http://www.cdr-stats.org/"
echo ""
echo "========================================================================="
echo ""
