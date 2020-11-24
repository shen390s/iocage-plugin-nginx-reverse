#!/bin/sh

my-domain() {
  cat /var/db/dhclient.leases.epair0b \
   | grep domain-name \
   | grep -v server \
   | tail -n 1 \
   | awk -F\" '{ print $2 }'
}

MY_FQDN="`hostname`.`my-domain`"

# Enable the service
sysrc -f /etc/rc.conf nginx_enable="YES"

service nginx start
