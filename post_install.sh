#!/bin/sh

if [ -f /root/bin/apply_role.sh ]; then
   sh /root/bin/apply_role.sh jails/nginx_reverse setup
fi

