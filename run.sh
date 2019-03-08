#! /bin/bash

set -e

if [ "${SCHEDULE}" = "**None**" ]; then
  bash backup.sh
else
  # Add backup to cron file only if it not already exists
  if ! grep -q "root /usr/bin/env bash /backup.sh" /etc/crontab; then
    echo "SHELL=/bin/bash" >> /etc/crontab
    echo "$SCHEDULE root /usr/bin/env bash /backup.sh > /proc/\$(pgrep -u root -o cron)/fd/1 2>&1" >> /etc/crontab
    echo "#" >> /etc/crontab
  fi
  env > /etc/environment # dump env to file so we're able to get vars back when running a script from cron
  cron -f
fi