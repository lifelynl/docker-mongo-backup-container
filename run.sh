#! /bin/bash

set -e

if [ "${SCHEDULE}" = "**None**" ]; then
  bash backup.sh
else
  echo "SHELL=/bin/bash" >> /etc/crontab
  echo "$SCHEDULE root /usr/bin/env bash /backup.sh &>> /var/log/cron.log" >> /etc/crontab
  echo "#" >> /etc/crontab
  touch /var/log/cron.log
  env > /etc/environment # dump env to file so we're able to get vars back when running a script from cron
  cron -f
fi