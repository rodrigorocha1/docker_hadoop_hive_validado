#!/bin/bash

echo "Aguardando MySQL iniciar..."
service mysql start
sleep 5

echo "Configurando banco Hive..."
mysql -uroot -proot <<EOF
CREATE USER IF NOT EXISTS 'hive'@'localhost' IDENTIFIED BY 'hive';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost';
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS hive_metastore;
EOF
