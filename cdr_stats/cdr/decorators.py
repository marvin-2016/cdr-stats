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
from django.http import HttpResponseRedirect
from functools import wraps
from user_profile.models import AccountCode
from switch.models import Switch

def check_user_detail(extra_value=None):
    """
    Decorator to check if accountcode, voipplan_id are attached to user or not
    """
    def _dec(view_func):
        def _caller(request, *args, **kwargs):
            if not request.user.is_superuser:
                try:
                    if len(Switch.objects.all().filter(allowed_staff = request.user.id)) == 0:
                        return HttpResponseRedirect('/?no_switch_error=true')
                    else:
                        return view_func(request, *args, **kwargs)
                except:
                    return HttpResponseRedirect('/?acc_code_error=true')
            return view_func(request, *args, **kwargs)
        return wraps(view_func)(_caller)
    return _dec
