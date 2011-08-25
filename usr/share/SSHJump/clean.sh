#!/bin/sh

GROUP=sshjump
USER=sshjump

DB_NAME=sshjump
DB_USER=sshjump

rm /etc/nologin.txt
touch /etc/nologin.txt

GROUP_LINE=`cat /etc/group | grep sshjump`
GROUP_LIST=`echo "${GROUP_LINE}" | awk -F: '{printf "%s",$4}'`
GROUP_ARRAY=( `echo "${GROUP_LIST}" | tr -s ',' ' '` )

for ADMIN in ${GROUP_ARRAY[@]}
do
	echo "Removing ${ADMIN}..."
	userdel -r ${ADMIN}
done

# Clean Environment
sed '/SSHJ[Uu][Mm][Pp]/d' /home/${USER}/.bashrc > /home/${USER}/.bashrc.new
mv /home/${USER}/.bashrc.new /home/${USER}/.bashrc

# Clean /etc/sudoers
sed "/${USER}/d" /etc/sudoers > /etc/sudoers.new
mv /etc/sudoers.new /etc/sudoers

sed "/${GROUP}/d" /etc/sudoers > /etc/sudoers.new
mv /etc/sudoers.new /etc/sudoers
chmod 0440 /etc/sudoers

# Remove SSHJump files
rm -rf /usr/share/SSHJump
rm -rf /usr/lib/perl5/vendor_perl/5.8.8/SSHJump

rm /etc/sshjump.conf
rm /etc/cron.d/sshjump
rm /usr/bin/sshjump*

# Remove Database
mysql -uroot -e "DROP DATABASE ${DB_NAME}";
mysql -uroot -e "DROP USER '${DB_USER}'@'localhost'";

# Restore Password Policy
sed -i 's:^PASS_MAX_DAYS.*:PASS_MAX_DAYS\t99999:' /etc/login.defs
sed -i 's:^PASS_MIN_DAYS.*:PASS_MIN_DAYS\t0:' /etc/login.defs
sed -i 's:^PASS_MIN_LEN.*:PASS_MIN_LEN\t5:' /etc/login.defs
