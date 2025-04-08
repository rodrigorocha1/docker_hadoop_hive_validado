FROM ubuntu:noble




ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/apache/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HIVE_HOME=/apache/hive
ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=hive_metastore
ENV MYSQL_USER=hive
ENV MYSQL_PASSWORD=hive

ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin:$PATH:$HIVE_HOME/bin:$PATH

RUN mkdir apache scripts_hadoop


WORKDIR /apache

RUN apt update && apt install -y \
    openjdk-8-jdk \
    wget \
    nano \
    mysql-server \
    tar \
    sudo \
    ssh \
    inetutils-telnet \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac

RUN java -version

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld && \
    echo "[mysqld]\nskip-networking=0\nskip-bind-address" >> /etc/mysql/mysql.conf.d/mysqld.cnf

RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz
RUN wget https://downloads.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz
RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.22/mysql-connector-java-8.0.22.jar

RUN tar -xvzf hadoop-3.4.1.tar.gz -C /apache && \
    mv /apache/hadoop-3.4.1 ${HADOOP_HOME} && \
    chmod -R 777 ${HADOOP_HOME} && \
    rm -rf hadoop-3.4.1.tar.gz

RUN tar -xvzf apache-hive-4.0.1-bin.tar.gz -C /apache && \
    mv /apache/apache-hive-4.0.1-bin/ /apache/hive && \
    rm -rf apache-hive-4.0.1-bin.tar.gz

# RUN sed -i 's/sudo //g' ${HADOOP_HOME}/libexec/hadoop-functions.sh

RUN mkdir -p ${HADOOP_HOME}/data/dfs/namespace_logs
RUN mkdir -p ${HADOOP_HOME}/data/dfs/data



COPY ./conf_hadoop/*.xml ${HADOOP_CONF_DIR}

COPY ./conf_hive/init_mysql.sh /scripts_hadoop/init_mysql.sh
RUN chmod +x /scripts_hadoop/init_mysql.sh

RUN echo "export JAVA_HOME=${JAVA_HOME}" >> ${HADOOP_CONF_DIR}/hadoop-env.sh && \
    echo 'export HDFS_NAMENODE_USER=root' >> ${HADOOP_CONF_DIR}/hadoop-env.sh && \
    echo 'export HDFS_DATANODE_USER=root' >> ${HADOOP_CONF_DIR}/hadoop-env.sh && \
    echo 'export HDFS_SECONDARYNAMENODE_USER=root' >> ${HADOOP_CONF_DIR}/hadoop-env.sh && \
    echo 'export YARN_RESOURCEMANAGER_USER=root' >> ${HADOOP_CONF_DIR}/hadoop-env.sh && \
    echo 'export YARN_NODEMANAGER_USER=root' >> ${HADOOP_CONF_DIR}/hadoop-env.sh
# RUN source /apache/hadoop/etc/hadoop/hadoop-env.sh


RUN echo "export HADOOP_HOME=${HADOOP_HOME}" >> ~/.bashrc && \
    echo "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> ~/.bashrc

RUN echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile && \
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile && \
    echo "source /etc/profile" >> /root/.bashrc

RUN ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

RUN ${HADOOP_HOME}/bin/hdfs namenode -format

COPY ./conf_hadoop/scripts/ /scripts_hadoop/

RUN chmod +x /scripts_hadoop/*.sh

RUN mv mysql-connector-java-8.0.22.jar $HIVE_HOME/lib/

COPY ./conf_hive/conf_xml/hive-site.xml $HIVE_HOME/conf/hive-site.xml




EXPOSE 50070 8088 50075 50090 9870 9864 10020 19888 10000 10002


CMD ["/bin/bash", "/scripts_hadoop/start-hadoop.sh"]


# Usa um script para gerenciar o início e encerramento do Hadoop
