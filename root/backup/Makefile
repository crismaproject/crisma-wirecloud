############################################################
# /home/peter/_work/CRISMA-sw/docker/wirecloud/root/backup/Makefile
# Peter Kutschera, Wed Nov 12 13:11:32 2014
# Time-stamp: "2014-11-12 13:53:45 peter"
# $Id$
# Peter.Kutschera@arcs.ac.at  (Forschungszentrum Seibersdorf)
# Peter@Kutschera.at (privat)
# © Peter Kutschera
#############################################################

MAINDIR = /root/backup/data
DATE := $(shell date '+%Y-%m-%d')
BACKUPDIR = $(MAINDIR)/$(DATE)

all: clean wirecloud

wirecloud:
	[ -d $(BACKUPDIR) ] ||  mkdir -p $(BACKUPDIR)
	pg_dump -U wc_user wirecloud -f /tmp/pg_dump-wirecloud.sql
	tar -czvf $(BACKUPDIR)/wirecloud.tar.gz /tmp/pg_dump-wirecloud.sql /opt/wirecloud_instance/wirecloud_instance/catalogue_resources/ /opt/wirecloud_instance/wirecloud_instance/widget_files/
	rm /tmp/pg_dump-wirecloud.sql

# restore:
#  cd /
#  tar -xf /root/backup/data/2014-11-12/wirecloud.tar.gz 
#  psql -U wc_user wirecloud --command="\d" | grep table | awk '{print "DROP TABLE IF EXISTS " $3 " CASCADE;"}' | psql -U wc_user wirecloud
#  psql -U wc_user wirecloud < /tmp/pg_dump-wirecloud.sql 
#  rm /tmp/pg_dump-wirecloud.sql

clean:
	- find $(MAINDIR) \( -name '*.bak' -o \( -mtime +20 -a -name '[12]*' \) \) -exec rm -rf {} \; 2> /dev/null

