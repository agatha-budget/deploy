## Agatha

filename=/home/erica/backup/$(date +"%Y-%m-%d-%H-%M-%S")_backup.sql
if [ $# -eq 0 ]
then pg_dump -U postgres tresorier > $filename
else $1/bin/pg_dump -U postgres tresorier > $filename
fi

## Keycloak

filename1=/home/erica/backup/keycloak_$(date +"%Y-%m-%d-%H-%M-%S")_backup.sql
if [ $# -eq 0 ]
then pg_dump -U keycloak keycloak > $filename1
else $1/bin/pg_dump -U keycloak keycloak > $filename1
fi

. /secrets/nextcloud_secrets.config

nextcloudcmd -u $user -p $password --path /Agatha/backup ./backup $url

nextcloudcmd -u $user -p $password --path /Agatha/log ./logs $url
