# Java 8
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get -y update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer
sudo apt-get -y install oracle-java8-set-default

# Elasticsearch
sudo curl -L -O https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.4/elasticsearch-2.3.4.tar.gz
sudo tar -xvf elasticsearch-2.3.4.tar.gz
sudo chown -R `whoami`: ./elasticsearch-2.3.4/

# Kibana
sudo curl -L -O https://download.elastic.co/kibana/kibana/kibana-4.5.2-linux-x64.tar.gz
sudo tar -xvf kibana-4.5.2-linux-x64.tar.gz

# Fluentd
sudo curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh

## Fluentd plugins
### Elasticsearch plugin
sudo /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-elasticsearch
## Forward plugin
sudo /usr/sbin/td-agent-gem install fluent-plugin-secure-forward

## Fluentd configuration
echo "
# Listen to Syslog
<source>
  @type syslog
  port 42185
  tag syslog
</source>

# Listen to Elasticsearch
<source>
  @type http
  port 9201
</source>

<source>
  @type tail
  path /home/ubuntu/elasticsearch-2.3.4/logs/elasticsearch.log
  format /^\[[^ ]* (?<time>[^\]]*)\]\[(?<level>[^\]]*)\](?<message>.*)$/
  pos_file /var/log/td-agent/elasticsearch.log.pos
  tag elastic
</source>

<source>
  @type forward
</source>

<match *.**>
  @type elasticsearch
  logstash_format true
  flush_interval 10s # for testing
</match>
" | sudo tee /etc/td-agent/td-agent.conf > /dev/null

# rsyslog
echo '*.* @127.0.0.1:42185' | sudo tee --append /etc/rsyslogd.conf > /dev/null
sudo /etc/init.d/rsyslog restart
