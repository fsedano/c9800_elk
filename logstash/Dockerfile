FROM ubuntu:16.04
RUN apt-get update && apt-get install -y less openssh-client wget gnupg apt-transport-https apt-utils curl vim  openjdk-8-jdk software-properties-common
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
RUN apt-get update && apt-get install -y logstash
RUN mkdir /root/patterns
RUN mkdir /root/data
COPY logstash_data/*.conf /root/
COPY logstash_data/apache-tiny.log /root/
COPY logstash_data/entrypoint.sh /app/
COPY logstash_data/examples.txt /root/
COPY logstash_data/*.log /root/data/
COPY logstash_data/patterns/* /root/patterns/

#ENTRYPOINT [ "sh", "/app/entrypoint.sh" ]
ENTRYPOINT [ "/usr/share/logstash/bin/logstash", "-f", "/root/custom.conf", "-w", "1"]