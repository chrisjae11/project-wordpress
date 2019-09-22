#!/bin/bash

set -e

mkdir /efs
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_dns}:/ /efs
echo "${efs_dns}:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 " >> /etc/fstab
docker run -d -e WORDPRESS_DB_HOST=${dbhost}:3306 -e WORDPRESS_DB_PASSWORD=${db_pass} -e WORDPRESS_DB_USER=${db_user} -e WORDPRESS_DB_NAME=${db_name} -v /efs/wordpress:/var/www/html -p 80:80 wordpress:latest

sleep 8
container_id=$( docker ps -a -q)
result=$( docker inspect -f {{.State.Running}} $container_id )
if [ $result == "false" ]
  then
    docker start $container_id
fi


# while [ ! -f /efs/wordpress/.htaccess ]
# do
#   sleep 2
# done
# grep "RewriteCond %HTTP:X_CDN" /efs/wordpress/.htaccess || echo $'<IfModule mod_rewrite.c>\nRewriteCond %HTTP:X_CDN !=AMAZON\nRewriteRule ^wp-content/uploads/(.*)$ http://$cloudfront/wp-content/uploads/$1 [r=301,nc]\n</IfModule>' >> /efs/wordpress/.htaccess
