FROM sequenceiq/hadoop-docker:2.6.0
MAINTAINER SequenceIQ

#support for Hadoop 2.6.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.1-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.6.1-bin-hadoop2.6/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin
# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

#install R
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install R

# DÉBUT CONTENEUR À NE PAS FERMER  
###################################
RUN curl -s https://nodejs.org/dist/v6.11.0/node-v6.11.0-linux-x64.tar.xz | tar -xvJ -C /usr/local/
#RUN cd /usr/local && ln -s node-v6.11.0-linux-x64/bin/node node 
#RUN cd /usr/local && ln -s node-v6.11.0-linux-x64/lib/node_modules/npm/bin/npm npm

ENV PATH $PATH:/usr/local/node-v6.11.0-linux-x64/bin

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install

COPY . /usr/src/app

EXPOSE 8080

COPY id_rsa.pub /root/.ssh/authorized_keys


# FIN CONTENEUR À NE PAS FERMER
#################################
ENTRYPOINT ["/etc/bootstrap.sh"]

CMD [ "npm", "start" ]
