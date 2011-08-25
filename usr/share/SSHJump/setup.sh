#!/bin/bash

BASE_DIR=/home/sshjump/SSHJump
GROUP=sshjump
USER=sshjump
RELOAD=0

while getopts r options
do
	case "$options" in
		r) RELOAD=1;;
	esac
done

chmod -R 750 ${BASE_DIR}
chmod 600 ${BASE_DIR}/etc/sshjump.conf

# Banner for /sbin/nologin
cp ${BASE_DIR}/etc/nologin.txt /etc

# Create group for sudoers
if ! id -g ${GROUP}; then
	groupadd ${GROUP}
fi

# Add initial superadmin account...password = 'password'
if ! id ${USER}; then
	useradd -c 'SUPERADMIN account for SSHJump' -g ${GROUP} -p '$1$w0paUb1n$fzr7nDA9AtOT7s90kHPJI/' ${USER}
fi

# Configure the admin user's enviroment...
if ! grep '^# SSHJump Environment' /home/${USER}/.bashrc; then
	cat <<END >> /home/${USER}/.bashrc
# SSHJump Environment
export SSHJUMP_CONF=/etc/sshjump.conf
END
fi

# Add this line to /etc/sudoers manually...maybe we can script this...
if ! grep ^${USER} /etc/sudoers; then
	cat <<END >> /etc/sudoers
%sshjump ALL=(sshjump) /bin/bash, /usr/bin/sshjump-admin.pl, /usr/bin/sshjump.pl
sshjump ALL=(root) NOPASSWD: /usr/sbin/usermod, /usr/sbin/useradd, /usr/sbin/userdel, /usr/bin/chage
END
fi

if [ ! -d /usr/share/SSHJump ]; then
	mkdir /usr/share/SSHJump
	chown sshjump:sshjump /usr/share/SSHJump
	chmod 700 /usr/share/SSHJump
fi

cp ${BASE_DIR}/etc/sshjump.conf /etc/sshjump.conf
chown sshjump:sshjump /etc/sshjump.conf
chmod 600 /etc/sshjump.conf

cp ${BASE_DIR}/etc/cron.d/sshjump /etc/cron.d
chmod 644 /etc/cron.d/sshjump

cp -r ${BASE_DIR}/usr/lib/perl5/vendor_perl/5.8.8/SSHJump /usr/lib/perl5/vendor_perl/5.8.8
chmod -R 444 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/App
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/App/Control
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/App/Verify
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/DB
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/DB/Join
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/DB/Collection
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/DB/Collection/Join
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/Dialog
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/System
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/System/Call
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/System/Call/Script
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/System/Call/Sudo
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/Moose
chmod 755 /usr/lib/perl5/vendor_perl/5.8.8/SSHJump/Verify
cp ${BASE_DIR}/usr/bin/sshjump* /usr/bin
chmod 755 /usr/bin/sshjump*

if [[ $RELOAD -eq 1 ]]; then
	# Set up the database
	cd ${BASE_DIR}/usr/share/SSHJump/sql
	./load.sh -u ${USER}

	# Need cron script to check for files in /home/sshjump/hosts, cp them to /etc, and remove them...
fi

# Password policy
sed -i 's:^PASS_MAX_DAYS.*:PASS_MAX_DAYS\t90:' /etc/login.defs
sed -i 's:^PASS_MIN_DAYS.*:PASS_MIN_DAYS\t14:' /etc/login.defs
sed -i 's:^PASS_MIN_LEN.*:PASS_MIN_LEN\t8:' /etc/login.defs

cat <<EOF >> /etc/sshjump.conf.new
VERSION             = 0.9.0
UPDATED             = 2010-09-30
GUI_NAME            = SSHJump System
BUG_REPORT_HOWTO    = Open a SJ ticket in Jira

DB_NAME             = sshjump
DB_USER             = sshjump
DB_PASS             = 7ikX%fz2:

LOG_FILE            = /home/sshjump/sshjump_debug.txt
SSH_KEY_DIR         = /home/sshjump/.ssh
SSH_KEY_SIZE        = 4096

# Temporary directory for 'dialog' output
DIALOG_DIR          = /home/sshjump/.dialog

# Holds logs generated from the 'script' command
SCRIPT_LOG_DIR      = /home/sshjump/.script_logs

# Temporary directory for storing script logs for playback
SCRIPT_PLAYBACK_DIR = /home/sshjump/.playback

# Temporary directory for storing modifired hosts.allow and hosts.deny
HOSTS_TMP_DIR       = /home/sshjump/.ipfiltering

# Holds static html reports for each script log
HTML_LOG_DIR        = /var/www/html/sshjump/script_logs

# Relative url path for viewing html reports.
# Should be HTML_LOG_DIR minus SSHJump's web root...
REL_HTML_LOG_DIR    = script_logs

HTPASSWD            = /etc/httpd/.htpasswd
EOF

mv /etc/sshjump.conf.new /etc/sshjump.conf
chown sshjump:sshjump /etc/sshjump.conf
chmod 700 /etc/sshjump.conf
