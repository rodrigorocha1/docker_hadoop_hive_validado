#!/bin/bash

# Define variáveis de ambiente
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/apache/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HIVE_HOME=/apache/hive
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$JAVA_HOME/bin

source ~/.bashrc
source /etc/profile

echo "Iniciando SSH"
# Inicia o SSH
service ssh start

echo "Iniciando MySql"
# Inicia o MySQL
service mysql start

# Executa a configuração inicial do MySQL para o Hive
echo "Executa a configuração inicial do MySQL para o Hive"
/scripts_hadoop/init_mysql.sh

echo "Iniciando metastore HIVE"
# Inicializa o metastore do Hive (se ainda não inicializado)
schematool -dbType mysql -initSchema --verbose

echo "Iniciando Hadoop"
# Inicia o Hadoop
$HADOOP_HOME/sbin/start-all.sh

echo "Iniciando Metastore e Hiveserver2"
# Inicia o Hive Metastore e HiveServer2
hive --service metastore &>/dev/null &
hive --service hiveserver2 &>/dev/null &

# Captura sinais de encerramento (CTRL+C ou Docker Stop) e executa o stop-hadoop.sh
trap "/scripts_hadoop/stop-hadoop.sh" SIGTERM SIGINT

# Mantém o contêiner rodando
while true; do sleep 60; done
