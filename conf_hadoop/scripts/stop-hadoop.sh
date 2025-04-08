#!/bin/bash

# Define variáveis de ambiente
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/apache/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin

source ~/.bashrc

echo "Parando serviços do Hadoop, Hive e dependências..."

# Para os serviços do Hadoop
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh

# Para os serviços auxiliares
service mysql stop
service ssh stop

echo "Todos os serviços foram encerrados com sucesso."
