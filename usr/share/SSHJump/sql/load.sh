#!/bin/bash

# Configuration variables...
DB_NAME='sshjump'
SUPER_ADMIN='sshjump'
HOST=${HOSTNAME}

DB_USER_RW='sshjump'
DB_PASS_RW='7ikX%fz2:'
DB_USER_RO='sshjump-reports'
DB_PASS_RO='iwnffitmk'

while getopts :u:d:h options
do
	case "$options" in
		u) SUPER_ADMIN=$OPTARG;;
		d) DB_NAME=$OPTARG;;
		h) HOST=$OPTARG;;
	esac
done

# Run this as root...
mysql -uroot -e "DROP DATABASE IF EXISTS ${DB_NAME}";
mysql -uroot -e "DROP USER '${DB_USER_RW}'@'localhost'" > /dev/null 2>&1;
mysql -uroot -e "DROP USER '${DB_USER_RO}'@'localhost'" > /dev/null 2>&1;

mysql -uroot -e "CREATE DATABASE ${DB_NAME}";

mysql -uroot sshjump < session.sql
mysql -uroot sshjump < sshkey.sql
mysql -uroot sshjump < group.sql
mysql -uroot sshjump < user.sql
mysql -uroot sshjump < user_group.sql
mysql -uroot sshjump < host.sql
mysql -uroot sshjump < host_alias.sql
mysql -uroot sshjump < log.sql
mysql -uroot sshjump < host_group.sql

# Read-Write user for all admin functions
mysql -uroot -e "CREATE USER '${DB_USER_RW}'@'localhost' IDENTIFIED BY '${DB_PASS_RW}'";
mysql -uroot -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER_RW}'@'localhost'";

# Read-Only user for reporting
mysql -uroot -e "CREATE USER '${DB_USER_RO}'@'localhost' IDENTIFIED BY '${DB_PASS_RO}'";
mysql -uroot -e "GRANT SELECT ON ${DB_NAME}.* TO '${DB_USER_RO}'@'localhost'";

# Add superadmin account to database
mysql -uroot -e "INSERT INTO user (username, access) VALUES ('${SUPER_ADMIN}', 'SUPERADMIN')" ${DB_NAME}

# Add sshjump host to database
mysql -uroot -e "INSERT INTO host (hostname, customer) VALUES ('${HOST}', 'ICA')" ${DB_NAME}
