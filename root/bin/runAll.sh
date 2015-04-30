#!/bin/bash
#
# Peter.Kutschera@ait.ac.at, 2014-11-11


# if the container was started with data directories mounted from external they might need initialization
if [ -e /wirecloud ]
then 
 if [ ! -e /wirecloud/pgsql ]
 then
  echo Copy PDGATA
  mkdir -p /wirecloud/pgsql
  cp -r /var/lib/pgsql/data /wirecloud/pgsql
  chown -R postgres:postgres /wirecloud/pgsql
 fi
 echo PGDATA=/wirecloud/pgsql/data > /etc/sysconfig/pgsql/postgresql 
 [ -e /wirecloud/catalogue_resources ] ||  mkdir /wirecloud/catalogue_resources
 rm -f /opt/wirecloud_instance/wirecloud_instance/catalogue_resources
 ln -s /wirecloud/catalogue_resources /opt/wirecloud_instance/wirecloud_instance/catalogue_resources
 [ -e /wirecloud/widget_files ] || mkdir /wirecloud/widget_files
 rm -f /opt/wirecloud_instance/wirecloud_instance/widget_files
 ln -s /wirecloud/widget_files /opt/wirecloud_instance/wirecloud_instance/widget_files
 chown -R apache:apache /wirecloud/catalogue_resources /wirecloud/widget_files
else
 rm /etc/sysconfig/pgsql/postgresql 
 ln -sf /opt/wirecloud_instance/wirecloud_instance/catalogue_resources.real /opt/wirecloud_instance/wirecloud_instance/catalogue_resources
 ln -sf /opt/wirecloud_instance/wirecloud_instance/widget_files.real /opt/wirecloud_instance/wirecloud_instance/widget_files
fi

/etc/init.d/postgresql start

( cd /home/ngsi/ngsijs/ngsi-proxy; npm run start )&

# run with --link c_orion:orion 
# or with --env DEFAULT_SILBOPS_BROKER='https://crisma-pilotC.ait.ac.at/orion/'
if [ "x$ORION_NAME" != "x" ]
then
   DEFAULT_SILBOPS_BROKER="http://${ORION_PORT_1026_TCP_ADDR}:${ORION_PORT_1026_TCP_PORT}/"
fi

perl -i.bak -p -e  "s{DEFAULT_SILBOPS_BROKER.*}{DEFAULT_SILBOPS_BROKER = '${DEFAULT_SILBOPS_BROKER}'}" /opt/wirecloud_instance/wirecloud_instance/settings.py

# set wirecloud admin password
while ( ! /opt/wirecloud_instance/manage.py changepassword2secret admin ${WIRECLOUD_ADMIN_PASSWD} )
do
 # wait for postgresql to come up
 sleep 1
 echo retry..
done

# create outpot for `docker logs ... `
cat /opt/wirecloud_instance/wirecloud_instance/settings.py

/usr/sbin/apachectl -D FOREGROUND
