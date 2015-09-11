#!/bin/sh

echo
echo "###########################################################"
echo
echo ">>> Installing vhots"

synced_folder_temp="$1"
vhosts_root_path_temp="$2"

# Virtual hosts from backup
cp $synced_folder_temp/$vhosts_root_path_temp/nginx/* /etc/nginx/sites-available/
dos2unix /etc/nginx/sites-available/*

echo "Nginx hosts"
AVAILABLE_SITES=/etc/nginx/sites-available/*
for f in $AVAILABLE_SITES
do
  echo "Procesez $f ..."
  site=${f##*/}
  sudo ngxen $site

  if ! grep -q "www.$site.dev" /etc/hosts; then
    echo "127.0.0.1 www.$site.dev" >> /etc/hosts
  fi
done

sudo service php5-fpm restart
sudo service nginx restart