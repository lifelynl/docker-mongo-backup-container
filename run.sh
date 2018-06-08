#! /bin/sh

set -e

if [ "${SCHEDULE}" = "**None**" ]; then
  sh backup.sh
else
  echo "run.sh started"
  # Format: minute hour day-of-month month day-of-week command
  # echo "$SCHEDULE root /bin/sh /backup.sh 2>&1" > /etc/crontab
  echo "$SCHEDULE root echo \"hallo\" > /tmp/testyo" > /etc/crontab
  echo "#" >> /etc/crontab
  # chmod 0644 /var/spool/cron/crontabs/root
  touch /var/log/cron.log
  cron -f
fi