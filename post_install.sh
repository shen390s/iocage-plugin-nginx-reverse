#!/bin/sh

my-domain() {
  cat /var/db/dhclient.leases.epair0b \
   | grep domain-name \
   | grep -v server \
   | tail -n 1 \
   | awk -F\" '{ print $2 }'
}

get_server_conf() {
   _name="$1"
   _conf="$2"

   _z1=`echo $_name $_conf | sed 's/ /_/g'`
   _z2="echo \$$_z1"
   _val=`eval $_z2`
   echo $_val
}

mk_server() {
   _name="$1"
   _port=$LISTEN_PORT
   _server_name=`get_server_conf $_name name`.`my-domain`
   _server_url=`get_server_conf $_name url`

   _cmd="sed -e 's@%%PORT%%@$_port@g' "
   _cmd="$_cmd -e 's@%%SERVER_NAME%%@$_server_name@g'"
   _cmd="$_cmd -e 's@%%URL%%@$_server_url@g' "

   cat /usr/local/etc/nginx/conf.d/server.conf.template | \
       eval "$_cmd" >/usr/local/etc/nginx/conf.d/$_name.conf       
}

mk_auth() {
    _auth_file="/usr/local/etc/nginx/htpasswd"
    touch $_auth_file

    for _user in $proxy_users; do
	_z1=`echo $_user passwd|sed 's/ /_/g'`
	_z2="echo \$$_z1"
	_passwd=`eval $_z2`
	/usr/local/bin/htpasswd.py -b $_auth_file "$_user" "$_passwd"
    done
}

MY_FQDN="`hostname`.`my-domain`"

# Enable the service
sysrc -f /etc/rc.conf nginx_enable="YES"

if [ -f /root/servers.conf ]; then
   . /root/servers.conf
fi

mk_auth

for _server in $SERVERS; do
    mk_server $_server
done

# install cert
gzip -dc letsencrypt.tar.gz | (cd /usr/local/etc && tar xvf -)

# service nginx start
