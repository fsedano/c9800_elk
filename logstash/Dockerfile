FROM ubuntu:18.04
RUN apt-get update && apt-get install -y less openssh-client wget gnupg apt-transport-https apt-utils curl vim default-jre
RUN apt-get install -y software-properties-common
RUN  add-apt-repository -y ppa:webupd8team/java
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN apt-get install -y oracle-java8-set-default
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
RUN apt-get update && apt-get install -y logstash
RUN apt-get install -y inetutils-ping
COPY logstash_data/simple.conf /root/
COPY logstash_data/apache.conf /root/
COPY logstash_data/apache-access.log /root
COPY logstash_data/apache-tiny.log /root/



